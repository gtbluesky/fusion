//
//  EngineBinding.swift
//  fusion
//
//  Created by gtbluesky on 2022/3/10.
//

import Foundation

class FusionEngineBinding: NSObject {
    private let isNested: Bool
    weak private var container: FusionViewController? = nil
    private var channel: FlutterMethodChannel? = nil
    var engine: FlutterEngine? = nil
    private var eventChannel: FlutterEventChannel? = nil
    private var eventSink: FlutterEventSink? = nil
    private var history: [Dictionary<String, Any?>] {
        get {
            FusionStackManager.instance.stack.flatMap {
                ($0.value)?.history ?? []
            }
        }
    }

    init(_ isNested: Bool) {
        self.isNested = isNested
        super.init()
        if (isNested) {
            engine = Fusion.instance.createAndRunEngine()
        } else {
            engine = Fusion.instance.cachedEngine
        }
        guard let engine = engine else {
            return
        }
        channel = FlutterMethodChannel(name: FusionConstant.FUSION_CHANNEL, binaryMessenger: engine.binaryMessenger)
        eventChannel = FlutterEventChannel(name: FusionConstant.FUSION_EVENT_CHANNEL, binaryMessenger: engine.binaryMessenger)
    }

    internal func attach(_ container: FusionViewController? = nil) {
        self.container = container
        channel?.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            switch call.method {
            case "push":
                if let dict = call.arguments as? Dictionary<String, Any>, let name = dict["name"] as? String {
                    let arguments = dict["arguments"] as? Dictionary<String, Any>
                    let isFlutterPage = dict["isFlutterPage"] as? Bool ?? false
                    if isFlutterPage {
                        if self.isNested == true {
                            if self.container?.history.isEmpty == true {
                                //在原Flutter容器打开Flutter页面
                                //即用户可见的第一个页面
                                self.container?.history.append([
                                    "name": name,
                                    "arguments": arguments,
                                    "uniqueId": UUID().uuidString,
                                    "isFirstPage": true
                                ])
                                result(self.container?.history)
                            } else {
                                //在新Flutter容器打开Flutter页面
                                Fusion.instance.delegate?.pushFlutterRoute(name: name, arguments: arguments)
                                result(nil)
                            }
                        } else {
                            //在原Flutter容器打开Flutter页面
                            let topContainer = UIApplication.roofViewController as? FusionViewController
                            let isFirstPage = topContainer?.history.isEmpty ?? false
                            topContainer?.history.append([
                                "name": name,
                                "arguments": arguments,
                                "uniqueId": UUID().uuidString,
                                "isFirstPage": isFirstPage
                            ])
                            result(self.history)
                            self.removePopGesture()
                        }
                    } else {
                        //打开Native页面
                        Fusion.instance.delegate?.pushNativeRoute(name: name, arguments: arguments)
                        result(nil)
                    }
                } else {
                    result(nil)
                }
            case "pop":
                if self.isNested {
                    if self.container == nil || self.container?.history.isEmpty == true {
                        result(nil)
                        self.detach()
                    } else {
                        // 在flutter页面中点击pop
                        FusionStackManager.instance.closeTopContainer()
                        result(self.container?.history)
                    }
                } else {
                    // 1、flutter容器退出
                    // 2、flutter页面pop
                    // 3、flutter容器退出后仅刷新history
                    if let topContainer = UIApplication.roofViewController as? FusionViewController {
                        if topContainer.history.count == 1 {
                            FusionStackManager.instance.closeTopContainer()
                        } else {
                            topContainer.history.removeLast()
                            self.addPopGesture()
                        }
                    }
                    result(self.history)
                }
            case "sendMessage":
                if let dict = call.arguments as? Dictionary<String, Any>, let msgName = dict["msgName"] as? String {
                    let msgBody = dict["msgBody"] as? Dictionary<String, Any>
                    FusionStackManager.instance.sendMessage(msgName, msgBody)
                }
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        eventChannel?.setStreamHandler(self)
    }

    internal func addPopGesture() {
        if (isNested) {
            return
        }
        if !Fusion.instance.adaptiveGesture {
            return
        }
        if history.count > 1 {
            return
        }
        let vc = UIApplication.roofViewController
        if !(vc is FusionViewController) {
            return
        }
        let nc = vc?.navigationController
        if nc == nil {
            return
        }
        if nc?.isNavigationBarHidden == false {
            return
        }
        nc?.addPopGesture()
    }

    internal func removePopGesture() {
        if (isNested) {
            return
        }
        if !Fusion.instance.adaptiveGesture {
            return
        }
        let vc = UIApplication.roofViewController
        let nc = vc?.navigationController
        if nc == nil {
            return
        }
        if nc?.isNavigationBarHidden == false {
            return
        }
        nc?.removePopGesture()
    }

    internal func push(_ name: String, _ arguments: Dictionary<String, Any>? = nil) {
        channel?.invokeMethod(
                "push",
                arguments: [
                    "name": name,
                    "arguments": arguments as Any
                ]
        )
    }

    internal func pop() {
        channel?.invokeMethod("pop", arguments: nil)
    }

    internal func notifyPageVisible() {
        channel?.invokeMethod("notifyPageVisible", arguments: nil)
    }

    internal func notifyPageInvisible() {
        channel?.invokeMethod("notifyPageInvisible", arguments: nil)
    }

    internal func notifyEnterForeground() {
        channel?.invokeMethod("notifyEnterForeground", arguments: nil)
    }

    internal func notifyEnterBackground() {
        channel?.invokeMethod("notifyEnterBackground", arguments: nil)
    }

    internal func detach() {
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