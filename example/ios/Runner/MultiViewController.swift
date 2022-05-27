//
//  MultiViewController.swift
//  Runner
//
//  Created by gtbluesky on 2022/3/17.
//

import Foundation
import fusion

class MultiViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        tabBar.isTranslucent = false
        addChildVC(childVC: CustomViewController(isNested: true, routeName: "/test", routeArguments: ["title": "a"]), title: "消息")
        addChildVC(childVC: CustomViewController(isNested: true, routeName: "/lifecycle", routeArguments: ["title": "b"]), title: "我的")
    }

    private func addChildVC(childVC: FusionViewController, title: String) {
        tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], for: .highlighted)
        childVC.title = title
//        let nav = UINavigationController(rootViewController: childVC)
        addChild(childVC)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
