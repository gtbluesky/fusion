//
//  CustomViewController.swift
//  Runner
//
//  Created by gtbluesky on 2022/3/14.
//

import Foundation
import fusion

class CustomViewController: FusionViewController, FusionMessengerProvider {

    private var channel: FlutterMethodChannel? = nil

    func configureFlutterChannel(binaryMessenger: FlutterBinaryMessenger) {
        print("\(self) configureFlutterChannel")
        channel = FlutterMethodChannel(name: "custom_channel", binaryMessenger: binaryMessenger)
        channel?.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            print("\(self)_call=\(call.method)")
        }
    }
    
    func releaseFlutterChannel() {
        print("\(self) releaseFlutterChannel")
        channel?.setMethodCallHandler(nil)
        channel = nil
    }

    deinit {
        print("\(self) deinit")
    }
}
