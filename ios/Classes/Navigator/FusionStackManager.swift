//
//  FusionStackManager.swift
//  fusion
//
//  Created by gtbluesky on 2022/3/10.
//

import Foundation
import UIKit

class FusionStackManager {
    private var stack = [FusionPageModel]()
    static let instance = FusionStackManager()

    private init() {
    }

    private func getTopPage() -> FusionPageModel? {
        stack = stack.filter {
            $0.nativePage != nil
        }
        if stack.isEmpty {
            return nil
        }
        return stack.last
    }

    private func removeTopPage() {
        stack.removeLast()
    }

    func add(vc: UIViewController) {
        if !stack.map({ model in
                    model.nativePage
                })
                .contains(vc) {
            stack.append(FusionPageModel(vc))
        }
    }

    func push(name: String?, arguments: inout Dictionary<String, Any>?) {
        guard let name = name else {
            return
        }
        let mode = arguments?.removeValue(forKey: "fusion_push_mode") as? Int
        switch mode {
        case 0:
            Fusion.instance.delegate?.pushNativeRoute(name: name, arguments: arguments)
        case 1:
            Fusion.instance.delegate?.pushFlutterRoute(name: name, arguments: arguments)
        default:
            getTopPage()?.flutterPages.append(name)
        }
    }

    func pop() {
        let nativePage = UIApplication.topmostViewController
        if getTopPage()?.nativePage == nativePage && getTopPage()?.flutterPages.count ?? 0 > 1 {
            getTopPage()?.flutterPages.removeLast()
        } else {
            if getTopPage()?.nativePage == nativePage && getTopPage()?.flutterPages.count == 1 {
                removeTopPage()
            }
            let navigationController = nativePage?.navigationController
            if let count = navigationController?.viewControllers.count {
                if count > 1 {
                    navigationController?.popViewController(animated: true)
                }
            } else {
                nativePage?.dismiss(animated: true)
            }
        }
    }

    func notifyEnterForeground() {
        stack.forEach {
            if let nativePage = $0.nativePage as? FusionViewController {
                nativePage.engineBinding.notifyEnterForeground()
            }
        }
    }

    func notifyEnterBackground() {
        stack.forEach {
            if let nativePage = $0.nativePage as? FusionViewController {
                nativePage.engineBinding.notifyEnterBackground()
            }
        }
    }
}
