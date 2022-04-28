//
// Created by gtbluesky on 2022/4/28.
//

import Foundation

@objc public protocol FusionNotificationListener {
    func onReceive(msgName: String, msgBody: Dictionary<String, Any>?)
}
