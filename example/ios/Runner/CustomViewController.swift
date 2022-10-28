//
//  CustomViewController.swift
//  Runner
//
//  Created by gtbluesky on 2022/3/14.
//

import Foundation
import fusion

class CustomViewController: FusionViewController, FusionMessengerHandler, FusionPopGestureHandler {

    private var channel: FlutterMethodChannel? = nil

    func configureFlutterChannel(binaryMessenger: FlutterBinaryMessenger) {
        NSLog("\(self) configureFlutterChannel")
        channel = FlutterMethodChannel(name: "custom_channel", binaryMessenger: binaryMessenger)
        channel?.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            NSLog("Custom Channel：\(self)_\(call.method)")
        }
    }

    func releaseFlutterChannel() {
        NSLog("\(self) releaseFlutterChannel")
        channel?.setMethodCallHandler(nil)
        channel = nil
    }

    func enablePopGesture() {
        let nc = navigationController
        if nc == nil {
            return
        }
        if nc?.isNavigationBarHidden == false {
            return
        }
        nc?.addPopGesture()
    }

    func disablePopGesture() {
        let nc = navigationController
        if nc == nil {
            return
        }
        if nc?.isNavigationBarHidden == false {
            return
        }
        nc?.removePopGesture()
    }

    deinit {
        NSLog("\(self) deinit")
    }
}