//
//  FusionEngineBinding.swift
//  fusion
//
//  Created by gtbluesky on 2022/3/10.
//

import Foundation

internal class FusionEngineBinding: NSObject {
    private var navigationChannel: FlutterMethodChannel? = nil
    private var notificationChannel: FlutterMethodChannel? = nil
    private var platformChannel: FlutterMethodChannel? = nil
    var engine: FlutterEngine? = nil
    private var historyList: [Dictionary<String, Any?>] {
        get {
            FusionStackManager.instance.containerStack.map {
                [
                    "uniqueId": $0.value?.uniqueId,
                    "history": $0.value?.history
                ]
            }
        }
    }

    init(_ engine: FlutterEngine?) {
        super.init()
        self.engine = engine;
        guard let engine = engine else {
            return
        }
        navigationChannel = FlutterMethodChannel(name: FusionConstant.FUSION_NAVIGATION_CHANNEL, binaryMessenger: engine.binaryMessenger)
        notificationChannel = FlutterMethodChannel(name: FusionConstant.FUSION_NOTIFICATION_CHANNEL, binaryMessenger: engine.binaryMessenger)
        platformChannel = FlutterMethodChannel(name: FusionConstant.FUSION_PLATFORM_CHANNEL, binaryMessenger: engine.binaryMessenger)
    }

    func attach() {
        navigationChannel?.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            switch call.method {
            case "open":
                guard let dict = call.arguments as? Dictionary<String, Any>, let name = dict["name"] as? String else {
                    result(nil)
                    return
                }
                let arguments = dict["arguments"] as? Dictionary<String, Any>
                Fusion.instance.delegate?.pushFlutterRoute(name: name, arguments: arguments)
                result(nil)
            case "push":
                guard let dict = call.arguments as? Dictionary<String, Any>, let name = dict["name"] as? String else {
                    result(nil)
                    return
                }
                let arguments = dict["arguments"] as? Dictionary<String, Any>
                Fusion.instance.delegate?.pushNativeRoute(name: name, arguments: arguments)
                result(nil)
            case "destroy":
                guard let dict = call.arguments as? Dictionary<String, Any>, let uniqueId = dict["uniqueId"] as? String else {
                    result(false)
                    return
                }
                if let container = FusionStackManager.instance.findContainer(uniqueId) {
                    FusionStackManager.instance.closeContainer(container)
                    result(true)
                } else {
                    result(false)
                }
            case "restore":
                result(self.historyList)
            case "sync":
                guard let dict = call.arguments as? Dictionary<String, Any>, let uniqueId = dict["uniqueId"] as? String, let pages = dict["pages"] as? [Dictionary<String, Any?>] else {
                    result(false)
                    return
                }
                let container = FusionStackManager.instance.findContainer(uniqueId)
                container?.history.removeAll()
                container?.history.append(contentsOf: pages)
                if container?.history.count == 1 {
                    self.enablePopGesture()
                } else {
                    self.disablePopGesture()
                }
                result(true)
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

    // external function
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

    func pop(_ result: Any?) {
        navigationChannel?.invokeMethod(
                "pop",
                arguments: [
                    "result": result
                ]
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

    // internal function
    func enablePopGesture() {
        (UIApplication.roofViewController as? FusionPopGestureHandler)?.enablePopGesture()
    }

    func disablePopGesture() {
        (UIApplication.roofViewController as? FusionPopGestureHandler)?.disablePopGesture()
    }

    func open(_ uniqueId: String, name: String, arguments: Dictionary<String, Any>?) {
        navigationChannel?.invokeMethod(
                "open",
                arguments: [
                    "uniqueId": uniqueId,
                    "name": name,
                    "arguments": arguments as Any
                ]
        )
    }

    func switchTop(_ uniqueId: String) {
        navigationChannel?.invokeMethod(
                "switchTop",
                arguments: [
                    "uniqueId": uniqueId
                ]
        )
    }

    /**
     Restore the specified container in flutter side
     - Parameters:
       - uniqueId: container's uniqueId
       - history: container's history
     */
    func restore(_ uniqueId: String, history: [Dictionary<String, Any?>]) {
        navigationChannel?.invokeMethod(
                "restore",
                arguments: [
                    "uniqueId": uniqueId,
                    "history": history
                ]
        )
    }

    /**
     Destroy the specified container in flutter side
     - Parameter uniqueId: container's uniqueId
     */
    func destroy(_ uniqueId: String) {
        navigationChannel?.invokeMethod(
                "destroy",
                arguments: [
                    "uniqueId": uniqueId
                ]
        )
    }

    func notifyPageVisible(_ uniqueId: String) {
        notificationChannel?.invokeMethod(
                "notifyPageVisible",
                arguments: [
                    "uniqueId": uniqueId
                ]
        )
    }

    func notifyPageInvisible(_ uniqueId: String) {
        notificationChannel?.invokeMethod(
                "notifyPageInvisible",
                arguments: [
                    "uniqueId": uniqueId
                ]
        )
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