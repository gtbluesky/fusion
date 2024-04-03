//
//  HostViewController.swift
//  Runner
//
//  Created by gtbluesky on 2022/3/10.
//

import UIKit
import fusion

class HostViewController: UIViewController, FusionNotificationListener {
//class HostViewController: UIViewController, UIViewControllerRestoration {

    @IBOutlet weak var button0: UIButton!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!

    override func viewDidLoad() {
        NSLog("\(self) func=\(#function)")
        super.viewDidLoad()
//        self.restorationClass = HostViewController.self
//        self.restorationIdentifier = NSStringFromClass(HostViewController.self)
        FusionNotificationBinding.instance.register(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        NSLog("\(self) func=\(#function)")
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

//    class func viewController(withRestorationIdentifierPath identifierComponents: [String], coder: NSCoder) -> UIViewController? {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "HostVC")
//        vc.restorationClass = self
//        vc.restorationIdentifier = identifierComponents.last
//        return vc
//    }

    @IBAction func click0(_ sender: UIButton) {
        FusionNavigator.push(
            "/index",
            routeArgs: ["title": "iOS Flutter Page"],
            routeType: .adaption
        )
    }

    @IBAction func click1(_ sender: Any) {
        FusionNavigator.push(
            "/transparent",
            routeArgs: ["title": "iOS Flutter Page", "transparent": true],
            routeType: .flutterWithContainer
        )
    }

    @IBAction func click2(_ sender: Any) {
        FusionNavigator.push(
            "/native_tab_scene",
            routeType: .native
        )
    }

    @IBAction func click3(_ sender: Any) {
        let fusionVc = CustomFusionViewController(
            routeName: "/lifecycle", routeArgs: nil
        )
        presentLeftDrawer(fusionVc, animated: true)
    }
    
    public func onReceive(name: String, body: Dictionary<String, Any>?) {
        NSLog("onReceive: name=\(name), body=\(String(describing: body))")
    }
    
    deinit {
        FusionNotificationBinding.instance.unregister(self)
    }
}
