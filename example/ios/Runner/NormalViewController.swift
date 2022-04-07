//
//  NormalViewController.swift
//  Runner
//
//  Created by gtbluesky on 2022/3/17.
//

import Foundation
class NormalViewController : UIViewController {
    private var button: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        button = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
        button?.center = view.center
        button?.setTitle("返回", for: .normal)
        button?.backgroundColor = UIColor.blue
        button?.addTarget(self, action: #selector(btnClick(btn:)), for: .touchUpInside)
        if let button = button {
            view.addSubview(button)
        }
    }
    
    @objc func btnClick(btn: UIButton) {
        if let count = navigationController?.viewControllers.count {
            print("count=\(count)")
        }
        if let count = navigationController?.viewControllers.count {
            if count > 1 {
                navigationController?.popViewController(animated: true)
            }
        } else {
            dismiss(animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
