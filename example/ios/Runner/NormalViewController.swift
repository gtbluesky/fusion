//
//  NormalViewController.swift
//  Runner
//
//  Created by gtbluesky on 2022/3/17.
//

import Foundation
import fusion

class NormalViewController: UIViewController {
    private var button: UIButton?
    private var button2: UIButton?
    private var button3: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        button?.center = view.center
        button?.setTitle("返回", for: .normal)
        button?.backgroundColor = UIColor.blue
        button?.addTarget(self, action: #selector(btnClick(btn:)), for: .touchUpInside)
        if let button = button {
            view.addSubview(button)
        }

        button2 = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        button2?.center = CGPoint(x: view.center.x, y: view.center.y + 60)
        button2?.setTitle("发送消息", for: .normal)
        button2?.backgroundColor = UIColor.gray
        button2?.addTarget(self, action: #selector(btnClick2(btn:)), for: .touchUpInside)
        if let button = button2 {
            view.addSubview(button)
        }

        button3 = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        button3?.center = CGPoint(x: view.center.x, y: view.center.y + 120)
        button3?.setTitle("打开Flutter页面", for: .normal)
        button3?.backgroundColor = UIColor.gray
        button3?.addTarget(self, action: #selector(btnClick3(btn:)), for: .touchUpInside)
        if let button = button3 {
            view.addSubview(button)
        }
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
        FusionNavigator.instance.sendMessage(msgName: "msg3", msgBody: ["time": "\(Int64(round(Date().timeIntervalSince1970 * 1000)))"])
    }

    @objc func btnClick3(btn: UIButton) {
        FusionNavigator.instance.open(name: "/test", arguments: ["title": "New Flutter Page"])
    }
}
