//
//  CustomFusionViewController.swift
//  Runner
//
//  Created by gtbluesky on 2022/3/14.
//

import Foundation
import Flutter
import fusion

class CustomFusionViewController: FusionViewController, FusionMessengerHandler, FusionPopGestureHandler {
//class CustomViewController: FusionViewController, FusionMessengerHandler, FusionPopGestureHandler, UIViewControllerRestoration {

    private var channel: FlutterMethodChannel? = nil

//    public class func viewController(withRestorationIdentifierPath identifierComponents: [String], coder: NSCoder) -> UIViewController? {
//        let vc = CustomViewController(coder: coder)
//        vc.restorationClass = self
//        vc.restorationIdentifier = identifierComponents.last
//        return vc
//    }

    override func viewDidLoad() {
        NSLog("\(self) func=\(#function)")
        super.viewDidLoad()
//        self.restorationClass = CustomViewController.self
//        self.restorationIdentifier = NSStringFromClass(CustomViewController.self)
    }

    override func viewWillAppear(_ animated: Bool) {
        NSLog("\(self) func=\(#function)")
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        NSLog("\(self) func=\(#function)")
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        NSLog("\(self) func=\(#function)")
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        NSLog("\(self) func=\(#function)")
        super.viewDidDisappear(animated)
    }

    func configureFlutterChannel(binaryMessenger: FlutterBinaryMessenger) {
        NSLog("\(self) configureFlutterChannel")
        channel = FlutterMethodChannel(name: "container_related_channel", binaryMessenger: binaryMessenger)
        channel?.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            result("container_related_channel: \(self)_\(call.method)")
        }
    }

    func releaseFlutterChannel() {
        NSLog("\(self) releaseFlutterChannel")
        channel?.setMethodCallHandler(nil)
        channel = nil
    }

    func enablePopGesture() {
        let nc = navigationController
        if nc == nil {
            return
        }
        if nc?.isNavigationBarHidden == false {
            return
        }
        nc?.addPopGesture()
    }

    func disablePopGesture() {
        let nc = navigationController
        if nc == nil {
            return
        }
        if nc?.isNavigationBarHidden == false {
            return
        }
        nc?.removePopGesture()
    }

    deinit {
        NSLog("\(self) deinit")
    }
}
