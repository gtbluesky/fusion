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
    public private(set) var engineGroup: FlutterEngineGroup? = nil
    public private(set) var defaultEngine: FlutterEngine? = nil
    internal var engineBinding: FusionEngineBinding? = nil
    var delegate: FusionRouteDelegate? = nil

    private override init() {
        super.init()
    }

    @objc public func install(_ delegate: FusionRouteDelegate) {
        self.delegate = delegate
        engineGroup = FlutterEngineGroup(name: "fusion", project: nil)
        defaultEngine = createAndRunEngine(FusionConstant.REUSE_MODE)
        engineBinding = FusionEngineBinding(true)
        engineBinding?.attach()
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    @objc public func uninstall() {
        engineBinding?.detach()
        engineBinding = nil
        engineGroup = nil
        defaultEngine = nil
    }

    internal func createAndRunEngine(_ initialRoute: String = FusionConstant.INITIAL_ROUTE) -> FlutterEngine? {
        let engine = engineGroup?.makeEngine(withEntrypoint: nil, libraryURI: nil, initialRoute: initialRoute)
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
        engineBinding?.notifyPageVisible()
    }

    @objc func didEnterBackground() {
        FusionStackManager.instance.notifyEnterBackground()
        engineBinding?.notifyPageInvisible()
    }
}
