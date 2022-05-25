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


        super.init(engine: engineBinding!.engine!, nibName: nil, bundle: nil)

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

    open override func viewWillAppear(_ animated: Bool) {
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
        super.viewDidAppear(animated)
        if (isNested) {
            return
        }
        engineBinding?.notifyPageVisible()
        engineBinding?.addPopGesture()
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        (self as? FusionMessengerProvider)?.releaseFlutterChannel()
        if (isNested) {
            return
        }
        engineBinding?.notifyPageInvisible()
        engineBinding?.removePopGesture()
    }

    deinit {
        if isNested {
            history.removeAll()
        }
        engineBinding?.pop()
        engineBinding = nil
        if (isNested) {
            FusionStackManager.instance.removeChild()
        } else {
            FusionStackManager.instance.remove()
        }
    }
}