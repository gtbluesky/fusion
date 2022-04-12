//
//  FusionViewController.swift
//  fusion
//
//  Created by gtbluesky on 2022/3/10.
//

import Foundation

open class FusionViewController: FlutterViewController {
    let engineBinding: FusionEngineBinding
    private var childMode = false

    public init(childMode: Bool = false, routeName: String, routeArguments: Dictionary<String, Any>?) {
        self.childMode = childMode
        self.engineBinding = FusionEngineBinding(childMode: childMode, routeName: routeName, routeArguments: routeArguments)
        super.init(engine: engineBinding.engine, nibName: nil, bundle: nil)
        self.engineBinding.provideMessenger(vc: self)
        if (!childMode) {
            FusionStackManager.instance.add(self)
        }
    }

    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (childMode) {
            return
        }
        engineBinding.notifyPageVisible()
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if (childMode) {
            return
        }
        engineBinding.notifyPageInvisible()
    }

    deinit {
        if (!childMode) {
            FusionStackManager.instance.remove()
        }
        engineBinding.detach()
    }
}
