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
        engineBinding = FusionEngineBinding(childMode: childMode, routeName: routeName, routeArguments: routeArguments)
        super.init(engine: engineBinding.engine, nibName: nil, bundle: nil)
        engineBinding.provideMessenger(vc: self)
    }

    public required init(coder aDecoder: NSCoder) {
        engineBinding = FusionEngineBinding(childMode: false, routeName: FusionConstant.INITIAL_ROUTE, routeArguments: nil)
        super.init(engine: engineBinding.engine, nibName: nil, bundle: nil)
        engineBinding.provideMessenger(vc: self)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        if (childMode) {
            return
        }
        FusionStackManager.instance.add(vc: self)
    }

    open override func viewDidAppear(_ animated: Bool) {
        if (childMode) {
            return
        }
        engineBinding.notifyPageVisible()
    }

    open override func viewDidDisappear(_ animated: Bool) {
        if (childMode) {
            return
        }
        engineBinding.notifyPageInvisible()
    }

    deinit {
        engineBinding.detach()
    }
}
