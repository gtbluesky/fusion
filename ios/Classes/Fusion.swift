//
//  Fusion.swift
//  fusion
//
//  Created by gtbluesky on 2022/3/10.
//

import Foundation
import UIKit
@objc public class Fusion: NSObject {
    public static let instance = Fusion()
    let engineGroup = FlutterEngineGroup(name: "fusion", project: nil)
    var delegate: FusionRouteDelegate? = nil
    
    private override init() {
        super.init()
    }
    
    public func install(delegate: FusionRouteDelegate) {
        self.delegate = delegate
    }
}
