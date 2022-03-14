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
    
    init(routeName: String, routeArguments: Dictionary<String, Any>?) {
        let initialRoute = FusionEngineBinding.convert2Uri(routeName, routeArguments)
        engine = Fusion.instance.engineGroup.makeEngine(withEntrypoint: nil, libraryURI: nil, initialRoute: initialRoute)
        channel = FlutterMethodChannel(name: FusionConstant.FUSION_CHANNEL, binaryMessenger: engine.binaryMessenger)
        attach()
    }
    
    func provideMessenger(vc: FusionViewController) {
        if let provider = vc as? FusionMessengerProvider {
            provider.configureFlutterChannel(binaryMessenger: engine.binaryMessenger)
        }
    }
    
    private static func convert2Uri(_ name: String, _ arguments: Dictionary<String, Any>?) -> String {
        let queryParameterArr = arguments?.map {(k:String,v:Any) -> String in
            return String(format:"%@=%@", k, String(describing: v))
        }
        if let queryParametersStr = queryParameterArr?.joined(separator: "&") {
            return String(describing: "\(name)?\(queryParametersStr)")
        } else {
            return name
        }
    }
    
    private func attach() {
        channel?.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            switch call.method {
                case "push":
                    if let dict = call.arguments as? Dictionary<String, Any> {
                        let name = dict["name"] as? String
                        let arguments = dict["arguments"] as? Dictionary<String, Any>
                        FusionStackManager.instance.push(name: name, arguments: arguments)
                    }
                    result(nil)
                case "pop":
                    FusionStackManager.instance.pop()
                    result(nil)
                default:
                    result(FlutterMethodNotImplemented)
            }
        }
    }
    
    func detach() {
        channel?.setMethodCallHandler(nil)
        channel = nil
    }
}
