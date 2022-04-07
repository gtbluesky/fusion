//
//  FusionNavigator.swift
//  fusion
//
//  Created by gtbluesky on 2022/3/10.
//

import Foundation

@objc public class FusionNavigator: NSObject {
    public static let instance = FusionNavigator()

    private override init() {
    }

    public func push(name: String, arguments: Dictionary<String, Any>?) {
        Fusion.instance.delegate?.pushFlutterRoute(name: name, arguments: arguments)
    }
}
