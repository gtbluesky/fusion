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
    private var channel: FlutterMethodChannel? = nil
    var engine: FlutterEngine? = nil
    private var eventChannel: FlutterEventChannel? = nil
    private var eventSink: FlutterEventSink? = nil
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
        channel = FlutterMethodChannel(name: FusionConstant.FUSION_CHANNEL, binaryMessenger: engine.binaryMessenger)
        eventChannel = FlutterEventChannel(name: FusionConstant.FUSION_EVENT_CHANNEL, binaryMessenger: engine.binaryMessenger)
    }

    func attach(_ container: FusionViewController? = nil) {
        self.container = container
        channel?.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
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
                    if self.container == nil || self.container?.history.isEmpty == true {
                        result(true)
                        self.detach()
                    } else {
                        // 在flutter页面中点击pop，仅关闭容器
                        FusionStackManager.instance.closeTopContainer()
                        result(false)
                    }
                } else {
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
            case "sendMessage":
                guard let dict = call.arguments as? Dictionary<String, Any>, let msgName = dict["msgName"] as? String else {
                    result(nil)
                    return
                }
                let msgBody = dict["msgBody"] as? Dictionary<String, Any>
                FusionStackManager.instance.sendMessage(msgName, msgBody)
                result(nil)
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
        eventChannel?.setStreamHandler(self)
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

    func push(_ name: String, _ arguments: Dictionary<String, Any>? = nil) {
        channel?.invokeMethod(
                "push",
                arguments: [
                    "name": name,
                    "arguments": arguments as Any
                ]
        )
    }

    func replace(_ name: String, _ arguments: Dictionary<String, Any>?) {
        channel?.invokeMethod(
                "replace",
                arguments: [
                    "name": name,
                    "arguments": arguments as Any
                ]
        )
    }

    func pop(_ active: Bool = false, _ result: Any? = nil) {
        channel?.invokeMethod(
                "pop",
                arguments: [
                    "active": active,
                    "result": result
                ]
        )
    }

    func remove(name: String) {
        channel?.invokeMethod(
                "remove",
                arguments: [
                    "name": name,
                ]
        )
    }

    func notifyPageVisible() {
        channel?.invokeMethod("notifyPageVisible", arguments: nil)
    }

    func notifyPageInvisible() {
        channel?.invokeMethod("notifyPageInvisible", arguments: nil)
    }

    func notifyEnterForeground() {
        channel?.invokeMethod("notifyEnterForeground", arguments: nil)
    }

    func notifyEnterBackground() {
        channel?.invokeMethod("notifyEnterBackground", arguments: nil)
    }

    func latestStyle(_ callback: @escaping (_ statusBarStyle: UIStatusBarStyle) -> Void) {
        let infoValue = Bundle.main.object(forInfoDictionaryKey: "UIViewControllerBasedStatusBarAppearance") as? Bool
        if infoValue == false {
            return
        }
        channel?.invokeMethod("latestStyle", arguments: nil, result: { (result) in
            if (result is FlutterError) {
                return
            }
            if result as? NSObject == FlutterMethodNotImplemented {
                return
            }
            var statusBarStyle: UIStatusBarStyle?;
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
        channel?.setMethodCallHandler(nil)
        channel = nil
        eventChannel?.setStreamHandler(nil)
        eventChannel = nil
        engine?.viewController = nil
        engine?.destroyContext()
        engine = nil
    }
}

extension FusionEngineBinding: FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }

    func sendMessage(_ msg: Dictionary<String, Any?>) {
        eventSink?(msg)
    }
}