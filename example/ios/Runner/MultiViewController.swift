//
//  MultiViewController.swift
//  Runner
//
//  Created by gtbluesky on 2022/3/17.
//

import Foundation
import fusion

class MultiViewController: UITabBarController, FusionPopGestureHandler {

    override func viewDidLoad() {
        super.viewDidLoad()
//        tabBar.isTranslucent = false
        addChildVC(childVC: CustomViewController(routeName: "/test", routeArguments: ["title": "a"]), title: "消息")
        addChildVC(childVC: CustomViewController(routeName: "/lifecycle", routeArguments: ["title": "b"]), title: "我的")
    }

    private func addChildVC(childVC: FusionViewController, title: String) {
        tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], for: .highlighted)
        childVC.title = title
//        let nav = UINavigationController(rootViewController: childVC)
        addChild(childVC)
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

//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(false, animated: animated)
//    }
}
