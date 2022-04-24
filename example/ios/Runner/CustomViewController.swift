//
//  CustomViewController.swift
//  Runner
//
//  Created by gtbluesky on 2022/3/14.
//

import Foundation
import fusion

class CustomViewController: FusionViewController, FusionMessengerProvider {

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
    }

    func configureFlutterChannel(binaryMessenger: FlutterBinaryMessenger) {
        print("\(self) configureFlutterChannel")
    }

    deinit {
        print("\(self) deinit")
    }
}