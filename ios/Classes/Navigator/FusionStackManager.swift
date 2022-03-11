//
//  FusionStackManager.swift
//  fusion
//
//  Created by gtbluesky on 2022/3/10.
//

import Foundation
class FusionStackManager {
    static let instance = FusionStackManager()
    private init() {}
    
    func push(name: String?, arguments: Dictionary<String, Any>?) {
        if arguments?["flutter"] != nil {
            
        } else {
            Fusion.instance.delegate?.pushNativeRoute(name: name, arguments: arguments)
        }
    }
    
    func pop() {
        
    }
}
