//
//  Fusion.swift
//  fusion
//
//  Created by gtbluesky on 2022/3/10.
//

import Foundation
import UIKit

public class Fusion: NSObject {
    @objc public static let instance = Fusion()
    private var engineGroup: FlutterEngineGroup? = nil
    internal var engineBinding: FusionEngineBinding? = nil
    var cachedEngine: FlutterEngine? = nil
    var delegate: FusionRouteDelegate? = nil
    public var adaptiveGesture: Bool = false

    private override init() {
        super.init()
    }

    @objc public func install(delegate: FusionRouteDelegate) {
        self.delegate = delegate
        engineGroup = FlutterEngineGroup(name: "fusion", project: nil)
        cachedEngine = createAndRunEngine()
        engineBinding = FusionEngineBinding(false)
        engineBinding?.attach()
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    @objc public func uninstall() {
        engineBinding?.detach()
        engineBinding = nil
        engineGroup = nil
        cachedEngine = nil
    }

    internal func createAndRunEngine() -> FlutterEngine? {
        let engine = engineGroup?.makeEngine(withEntrypoint: nil, libraryURI: nil)
        if let engine = engine {
            let clazz = NSClassFromString("GeneratedPluginRegistrant") as? NSObject.Type
            let selector = NSSelectorFromString("registerWithRegistry:")
            if clazz?.responds(to: selector) == true {
                clazz?.perform(selector, with: engine)
            }
        }
        return engine
    }

    /**
     应用首次启动不会收到该通知
     */
    @objc func willEnterForeground() {
        FusionStackManager.instance.notifyEnterForeground()
    }

    @objc func didEnterBackground() {
        FusionStackManager.instance.notifyEnterBackground()
    }
}
