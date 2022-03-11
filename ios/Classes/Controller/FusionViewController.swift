//
//  FusionViewController.swift
//  fusion
//
//  Created by gtbluesky on 2022/3/10.
//

import Foundation
public class FusionViewController: FlutterViewController {
    private let engineBinding: EngineBinding
    
    public init(routeName: String, routeArguments: Dictionary<String, Any>?) {
        engineBinding = EngineBinding(routeName: routeName, routeArguments: routeArguments)
        super.init(engine: engineBinding.engine, nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        engineBinding = EngineBinding(routeName: FusionConstant.INITIAL_ROUTE, routeArguments: nil)
        super.init(engine: engineBinding.engine, nibName: nil, bundle: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        engineBinding.attach()
    }
    
    deinit {
        engineBinding.detach()
    }
}
