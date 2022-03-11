//
//  Fusion.swift
//  fusion
//
//  Created by gtbluesky on 2022/3/10.
//

import Foundation
import UIKit
public class Fusion {
    public static let instance = Fusion()
    let engineGroup = FlutterEngineGroup(name: "fusion", project: nil)
    var delegate: FusionRouteDelegate? = nil
    
    private init() {}
    
    public func install(delegate: FusionRouteDelegate) {
        self.delegate = delegate
    }
}
