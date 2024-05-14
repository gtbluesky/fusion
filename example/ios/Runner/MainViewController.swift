//
//  MainViewController.swift
//  Runner
//
//  Created by gtbluesky on 2024/4/9.
//

import Foundation
import fusion

class MainViewController: UIViewController {
//class MainViewController: UIViewController, FusionNotificationListener, UIViewControllerRestoration {
    
    //    class func viewController(withRestorationIdentifierPath identifierComponents: [String], coder: NSCoder) -> UIViewController? {
    //        let vc = MainViewController()
    //        vc.restorationClass = self
    //        vc.restorationIdentifier = identifierComponents.last
    //        return vc
    //    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.restorationClass = MainViewController.self
//        self.restorationIdentifier = NSStringFromClass(MainViewController.self)
        view.backgroundColor = .white
        newButton(button: UIButton(), offsetY: -75, title: "Flutter普通页面场景", action: #selector(click0(btn:)))
        newButton(button: UIButton(), offsetY: -25, title: "Flutter透明页面场景", action: #selector(click1(btn:)))
        newButton(button: UIButton(), offsetY: 25, title: "Flutter子页面场景", action: #selector(click2(btn:)))
        newButton(button: UIButton(), offsetY: 75, title: "Native侧边栏嵌入Flutter场景", action: #selector(click3(btn:)))
        FusionEventManager.instance.register("custom_event", callback: onReceive)
    }
    
//    lazy var onReceive: FusionEventCallback = onReceiveFunc
//    
//    public func onReceiveFunc(args: Dictionary<String, Any>?) {
//        NSLog("onReceive: args=\(String(describing: args))")
//    }
    
    let onReceive: FusionEventCallback = { args in
        NSLog("onReceive: args=\(String(describing: args))")
    }

    private func newButton(button: UIButton, offsetY: CGFloat, title: String, action: Selector) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.sizeToFit()
        button.center = CGPoint(x: view.center.x, y: view.center.y + offsetY)
        button.addTarget(self, action: action, for: .touchUpInside)
        view.addSubview(button)
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    @IBAction func click0(btn: UIButton) {
        FusionNavigator.push(
            "/index",
            routeArgs: ["title": "iOS Flutter Page"],
            routeType: .adaption
        )
    }

    @IBAction func click1(btn: Any) {
        FusionNavigator.push(
            "/transparent",
            routeArgs: ["title": "iOS Flutter Page", "transparent": true],
            routeType: .flutterWithContainer
        )
    }

    @IBAction func click2(btn: Any) {
        FusionNavigator.push(
            "/native_tab_fixed",
            routeType: .native
        )
    }

    @IBAction func click3(btn: Any) {
        FusionEventManager.instance.unregister("custom_event", callback: onReceive)

//        let fusionVc = CustomFusionViewController(
//            routeName: "/lifecycle", routeArgs: nil
//        )
//        presentLeftDrawer(fusionVc, animated: true)
    }
    
    deinit {
        FusionEventManager.instance.unregister("custom_event")
    }
}

