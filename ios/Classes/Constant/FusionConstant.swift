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
    static let FUSION_NAVIGATION_CHANNEL = "fusion_navigation_channel"
    static let FUSION_NOTIFICATION_CHANNEL = "fusion_notification_channel"
    static let FUSION_PLATFORM_CHANNEL = "fusion_platform_channel"
    static let OverlayStyleUpdateNotificationKey = "io.flutter.plugin.platform.SystemChromeOverlayNotificationKey"
    static let FUSION_RESTORATION_HISTORY_KEY = "history"
    static let FUSION_RESTORATION_UNIQUE_ID_KEY = "uniqueId"
}

internal extension NSNotification.Name {
    static let OverlayStyleUpdateNotificationName = NSNotification.Name("io.flutter.plugin.platform.SystemChromeOverlayNotificationName")
}