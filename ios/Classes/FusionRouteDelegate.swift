//
//  FusionRouteDelegate.swift
//  fusion
//
//  Created by gtbluesky on 2022/3/10.
//

import Foundation

@objc public protocol FusionRouteDelegate {
    func pushNativeRoute(name: String, args: Dictionary<String, Any>?)
    func pushFlutterRoute(name: String, args: Dictionary<String, Any>?)
}
