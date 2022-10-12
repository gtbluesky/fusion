//
//  FusionViewController.swift
//  fusion
//
//  Created by gtbluesky on 2022/3/10.
//

import Foundation

open class FusionViewController: FlutterViewController {

    private var isReused = true
    internal var history: [Dictionary<String, Any?>] = []
    internal var engineBinding: FusionEngineBinding? = nil

    public init(isReused: Bool = true, routeName: String, routeArguments: Dictionary<String, Any>?) {
        self.isReused = isReused
        if isReused {
            engineBinding = Fusion.instance.engineBinding
        } else {
            engineBinding = FusionEngineBinding(false)
        }
        engineBinding?.engine?.viewController = nil
        super.init(engine: engineBinding!.engine!, nibName: nil, bundle: nil)
        if !isReused {
            engineBinding?.attach(self)
        }
        engineBinding?.push(routeName, routeArguments)
        if !isReused {
            FusionStackManager.instance.addChild(self)
        } else {
            FusionStackManager.instance.add(self)
        }
    }

    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func viewDidLoad() {
        if isReused {
            attachToFlutterEngine()
        }
        super.viewDidLoad()
        if isViewOpaque {
            self.view.backgroundColor = UIColor.white
        }
    }

    open override func viewWillAppear(_ animated: Bool) {
        if isReused {
            attachToFlutterEngine()
        }
        super.viewWillAppear(animated)
        if let engine = engineBinding?.engine {
            (self as? FusionMessengerHandler)?.configureFlutterChannel(binaryMessenger: engine.binaryMessenger)
        }
        if !isReused {
            return
        }
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    open override func viewDidAppear(_ animated: Bool) {
        if isReused {
            attachToFlutterEngine()
        }
        // 即使在UIViewController的viewDidAppear下，application也可能在inactive模式，此时如果提交渲染会导致GPU后台渲染而crash
        // https://github.com/flutter/flutter/issues/57973
        // https://github.com/flutter/engine/pull/18742
        if UIApplication.shared.applicationState == .active && isReused {
            surfaceUpdated(true)
        }
        super.viewDidAppear(animated)
        if (!isReused) {
            return
        }
        engineBinding?.notifyPageVisible()
        if history.count == 1 {
            engineBinding?.addPopGesture()
        } else {
            engineBinding?.removePopGesture()
        }
    }

    open override func didMove(toParent parent: UIViewController?) {
        // pop时调用
        if parent == nil && isReused {
            detachFromFlutterEngine()
        }
        super.didMove(toParent: parent)
    }

    open override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion:  {
            if let completion = completion {
                completion()
            }
            if self.isReused {
                self.detachFromFlutterEngine()
            }
        })
    }

    open override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.keyWindow?.endEditing(true)
        super.viewWillDisappear(animated)
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        (self as? FusionMessengerHandler)?.releaseFlutterChannel()
        if (!isReused) {
            return
        }
        engineBinding?.notifyPageInvisible()
    }

    private func attachToFlutterEngine() {
        if engine?.viewController == self {
            return
        }
        engine?.viewController = self
    }

    private func detachFromFlutterEngine() {
        if engine?.viewController != self {
            return
        }
        surfaceUpdated(false)
        engine?.viewController = nil
    }

    private func surfaceUpdated(_ appeared: Bool) {
        if engine?.viewController == self {
            let selector = NSSelectorFromString("surfaceUpdated:")
            if super.responds(to: selector) == true {
                super.perform(selector, with: appeared)
            }
        }
    }

    deinit {
        history.removeAll()
        if !isReused {
            FusionStackManager.instance.removeChild()
        } else {
            FusionStackManager.instance.remove()
        }
        engineBinding?.pop()
        engineBinding = nil
    }
}