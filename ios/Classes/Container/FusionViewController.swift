//
//  FusionViewController.swift
//  fusion
//
//  Created by gtbluesky on 2022/3/10.
//

import Flutter
import Foundation

open class FusionViewController: FlutterViewController {
    internal var history: [Dictionary<String, Any?>] = []
    internal var uniqueId = "container_\(UUID().uuidString)"
    private let engineBinding = Fusion.instance.engineBinding
    private var maskView: UIView? = nil
    private var backgroundColor: UIColor = .white
    
    private var isAttached: Bool {
        get {
            engineBinding?.engine?.viewController == self
        }
    }
    
    func removeMask() {
        maskView?.removeFromSuperview()
        maskView = nil
    }
    
    private func attachToContainer() {
        if !isAttached {
            // Attach
            engineBinding?.engine?.viewController = self
        }
        // Configure custom channel
        if let engine = engineBinding?.engine {
            (self as? FusionMessengerHandler)?.configureFlutterChannel(binaryMessenger: engine.binaryMessenger)
        }
    }

    private func detachFromContainer() {
        if isAttached {
            // Detach
            engineBinding?.engine?.viewController = nil
        }
        // Release custom channel
        (self as? FusionMessengerHandler)?.releaseFlutterChannel()
    }
    
    private func onContainerCreate() {
        if isViewOpaque {
            modalPresentationStyle = .fullScreen
            view.backgroundColor = backgroundColor
            maskView = UIView()
            if let maskView = maskView {
                maskView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                maskView.backgroundColor = backgroundColor
                view.addSubview(maskView)
            }
        } else {
            modalPresentationStyle = .overFullScreen
        }
        FusionStackManager.instance.add(self)
    }

    private func onContainerVisible() {
        FusionStackManager.instance.add(self)
        engineBinding?.switchTop(uniqueId)
        engineBinding?.notifyPageVisible(uniqueId)
        attachToContainer()
    }
    
    private func updateSystemOverlayStyle() {
        engineBinding?.checkStyle { statusBarStyle in
            NotificationCenter.default.post(name: .OverlayStyleUpdateNotificationName, object: nil, userInfo: [FusionConstant.OverlayStyleUpdateNotificationKey: statusBarStyle.rawValue])
        }
    }

    private func onContainerInvisible() {
        engineBinding?.notifyPageInvisible(uniqueId)
        detachFromContainer()
    }

    private func onContainerDestroy() {
        history.removeAll()
        FusionStackManager.instance.remove(self)
        engineBinding?.destroy(uniqueId)
    }

    public init(routeName: String, routeArguments: Dictionary<String, Any>?, transparent: Bool = false, backgroundColor: UIColor? = nil) {
        if let backgroundColor = backgroundColor {
            self.backgroundColor = backgroundColor
        }
        guard let engine = engineBinding?.engine else {
            super.init()
            return
        }
        engineBinding?.engine?.viewController = nil
        super.init(engine: engine, nibName: nil, bundle: nil)
        isViewOpaque = !transparent
        engineBinding?.open(uniqueId, name: routeName, arguments: routeArguments)
        onContainerCreate()
    }

    public convenience init(routeName: String, routeArguments: Dictionary<String, Any>?, transparent: Bool = false, backgroundColor: Int) {
        let alpha = CGFloat((backgroundColor & 0xFF000000) >> 24) / 255.0
        let red = CGFloat((backgroundColor & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((backgroundColor & 0xFF00) >> 8) / 255.0
        let blue = CGFloat(backgroundColor & 0xFF) / 255.0
        let bgColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        self.init(routeName: routeName, routeArguments: routeArguments, transparent: transparent, backgroundColor: bgColor)
    }

    public required init(coder: NSCoder) {
        guard let engine = engineBinding?.engine else {
            super.init()
            return
        }
        engineBinding?.engine?.viewController = nil
        super.init(engine: engine, nibName: nil, bundle: nil)
        isViewOpaque = coder.decodeBool(forKey: FusionConstant.FUSION_RESTORATION_OPAQUE_KEY)
        if let uniqueId = coder.decodeObject(forKey: FusionConstant.FUSION_RESTORATION_UNIQUE_ID_KEY) as? String {
            self.uniqueId = uniqueId
        }
        let classSet = [NSArray.self, NSDictionary.self, NSString.self, NSNumber.self]
        if let history = coder.decodeObject(of: classSet, forKey: FusionConstant.FUSION_RESTORATION_HISTORY_KEY) as? [Dictionary<String, Any?>] {
            engineBinding?.restore(uniqueId, history: history)
        }
        onContainerCreate()
    }

    open override func encodeRestorableState(with coder: NSCoder) {
        coder.encode(uniqueId, forKey: FusionConstant.FUSION_RESTORATION_UNIQUE_ID_KEY)
        coder.encode(history, forKey: FusionConstant.FUSION_RESTORATION_HISTORY_KEY)
        coder.encode(isViewOpaque, forKey: FusionConstant.FUSION_RESTORATION_OPAQUE_KEY)
        super.encodeRestorableState(with: coder)
    }

    open override func viewWillAppear(_ animated: Bool) {
        onContainerVisible()
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        viewDidLayoutSubviews()
    }

    open override func viewDidAppear(_ animated: Bool) {
        viewDidLayoutSubviews()
        updateSystemOverlayStyle()
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

    deinit {
        onContainerDestroy()
    }
}
