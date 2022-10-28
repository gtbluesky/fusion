//
//  FusionEngineBinding.swift
//  fusion
//
//  Created by gtbluesky on 2022/3/10.
//

import Foundation

internal class FusionEngineBinding: NSObject {
    private let isReused: Bool
    weak private var container: FusionViewController? = nil
    private var navigationChannel: FlutterMethodChannel? = nil
    private var notificationChannel: FlutterMethodChannel? = nil
    private var platformChannel: FlutterMethodChannel? = nil
    var engine: FlutterEngine? = nil
    private var history: [Dictionary<String, Any?>] {
        get {
            FusionStackManager.instance.pageStack.flatMap {
                ($0.value)?.history ?? []
            }
        }
    }

    init(_ isReused: Bool) {
        self.isReused = isReused
        super.init()
        if (!isReused) {
            engine = Fusion.instance.createAndRunEngine()
        } else {
            engine = Fusion.instance.defaultEngine
        }
        guard let engine = engine else {
            return
        }
        navigationChannel = FlutterMethodChannel(name: FusionConstant.FUSION_NAVIGATION_CHANNEL, binaryMessenger: engine.binaryMessenger)
        notificationChannel = FlutterMethodChannel(name: FusionConstant.FUSION_NOTIFICATION_CHANNEL, binaryMessenger: engine.binaryMessenger)
        platformChannel = FlutterMethodChannel(name: FusionConstant.FUSION_PLATFORM_CHANNEL, binaryMessenger: engine.binaryMessenger)
    }

    func attach(_ container: FusionViewController? = nil) {
        self.container = container
        navigationChannel?.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            switch call.method {
            case "push":
                guard let dict = call.arguments as? Dictionary<String, Any>, let name = dict["name"] as? String else {
                    result(nil)
                    return
                }
                let arguments = dict["arguments"] as? Dictionary<String, Any>
                let isFlutterPage = dict["flutter"] as? Bool ?? false
                if isFlutterPage {
                    if !self.isReused {
                        if self.container?.history.isEmpty == true {
                            // 在原Flutter容器打开Flutter页面
                            // 即用户可见的第一个页面
                            let pageInfo: Dictionary<String, Any?> = [
                                "name": name,
                                "arguments": arguments,
                                "uniqueId": UUID().uuidString,
                                "home": true
                            ]
                            self.container?.history.append(pageInfo)
                            result(pageInfo)
                        } else {
                            // 在新Flutter容器打开Flutter页面
                            Fusion.instance.delegate?.pushFlutterRoute(name: name, arguments: arguments)
                            result(nil)
                        }
                    } else {
                        // 在原Flutter容器打开Flutter页面
                        guard let topContainer = FusionStackManager.instance.getTopContainer() as? FusionViewController else {
                            result(nil)
                            return
                        }
                        let pageInfo: Dictionary<String, Any?> = [
                            "name": name,
                            "arguments": arguments,
                            "uniqueId": UUID().uuidString,
                            "home": topContainer.history.isEmpty
                        ]
                        topContainer.history.append(pageInfo)
                        result(pageInfo)
                        if topContainer.history.count == 1 {
                            self.addPopGesture()
                        } else {
                            self.removePopGesture()
                        }
                    }
                } else {
                    // 打开Native页面
                    Fusion.instance.delegate?.pushNativeRoute(name: name, arguments: arguments)
                    result(nil)
                }
            case "replace":
                if !self.isReused {
                    result(nil)
                    return
                }
                guard let dict = call.arguments as? Dictionary<String, Any>, let name = dict["name"] as? String else {
                    result(nil)
                    return
                }
                let arguments = dict["arguments"] as? Dictionary<String, Any>
                guard let topContainer = FusionStackManager.instance.getTopContainer() as? FusionViewController else {
                    result(nil)
                    return
                }
                topContainer.history.removeLast()
                let pageInfo: Dictionary<String, Any?> = [
                    "name": name,
                    "arguments": arguments,
                    "uniqueId": UUID().uuidString,
                    "home": topContainer.history.isEmpty
                ]
                topContainer.history.append(pageInfo)
                result(pageInfo)
            case "pop":
                if !self.isReused {
                    // 子页面不支持pop
                    result(false)
                    return
                }
                guard let topContainer = FusionStackManager.instance.getTopContainer() as? FusionViewController else {
                    // flutter容器关闭后
                    // 仅刷新history，让容器第一个可见Flutter页面出栈
                    result(false)
                    return
                }
                if topContainer.history.count == 1 {
                    // 仅关闭flutter容器
                    FusionStackManager.instance.closeTopContainer()
                    result(false)
                } else {
                    // flutter页面pop
                    topContainer.history.removeLast()
                    result(true)
                }
                if topContainer.history.count == 1 {
                    self.addPopGesture()
                } else {
                    self.removePopGesture()
                }
            case "remove":
                if !self.isReused {
                    result(false)
                    return
                }
                guard let dict = call.arguments as? Dictionary<String, Any>, let name = dict["name"] as? String else {
                    result(false)
                    return
                }
                guard let topContainer = FusionStackManager.instance.getTopContainer() as? FusionViewController else {
                    result(false)
                    return
                }
                let index = topContainer.history.lastIndex {
                    $0["name"] as? String == name
                } ?? -1
                if index >= 0 {
                    topContainer.history.remove(at: index)
                }
                result(true)
                if topContainer.history.count == 1 {
                    self.addPopGesture()
                } else {
                    self.removePopGesture()
                }
            case "restoreHistory":
                if self.isReused {
                    result(self.history)
                } else {
                    result(nil)
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        notificationChannel?.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            switch call.method {
            case "sendMessage":
                guard let dict = call.arguments as? Dictionary<String, Any>, let name = dict["name"] as? String else {
                    result(nil)
                    return
                }
                let body = dict["body"] as? Dictionary<String, Any>
                FusionStackManager.instance.sendMessage(name, body: body)
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    func addPopGesture() {
        if (!isReused) {
            return
        }
        let vc = UIApplication.roofViewController
        if !(vc is FusionViewController) {
            return
        }
        (vc as? FusionPopGestureHandler)?.enablePopGesture()
    }

    func removePopGesture() {
        if (!isReused) {
            return
        }
        let vc = UIApplication.roofViewController
        if !(vc is FusionViewController) {
            return
        }
        (vc as? FusionPopGestureHandler)?.disablePopGesture()
    }

    func push(_ name: String, arguments: Dictionary<String, Any>?) {
        navigationChannel?.invokeMethod(
                "push",
                arguments: [
                    "name": name,
                    "arguments": arguments as Any
                ]
        )
    }

    func replace(_ name: String, arguments: Dictionary<String, Any>?) {
        navigationChannel?.invokeMethod(
                "replace",
                arguments: [
                    "name": name,
                    "arguments": arguments as Any
                ]
        )
    }

    func pop(active: Bool = false, result: Any? = nil) {
        navigationChannel?.invokeMethod(
                "pop",
                arguments: [
                    "active": active,
                    "result": result
                ],
                result: { [weak self] (result) in
                    // 子页面退出后销毁Engine
                    if !active && self?.isReused == false {
                        self?.detach()
                    }
                }
        )
    }

    func remove(_ name: String) {
        navigationChannel?.invokeMethod(
                "remove",
                arguments: [
                    "name": name,
                ]
        )
    }

    func notifyPageVisible() {
        notificationChannel?.invokeMethod("notifyPageVisible", arguments: nil)
    }

    func notifyPageInvisible() {
        notificationChannel?.invokeMethod("notifyPageInvisible", arguments: nil)
    }

    func notifyEnterForeground() {
        notificationChannel?.invokeMethod("notifyEnterForeground", arguments: nil)
    }

    func notifyEnterBackground() {
        notificationChannel?.invokeMethod("notifyEnterBackground", arguments: nil)
    }

    func dispatchMessage(_ msg: Dictionary<String, Any?>) {
        notificationChannel?.invokeMethod("dispatchMessage", arguments: msg)
    }

    func latestStyle(_ callback: @escaping (_ statusBarStyle: UIStatusBarStyle) -> Void) {
        let infoValue = Bundle.main.object(forInfoDictionaryKey: "UIViewControllerBasedStatusBarAppearance") as? Bool
        if infoValue == false {
            return
        }
        platformChannel?.invokeMethod("latestStyle", arguments: nil, result: { (result) in
            if (result == nil) {
                return
            }
            if (result is FlutterError) {
                return
            }
            if result as? NSObject == FlutterMethodNotImplemented {
                return
            }
            var statusBarStyle: UIStatusBarStyle?
            if let map = result as? Dictionary<String, Any> {
                let brightness = map["statusBarBrightness"] as? String
                if brightness == nil {
                    return
                }
                if brightness == "Brightness.dark" {
                    statusBarStyle = .lightContent
                } else if brightness == "Brightness.light" {
                    if #available(iOS 13, *) {
                        statusBarStyle = .darkContent
                    } else {
                        statusBarStyle = .default
                    }
                } else {
                    return
                }
            }
            guard let statusBarStyle = statusBarStyle else {
                return
            }
            callback(statusBarStyle)
        })
    }

    func detach() {
        navigationChannel?.setMethodCallHandler(nil)
        navigationChannel = nil
        notificationChannel?.setMethodCallHandler(nil)
        notificationChannel = nil
        platformChannel = nil
        engine?.viewController = nil
        engine?.destroyContext()
        engine = nil
    }
}