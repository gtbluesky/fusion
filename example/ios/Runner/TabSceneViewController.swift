//
//  TabSceneViewController.swift
//  Runner
//
//  Created by gtbluesky on 2022/3/17.
//

import Foundation
import fusion

class TabSceneViewController: UITabBarController, FusionPopGestureHandler {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.isTranslucent = false
        addChildVC(
            childVC: CustomFusionViewController(
                routeName: "/background",
                routeArgs: [
                    "title": "Flutter Tab0",
                    "backgroundColor": 0xFF546E7A
                ],
                backgroundColor: 0xFF546E7A
            ),
            title: "Tab0"
        )
        addChildVC(
            childVC: FusionViewController(
                routeName: "/lifecycle",
                routeArgs: ["title": "Flutter Tab1"]
            ),
            title: "Tab1"
        )
        addChildVC(
            childVC: FusionViewController(
                routeName: "/web",
                routeArgs: ["title": "Flutter Tab2"]
            ),
            title: "Tab2"
        )
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
