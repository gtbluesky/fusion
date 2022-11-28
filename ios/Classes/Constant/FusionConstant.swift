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
    static let OverlayStyleUpdateNotificationKey = "io.flutter.plugin.platform.SystemChromeOverlayNotificationKey"
    static let FUSION_RESTORATION_HISTORY_KEY = "history"
    static let FUSION_RESTORATION_UNIQUE_ID_KEY = "uniqueId"
    static let FUSION_RESTORATION_OPAQUE_KEY = "opaque"
}

internal extension NSNotification.Name {
    static let OverlayStyleUpdateNotificationName = NSNotification.Name("io.flutter.plugin.platform.SystemChromeOverlayNotificationName")
}