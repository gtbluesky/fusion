import Flutter
import UIKit

public class SwiftFusionPlugin: NSObject, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "fusion", binaryMessenger: registrar.messenger())
        let instance = SwiftFusionPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "getPlatformVersion" {
            result("iOS: \(UIDevice.current.systemVersion)")
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
}
