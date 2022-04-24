//
//  UIApplicationExtension.swift
//  fusion
//
//  Created by gtbluesky on 2022/3/18.
//

import Foundation

extension UIApplication {
    static var roofViewController: UIViewController? {
        let rootViewController = shared.delegate?.window??.rootViewController
        var roofViewController: UIViewController? = rootViewController
        while true {
            if roofViewController?.presentedViewController != nil {
                roofViewController = roofViewController?.presentedViewController
            } else if roofViewController is UINavigationController {
                let navigationBarController = roofViewController as? UINavigationController
                roofViewController = navigationBarController?.topViewController
            } else if roofViewController is UITabBarController {
                let tabBarController = roofViewController as? UITabBarController
                roofViewController = tabBarController?.selectedViewController
            } else if roofViewController == rootViewController && roofViewController?.children.isEmpty == false {
                roofViewController = roofViewController?.children.first
            } else {
                break
            }
        }
        return roofViewController
    }

    static var roofNavigationController: UINavigationController? {
        let rootViewController = shared.delegate?.window??.rootViewController
        var roofNavigationController: UINavigationController? = nil
        var roofViewController: UIViewController? = rootViewController
        while true {
            if roofViewController is UINavigationController {
                roofNavigationController = roofViewController as? UINavigationController
            }
            if roofViewController?.presentedViewController != nil {
                roofViewController = roofViewController?.presentedViewController
            } else if roofViewController is UITabBarController {
                let tabBarController = roofViewController as? UITabBarController
                roofViewController = tabBarController?.selectedViewController
            } else if roofViewController == rootViewController && roofViewController?.children.isEmpty == false {
                roofViewController = roofViewController?.children.first
            } else {
                break
            }
        }
        return roofNavigationController
    }
}
