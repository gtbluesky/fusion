//
//  EngineProvider.swift
//  fusion
//
//  Created by gtbluesky on 2022/3/14.
//

import Foundation
public protocol EngineProvider {
    func onEngineCreated(engine: FlutterEngine)
}
