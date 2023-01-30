import Flutter
import UIKit

public class FusionPlugin: NSObject, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "fusion", binaryMessenger: registrar.messenger())
        let instance = FusionPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "getPlatformVersion" {
            result("Fusion Channel, iOS: \(UIDevice.current.systemVersion)")
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
}
