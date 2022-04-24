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

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @objc func btnClick(btn: UIButton) {
        if let count = navigationController?.viewControllers.count {
            if count > 1 {
                navigationController?.popViewController(animated: true)
            }
        } else {
            dismiss(animated: true)
        }
//        let alert = UIAlertController(title: "Hello!", message: "Message", preferredStyle: UIAlertController.Style.alert)
//        let alertAction = UIAlertAction(title: "OK!", style: UIAlertAction.Style.default)
//        alert.addAction(alertAction)
//        present(alert, animated: true)

//        let vc = MultiViewController()
//        vc.modalPresentationStyle = .fullScreen
//        present(vc, animated: true)
    }
}
