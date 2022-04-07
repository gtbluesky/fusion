//
//  MultiViewController.swift
//  Runner
//
//  Created by gtbluesky on 2022/3/17.
//

import Foundation
import fusion
class MultiViewController : UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        tabBar.isTranslucent = false
        addChildVC(childVC: FusionViewController(childMode: true, routeName: "/test", routeArguments: ["title": "a"]), title: "消息")
        addChildVC(childVC: FusionViewController(childMode: true, routeName: "/list", routeArguments: ["title": "b"]), title: "我的")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func addChildVC(childVC: UIViewController, title: String) {
        tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.red], for: .highlighted)
        childVC.title = title
//        let nav = UINavigationController(rootViewController: childVC)
        addChild(childVC)
    }
}
