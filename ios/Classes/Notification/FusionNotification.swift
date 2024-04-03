//
//  FusionNotification.swift
//  fusion
//
// Created by gtbluesky on 2022/4/28.
//

import Foundation

@objc public protocol FusionNotificationListener {
    func onReceive(name: String, body: Dictionary<String, Any>?)
}

@objc public class FusionNotificationBinding: NSObject {
    private var listeners = [WeakReference<FusionNotificationListener>]()
    public static let instance = FusionNotificationBinding()

    private override init() {
        super.init()
    }

    public func register(_ listener: FusionNotificationListener) {
        unregister(listener)
        listeners.append(WeakReference(listener))
    }

    public func unregister(_ listener: FusionNotificationListener) {
        listeners.removeAll {
            ($0.value as AnyObject) === (listener as AnyObject) || $0.value == nil
        }
    }

    internal func dispatchMessage(_ name: String, _ body: Dictionary<String, Any>?) {
        listeners.forEach {
            $0.value?.onReceive(name: name, body: body)
        }
    }
}

@objc public enum FusionNotificationType: Int {
    case flutter
    case native
    case global
  }
