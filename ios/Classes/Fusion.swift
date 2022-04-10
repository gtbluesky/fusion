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
    let engineGroup = FlutterEngineGroup(name: "fusion", project: nil)
    var delegate: FusionRouteDelegate? = nil

    private override init() {
        super.init()
    }

    @objc public func install(delegate: FusionRouteDelegate) {
        self.delegate = delegate
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
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
