//
//  FusionViewController.swift
//  fusion
//
//  Created by gtbluesky on 2022/3/10.
//

import Foundation

open class FusionViewController: FlutterViewController {

    private var isNested = false
    internal var history: [Dictionary<String, Any?>] = []
    internal var engineBinding: FusionEngineBinding? = nil

    public init(isNested: Bool = false, routeName: String, routeArguments: Dictionary<String, Any>?) {
        self.isNested = isNested
        if isNested {
            engineBinding = FusionEngineBinding(isNested)
        } else {
            engineBinding = Fusion.instance.engineBinding
        }
        engineBinding?.engine?.viewController = nil
        super.init(engine: engineBinding!.engine!, nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        if isNested {
            engineBinding?.attach(self)
        }
        engineBinding?.push(routeName, routeArguments)
        if isNested {
            FusionStackManager.instance.addChild(self)
        } else {
            FusionStackManager.instance.add(self)
        }
    }

    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func viewDidLoad() {
        if !isNested {
            attachToFlutterEngine()
        }
        super.viewDidLoad()
        if isViewOpaque {
            self.view.backgroundColor = UIColor.white
        }
    }

    open override func viewWillAppear(_ animated: Bool) {
        if !isNested {
            attachToFlutterEngine()
        }
        super.viewWillAppear(animated)
        if let engine = engineBinding?.engine {
            (self as? FusionMessengerProvider)?.configureFlutterChannel(binaryMessenger: engine.binaryMessenger)
        }
        if isNested {
            return
        }
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    open override func viewDidAppear(_ animated: Bool) {
        if !isNested {
            attachToFlutterEngine()
        }
        // 即使在UIViewController的viewDidAppear下，application也可能在inactive模式，此时如果提交渲染会导致GPU后台渲染而crash
        // https://github.com/flutter/flutter/issues/57973
        // https://github.com/flutter/engine/pull/18742
        if UIApplication.shared.applicationState == .active && !isNested {
            surfaceUpdated(true)
        }
        super.viewDidAppear(animated)
        if (isNested) {
            return
        }
        engineBinding?.notifyPageVisible()
        if history.count == 1 {
            engineBinding?.addPopGesture(self)
        } else {
            engineBinding?.removePopGesture()
        }
    }

    open override func didMove(toParent parent: UIViewController?) {
        // pop时调用
        if parent == nil && !isNested {
            detachFromFlutterEngine()
        }
        super.didMove(toParent: parent)
    }

    open override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion:  {
            if let completion = completion {
                completion()
            }
            if !self.isNested {
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
        (self as? FusionMessengerProvider)?.releaseFlutterChannel()
        if (isNested) {
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
        if isNested {
            history.removeAll()
            FusionStackManager.instance.removeChild()
        } else {
            FusionStackManager.instance.remove()
        }
        engineBinding?.pop()
        engineBinding = nil
    }
}