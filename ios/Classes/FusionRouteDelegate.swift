//
//  FusionRouteDelegate.swift
//  fusion
//
//  Created by gtbluesky on 2022/3/10.
//

import Foundation
@objc public protocol FusionRouteDelegate {
    func pushNativeRoute(name: String?, arguments: Dictionary<String, Any>?)
    func pushFlutterRoute(name: String?, arguments: Dictionary<String, Any>?)
}
