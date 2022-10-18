//
//  NormalViewController.swift
//  Runner
//
//  Created by gtbluesky on 2022/3/17.
//

import Foundation
import fusion

class NormalViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        newButton(button: UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50)), offsetY: 0, title: "返回", action: #selector(btnClick(btn:)))
        newButton(button: UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50)), offsetY: 60, title: "发送消息", action: #selector(btnClick2(btn:)))
        newButton(button: UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50)), offsetY: 120, title: "打开普通Flutter页面", action: #selector(btnClick3(btn:)))
        newButton(button: UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50)), offsetY: 180, title: "打开透明Flutter页面", action: #selector(btnClick4(btn:)))
    }

    private func newButton(button: UIButton, offsetY: Int, title: String, action: Selector) {
        button.center = CGPoint(x: view.center.x, y: view.center.y + CGFloat(offsetY))
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor.blue
        button.addTarget(self, action: action, for: .touchUpInside)
        view.addSubview(button)
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    @objc func btnClick(btn: UIButton) {
        if let count = navigationController?.viewControllers.count {
            if count > 1 {
                navigationController?.popViewController(animated: true)
            }
        } else {
            dismiss(animated: true)
        }
    }

    @objc func btnClick2(btn: UIButton) {
        FusionNavigator.instance.sendMessage("msg3", msgBody: ["time": "\(Int64(round(Date().timeIntervalSince1970 * 1000)))"])
    }

    @objc func btnClick3(btn: UIButton) {
        FusionNavigator.instance.open("/test", arguments: ["title": "New Flutter Page"])
    }

    @objc func btnClick4(btn: UIButton) {
        FusionNavigator.instance.open("/transparent", arguments: ["title": "Transparent Flutter Page", "transparent": true])
    }
}
