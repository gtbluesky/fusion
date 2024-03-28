//
//  MultiViewController.swift
//  Runner
//
//  Created by gtbluesky on 2022/3/17.
//

import Foundation
import fusion

class TabSceneController: UITabBarController, FusionPopGestureHandler {

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.isTranslucent = false
        addChildVC(childVC: CustomViewController(routeName: "/background", routeArgs: ["backgroundColor": 0xFF546E7A], backgroundColor: 0xFF546E7A), title: "主页")
        addChildVC(childVC: CustomViewController(routeName: "/lifecycle", routeArgs: ["title": "flutter1"]), title: "消息")
        addChildVC(childVC: CustomViewController(routeName: "/web", routeArgs: ["title": "flutter2"]), title: "我的")
    }

    private func addChildVC(childVC: FusionViewController, title: String) {
        tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], for: .highlighted)
        childVC.title = title
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
