//
//  FusionExt.swift
//  fusion
//
//  Created by gtbluesky on 2022/3/18.
//

import Foundation

public extension UIApplication {
    static var topmostViewController: UIViewController? {
        var topmostViewController: UIViewController? = shared.delegate?.window??.rootViewController
        while true {
            if topmostViewController?.presentedViewController != nil {
                topmostViewController = topmostViewController?.presentedViewController
            } else if topmostViewController is UINavigationController {
                let navigationBarController = topmostViewController as? UINavigationController
                topmostViewController = navigationBarController?.topViewController
            } else if topmostViewController is UITabBarController {
                let tabBarController = topmostViewController as? UITabBarController
                topmostViewController = tabBarController?.selectedViewController
            } else {
                break
            }
        }
        return topmostViewController
    }

    static var topmostNavigationController: UINavigationController? {
        var topmostNavigationController: UINavigationController? = nil
        var topmostViewController: UIViewController? = shared.delegate?.window??.rootViewController
        while true {
            if topmostViewController is UINavigationController {
                topmostNavigationController = topmostViewController as? UINavigationController
            }
            if topmostViewController?.presentedViewController != nil {
                topmostViewController = topmostViewController?.presentedViewController
            } else if topmostViewController is UITabBarController {
                let tabBarController = topmostViewController as? UITabBarController
                topmostViewController = tabBarController?.selectedViewController
            } else {
                break
            }
        }
        return topmostNavigationController
    }
}
