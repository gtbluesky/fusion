//
//  HostViewController.swift
//  Runner
//
//  Created by gtbluesky on 2022/3/10.
//

import Foundation
import UIKit
import fusion

class HostViewController: UIViewController {

    @IBOutlet weak var myButton: UIButton!

    @IBOutlet weak var button2: UIButton!


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }

    @IBAction func clickButton(_ sender: UIButton) {
        FusionNavigator.instance.push(name: "/test", arguments: ["title": "iOS Flutter Page"])
    }

    @IBAction func click2(_ sender: Any) {
        self.navigationController?.pushViewController(MultiViewController(), animated: true)
    }
}

extension HostViewController: PageNotificationListener {
    public func onReceive(msgName: String, msgBody: Dictionary<String, Any>?) {
        print("\(msgName), \(msgBody)")
    }
}
