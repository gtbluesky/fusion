//
//  FusionNavigator.swift
//  fusion
//
//  Created by gtbluesky on 2022/3/10.
//

import Foundation
public class FusionNavigator {
    public static let instance = FusionNavigator()
    private init() {}
    
    public func push(name: String, arguments: Dictionary<String, Any>?) {
        Fusion.instance.delegate?.pushFlutterRoute(name: name, arguments: arguments)
    }
}
