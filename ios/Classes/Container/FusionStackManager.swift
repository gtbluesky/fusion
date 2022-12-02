//
//  FusionStackManager.swift
//  fusion
//
//  Created by gtbluesky on 2022/3/10.
//

import Foundation
import UIKit

internal class FusionStackManager {
    var containerStack = [WeakReference<FusionViewController>]()
    static let instance = FusionStackManager()

    private init() {
    }

    func add(_ container: FusionViewController) {
        remove(container)
        containerStack.append(WeakReference(container))
    }

    func remove(_ container: FusionViewController) {
        containerStack.removeAll {
            $0.value == container || $0.value == nil
        }
    }

    func getTopContainer() -> FusionViewController? {
        if containerStack.isEmpty {
            return  nil
        }
        return containerStack.last?.value
    }

    func findContainer(_ uniqueId: String) -> FusionViewController? {
        if uniqueId.isEmpty {
            return nil
        }
        for containerRef in containerStack {
            if containerRef.value?.uniqueId == uniqueId {
                return containerRef.value
            }
        }
        return nil
    }

    func closeContainer(_ container: FusionViewController) {
        let vc = container
        let nc = vc.navigationController
        if let count = nc?.viewControllers.count {
            if count > 1 {
                if (nc?.topViewController == vc) {
                    nc?.popViewController(animated: true)
                } else if nc?.viewControllers.contains(vc) == true {
                    vc.removeFromParent()
                }
            } else if count == 1 && nc?.presentingViewController != nil {
                nc?.dismiss(animated: vc.isViewOpaque)
            }
        } else {
            if vc.modalPresentationStyle == .overFullScreen || vc.modalPresentationStyle == .overCurrentContext {
                var nextVc = vc.presentingViewController
                if (nextVc is UINavigationController) {
                    nextVc = (nextVc as? UINavigationController)?.topViewController
                }
                if !(nextVc is FusionViewController) {
                    vc.dismiss(animated: vc.isViewOpaque)
                    return
                }
                nextVc?.beginAppearanceTransition(true, animated: false)
                vc.dismiss(animated: vc.isViewOpaque) {
                    nextVc?.endAppearanceTransition()
                }
            } else {
                vc.dismiss(animated: vc.isViewOpaque)
            }
        }
    }

    func notifyEnterForeground() {
        Fusion.instance.engineBinding?.notifyEnterForeground()
    }

    func notifyEnterBackground() {
        Fusion.instance.engineBinding?.notifyEnterBackground()
    }

    func sendMessage(_ name: String, body: Dictionary<String, Any>?) {
        // Native
        FusionNotificationBinding.instance.dispatchMessage(name, body: body)
        // Flutter
        let msg: Dictionary<String, Any?> = ["name": name, "body": body]
        Fusion.instance.engineBinding?.dispatchMessage(msg)
    }
}