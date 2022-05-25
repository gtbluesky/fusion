//
//  EngineBinding.swift
//  fusion
//
//  Created by gtbluesky on 2022/3/10.
//

import Foundation

class FusionEngineBinding: NSObject {
    private var channel: FlutterMethodChannel? = nil
    let engine: FlutterEngine
    private let childMode: Bool
    private var history: [Dictionary<String, Any?>] = []
    private var eventChannel: FlutterEventChannel? = nil
    private var events: FlutterEventSink? = nil

    init(childMode: Bool, routeName: String, routeArguments: Dictionary<String, Any>?) {
        self.childMode = childMode
        let uniqueId = UUID().uuidString
        let initialRoute = FusionEngineBinding.convert2Uri(uniqueId, routeName, routeArguments)
        history.append([
            "name": routeName,
            "arguments": routeArguments,
            "uniqueId": uniqueId
        ])
        engine = Fusion.instance.engineGroup.makeEngine(withEntrypoint: nil, libraryURI: nil, initialRoute: initialRoute)
        channel = FlutterMethodChannel(name: FusionConstant.FUSION_CHANNEL, binaryMessenger: engine.binaryMessenger)
        eventChannel = FlutterEventChannel(name: FusionConstant.FUSION_EVENT_CHANNEL, binaryMessenger: engine.binaryMessenger)
        super.init()
        attach()
    }

    func provideMessenger(_ vc: FusionViewController) {
        if let provider = vc as? FusionMessengerProvider {
            provider.configureFlutterChannel(binaryMessenger: engine.binaryMessenger)
        }
    }

    private static func convert2Uri(_ uniqueId: String, _ name: String, _ arguments: Dictionary<String, Any>?) -> String {
        var queryParameterArr = arguments?.map { (k: String, v: Any) -> String in
            String(format: "%@=%@", k, String(describing: v))
        } ?? []
        queryParameterArr.append(String(describing: "uniqueId=\(uniqueId)"))
        let queryParametersStr = queryParameterArr.joined(separator: "&")
        return String(describing: "\(name)?\(queryParametersStr)")
    }

    private func attach() {
        channel?.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            switch call.method {
            case "push":
                if let dict = call.arguments as? Dictionary<String, Any>, let name = dict["name"] as? String {
                    let arguments = dict["arguments"] as? Dictionary<String, Any>
                    let isFlutterPage = dict["isFlutterPage"] as? Bool ?? false
                    if isFlutterPage {
                        if self.childMode == true {
                            //在新Flutter容器打开Flutter页面
                            Fusion.instance.delegate?.pushFlutterRoute(name: name, arguments: arguments)
                            result(nil)
                        } else {
                            //在原Flutter容器打开Flutter页面
                            self.history.append([
                                "name": name,
                                "arguments": arguments,
                                "uniqueId": UUID().uuidString
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
            case "replace":
                if let dict = call.arguments as? Dictionary<String, Any>, let name = dict["name"] as? String {
                    let arguments = dict["arguments"] as? Dictionary<String, Any>
                    self.history.removeLast()
                    self.history.append([
                        "name": name,
                        "arguments": arguments,
                        "uniqueId": UUID().uuidString
                    ])
                    result(self.history)
                    self.removePopGesture()
                } else {
                    result(nil)
                }
            case "pop":
                if self.history.count > 1 {
                    self.history.removeLast()
                    result(self.history)
                    self.addPopGesture()
                } else {
                    FusionStackManager.instance.closeTopContainer()
                    result(nil)
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

    func addPopGesture() {
        if (childMode) {
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

    func removePopGesture() {
        if (childMode) {
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

    func detach() {
        channel?.setMethodCallHandler(nil)
        channel = nil
        eventChannel?.setStreamHandler(nil)
        eventChannel = nil
    }
}

extension FusionEngineBinding: FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.events = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        events = nil
        return nil
    }

    func sendMessage(_ msg: Dictionary<String, Any?>) {
        events?(msg)
    }
}