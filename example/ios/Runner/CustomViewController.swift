//
//  CustomViewController.swift
//  Runner
//
//  Created by gtbluesky on 2022/3/14.
//

import Foundation
import fusion
class CustomViewController : FusionViewController, FusionMessengerProvider {
    func configureFlutterChannel(binaryMessenger: FlutterBinaryMessenger) {
        print("CustomViewController, configureFlutterChannel")
        let channel = FlutterMethodChannel(name: "channel名", binaryMessenger: binaryMessenger)
        channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
   
        }
    }
}
