//
//  FusionStackManager.swift
//  fusion
//
//  Created by gtbluesky on 2022/3/10.
//

import Foundation
import UIKit

class FusionStackManager {
    private var stack = [WeakReference<UIViewController>]()
    static let instance = FusionStackManager()

    private init() {
    }

    func add(_ vc: UIViewController) {
        stack.append(WeakReference(vc))
    }

    func remove() {
        stack.removeAll {
            $0.value == nil
        }
    }

    func closeTopContainer() {
        let vc = UIApplication.roofViewController
        let nc = vc?.navigationController
        if let count = nc?.viewControllers.count {
            if count > 1 {
                nc?.popViewController(animated: true)
            }
        } else {
            vc?.dismiss(animated: true)
        }
    }

    func notifyEnterForeground() {
        stack.forEach {
            if let vc = $0.value as? FusionViewController {
                vc.engineBinding.notifyEnterForeground()
            }
        }
    }

    func notifyEnterBackground() {
        stack.forEach {
            if let vc = $0.value as? FusionViewController {
                vc.engineBinding.notifyEnterBackground()
            }
        }
    }
}
