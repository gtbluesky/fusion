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
        if let engine = engineBinding?.engine {
            (self as? FusionMessengerHandler)?.configureFlutterChannel(binaryMessenger: engine.binaryMessenger)
        }
        if !isReused {
            engineBinding?.attach(self)
        }
        engineBinding?.push(routeName, arguments: routeArguments)
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
        super.viewDidLoad()
        if isViewOpaque {
            self.view.backgroundColor = UIColor.white
        }
    }

    open override func viewWillAppear(_ animated: Bool) {
        if isReused {
            attachToFlutterEngine()
            engineBinding?.latestStyle { statusBarStyle in
                NotificationCenter.default.post(name: .OverlayStyleUpdateNotificationName, object: nil, userInfo: [FusionConstant.OverlayStyleUpdateNotificationKey: statusBarStyle.rawValue])
            }
        }
        super.viewWillAppear(animated)
        if !isReused {
            return
        }
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    open override func viewDidAppear(_ animated: Bool) {
        if isReused {
            attachToFlutterEngine()
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
        super.didMove(toParent: parent)
        // parent == nil 为 pop
        // parent != nil 为 push
        if parent == nil && isReused {
            detachFromFlutterEngine()
        }
    }

    open override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: { [weak self] in
            if let completion = completion {
                completion()
            }
            if self?.isReused == true {
                self?.detachFromFlutterEngine()
            }
        })
    }

    open override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.keyWindow?.endEditing(true)
        super.viewWillDisappear(animated)
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if (!isReused) {
            return
        }
        engineBinding?.notifyPageInvisible()
    }

    private func attachToFlutterEngine() {
        if engineBinding?.engine?.viewController == self {
            return
        }
        engineBinding?.engine?.viewController = self
        if let engine = engineBinding?.engine {
            (self as? FusionMessengerHandler)?.configureFlutterChannel(binaryMessenger: engine.binaryMessenger)
        }
    }

    private func detachFromFlutterEngine() {
        if engineBinding?.engine?.viewController != self {
            return
        }
        engineBinding?.engine?.viewController = nil
        (self as? FusionMessengerHandler)?.releaseFlutterChannel()
    }

    private func destroy() {
        history.removeAll()
        if isReused {
            FusionStackManager.instance.remove(self)
        } else {
            (self as? FusionMessengerHandler)?.releaseFlutterChannel()
            FusionStackManager.instance.removeChild(self)
        }
        engineBinding?.pop()
        engineBinding = nil
    }

    deinit {
        destroy()
    }
}