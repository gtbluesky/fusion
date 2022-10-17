//
//  FusionConstant.swift
//  fusion
//
//  Created by gtbluesky on 2022/3/10.
//

import Foundation

internal struct FusionConstant {
    static let ROUTE_NAME = "ROUTE_NAME"
    static let ROUTE_ARGUMENTS = "ROUTE_ARGUMENTS"
    static let INITIAL_ROUTE = "/"
    static let FUSION_CHANNEL = "fusion_channel"
    static let FUSION_EVENT_CHANNEL = "fusion_event_channel"
    static let REUSE_MODE = "reuse_mode"
    static let OverlayStyleUpdateNotificationKey = "io.flutter.plugin.platform.SystemChromeOverlayNotificationKey"
}

internal extension NSNotification.Name {
    static let OverlayStyleUpdateNotificationName = NSNotification.Name("io.flutter.plugin.platform.SystemChromeOverlayNotificationName")
}