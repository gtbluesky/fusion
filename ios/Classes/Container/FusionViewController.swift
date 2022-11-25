//
//  FusionViewController.swift
//  fusion
//
//  Created by gtbluesky on 2022/3/10.
//

import Foundation

open class FusionViewController: FlutterViewController {

    internal var history: [Dictionary<String, Any?>] = []
    internal var uniqueId = "container_\(UUID().uuidString)"
    private let engineBinding = Fusion.instance.engineBinding

    public init(routeName: String, routeArguments: Dictionary<String, Any>?) {
        engineBinding?.engine?.viewController = nil
        super.init(engine: engineBinding!.engine!, nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        engineBinding?.open(uniqueId, name: routeName, arguments: routeArguments)
        onContainerCreate()
    }

    public required init(coder: NSCoder) {
        engineBinding?.engine?.viewController = nil
        super.init(engine: engineBinding!.engine!, nibName: nil, bundle: nil)
        let classSet = [NSArray.self, NSDictionary.self, NSString.self, NSNumber.self]
        if let uniqueId = coder.decodeObject(forKey: FusionConstant.FUSION_RESTORATION_UNIQUE_ID_KEY) as? String {
            self.uniqueId = uniqueId
        }
        if let history = coder.decodeObject(of: classSet, forKey: FusionConstant.FUSION_RESTORATION_HISTORY_KEY) as? [Dictionary<String, Any?>] {
            self.history.append(contentsOf: history)
            engineBinding?.restore(uniqueId, history: history)
        }
        onContainerCreate()
    }

    open override func encodeRestorableState(with coder: NSCoder) {
        coder.encode(uniqueId, forKey: FusionConstant.FUSION_RESTORATION_UNIQUE_ID_KEY)
        coder.encode(history, forKey: FusionConstant.FUSION_RESTORATION_HISTORY_KEY)
        super.encodeRestorableState(with: coder)
    }

    open override func viewDidLoad() {
        attachToFlutterEngine()
        super.viewDidLoad()
        if isViewOpaque {
            self.view.backgroundColor = UIColor.white
        }
    }

    open override func viewWillAppear(_ animated: Bool) {
        onContainerVisible()
        engineBinding?.latestStyle { statusBarStyle in
            NotificationCenter.default.post(name: .OverlayStyleUpdateNotificationName, object: nil, userInfo: [FusionConstant.OverlayStyleUpdateNotificationKey: statusBarStyle.rawValue])
        }
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    open override func viewDidAppear(_ animated: Bool) {
        attachToFlutterEngine()
        super.viewDidAppear(animated)
    }

    open override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.keyWindow?.endEditing(true)
        super.viewWillDisappear(animated)
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onContainerInvisible()
    }

    private func attachToFlutterEngine() {
        if engineBinding?.engine?.viewController == self {
            return
        }
        engineBinding?.engine?.viewController = self
    }

    private func detachFromFlutterEngine() {
        if engineBinding?.engine?.viewController != self {
            return
        }
        engineBinding?.engine?.viewController = nil
    }

    func onContainerCreate() {

    }

    func onContainerVisible() {
        FusionStackManager.instance.add(self)
        engineBinding?.switchTop(uniqueId)
        engineBinding?.notifyPageVisible(uniqueId)
        attachToFlutterEngine()
        if let engine = engineBinding?.engine {
            (self as? FusionMessengerHandler)?.configureFlutterChannel(binaryMessenger: engine.binaryMessenger)
        }
    }

    func onContainerInvisible() {
        engineBinding?.notifyPageInvisible(uniqueId)
        detachFromFlutterEngine()
        (self as? FusionMessengerHandler)?.releaseFlutterChannel()
    }

    func onContainerDestroy() {
        history.removeAll()
        FusionStackManager.instance.remove(self)
        engineBinding?.destroy(uniqueId)
    }

    deinit {
        onContainerDestroy()
    }
}
