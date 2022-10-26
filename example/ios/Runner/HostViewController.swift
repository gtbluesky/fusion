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

    @IBOutlet weak var button0: UIButton!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    @IBAction func click0(_ sender: UIButton) {
        FusionNavigator.instance.open("/lifecycle", arguments: ["title": "iOS Flutter Page"])
    }

    @IBAction func click1(_ sender: Any) {
        FusionNavigator.instance.open("/transparent", arguments: ["title": "iOS Flutter Page", "transparent": true])
    }

    @IBAction func click2(_ sender: Any) {
        navigationController?.pushViewController(MultiViewController(), animated: true)
    }

    @IBAction func click3(_ sender: Any) {
        let fusionVc = CustomViewController(isReused: false, routeName: "/lifecycle", routeArguments: nil)
        presentLeftDrawer(fusionVc, animated: true)
    }
}

extension HostViewController: PageNotificationListener {
    public func onReceive(msgName: String, msgBody: Dictionary<String, Any>?) {
        print("onReceive: msgName=\(msgName), msgBody=\(msgBody)")
    }
}
