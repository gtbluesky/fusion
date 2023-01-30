//
//  FusionMessengerHandler.swift
//  fusion
//
//  Created by gtbluesky on 2022/3/14.
//

import Flutter
import Foundation

@objc public protocol FusionMessengerHandler {
    func configureFlutterChannel(binaryMessenger: FlutterBinaryMessenger)
    func releaseFlutterChannel()
}
