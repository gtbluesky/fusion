//
//  EngineBinding.swift
//  fusion
//
//  Created by gtbluesky on 2022/3/10.
//

import Foundation

class FusionEngineBinding {
    private var channel: FlutterMethodChannel? = nil
    let engine: FlutterEngine
    private let childMode: Bool
    private var history: [Dictionary<String, Any?>] = []

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
        attach()
    }

    func provideMessenger(vc: FusionViewController) {
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
                }
                result(nil)
            case "pop":
                if self.history.count > 1 {
                    self.history.removeLast()
                    result(self.history)
                    self.addPopGesture()
                } else {
                    FusionStackManager.instance.closeTopContainer()
                    result(nil)
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
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
        channel?.invokeMethod("onPageVisible", arguments: nil)
    }

    func notifyPageInvisible() {
        channel?.invokeMethod("onPageInvisible", arguments: nil)
    }

    func notifyEnterForeground() {
        channel?.invokeMethod("onForeground", arguments: nil)
    }

    func notifyEnterBackground() {
        channel?.invokeMethod("onBackground", arguments: nil)
    }

    func detach() {
        channel?.setMethodCallHandler(nil)
        channel = nil
    }
}
