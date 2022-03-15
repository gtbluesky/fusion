//
//  FusionViewController.swift
//  fusion
//
//  Created by gtbluesky on 2022/3/10.
//

import Foundation
open class FusionViewController: FlutterViewController {
    private let engineBinding: FusionEngineBinding
    
    public init(routeName: String, routeArguments: Dictionary<String, Any>?) {
        engineBinding = FusionEngineBinding(routeName: routeName, routeArguments: routeArguments)
        super.init(engine: engineBinding.engine, nibName: nil, bundle: nil)
        engineBinding.provideMessenger(vc: self)
    }
    
    public required init(coder aDecoder: NSCoder) {
        engineBinding = FusionEngineBinding(routeName: FusionConstant.INITIAL_ROUTE, routeArguments: nil)
        super.init(engine: engineBinding.engine, nibName: nil, bundle: nil)
        engineBinding.provideMessenger(vc: self)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        FusionStackManager.instance.add(vc: self)
    }
    
    deinit {
        engineBinding.detach()
    }
}
