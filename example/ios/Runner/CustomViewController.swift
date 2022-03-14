//
//  CustomViewController.swift
//  Runner
//
//  Created by gtbluesky on 2022/3/14.
//

import Foundation
import fusion
class CustomViewController : FusionViewController, EngineProvider {
    func onEngineCreated(engine: FlutterEngine) {
        print("CustomViewController,onEngineCreated")
    }
}
