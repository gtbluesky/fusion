//
//  FusionEvent.swift
//  fusion
//
// Created by gtbluesky on 2022/4/28.
//

import Foundation

public typealias FusionEventCallback = @convention(block) (Dictionary<String, Any>?) -> Void

@objc public class FusionEventManager: NSObject {
    private var callbackMap = [String: [FusionEventCallback]]()
    public static let instance = FusionEventManager()

    private override init() {
        super.init()
    }

    public func register(_ event: String, callback: @escaping FusionEventCallback) {
        var callbacks = callbackMap[event] ?? []
        callbacks.append(callback)
        callbackMap[event] = callbacks
    }

    public func unregister(_ event: String, callback: FusionEventCallback? = nil) {
        if callback == nil {
            callbackMap.removeValue(forKey: event)
        } else {
            /// https://stackoverflow.com/questions/24111984/how-do-you-test-functions-and-closures-for-equality
            callbackMap[event]?.removeAll {
                unsafeBitCast($0, to: AnyObject.self) === unsafeBitCast(callback, to: AnyObject.self)
            }
        }
    }
    
    public func send(_ event: String, args: Dictionary<String, Any>? = nil, type: FusionEventType = .global) {
        switch type {
        case .flutter:
            Fusion.instance.engineBinding?.dispatchEvent(event, args)
        case .native:
            dispatchEvent(event, args)
        case .global:
            dispatchEvent(event, args)
            Fusion.instance.engineBinding?.dispatchEvent(event, args)
        }
    }

    private func dispatchEvent(_ name: String, _ args: Dictionary<String, Any>?) {
        let callbacks = callbackMap[name]
        guard let callbacks = callbacks else {
            return
        }
        callbacks.forEach {
            $0(args)
        }
     }
}

@objc public enum FusionEventType: Int {
    case flutter
    case native
    case global
  }
