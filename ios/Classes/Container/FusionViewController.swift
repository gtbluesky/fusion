//
//  FusionViewController.swift
//  fusion
//
//  Created by gtbluesky on 2022/3/10.
//

import Flutter
import Foundation
import ObjectiveC

private enum FusionViewControllerAssoc {
    static var history: UInt8 = 0
    static var uniqueId: UInt8 = 0
    static var backgroundColor: UInt8 = 0
    static var engineBinding: UInt8 = 0
}

extension FusionViewController {
    var history: [Dictionary<String, Any?>] {
        get {
            (objc_getAssociatedObject(self, &FusionViewControllerAssoc.history) as? [Dictionary<String, Any?>]) ?? []
        }
        set {
            objc_setAssociatedObject(self, &FusionViewControllerAssoc.history, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var uniqueId: String {
        get {
            if let value = objc_getAssociatedObject(self, &FusionViewControllerAssoc.uniqueId) as? String {
                return value
            }
            let value = "container_\(UUID().uuidString)"
            objc_setAssociatedObject(self, &FusionViewControllerAssoc.uniqueId, value, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            return value
        }
        set {
            objc_setAssociatedObject(self, &FusionViewControllerAssoc.uniqueId, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }

    private var fusionBackgroundColor: UIColor {
        get {
            (objc_getAssociatedObject(self, &FusionViewControllerAssoc.backgroundColor) as? UIColor) ?? .white
        }
        set {
            objc_setAssociatedObject(self, &FusionViewControllerAssoc.backgroundColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var engineBinding: FusionEngineBinding? {
        get {
            objc_getAssociatedObject(self, &FusionViewControllerAssoc.engineBinding) as? FusionEngineBinding
        }
        set {
            objc_setAssociatedObject(self, &FusionViewControllerAssoc.engineBinding, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var isAttached: Bool {
        engineBinding?.engine?.viewController == self
    }

    @objc static func fusionSharedEngine() -> FlutterEngine? {
        Fusion.instance.engineBinding?.engine
    }

    @objc static func fusionDetachSharedEngine() {
        Fusion.instance.engineBinding?.engine?.viewController = nil
    }

    public convenience init(routeName: String, routeArgs: Dictionary<String, Any>?, transparent: Bool = false, backgroundColor: UIColor? = nil) {
        self.init(__routeName: routeName, routeArgs: routeArgs, transparent: transparent, backgroundColor: backgroundColor)
    }

    @objc func fusion_completeInitWithRouteName(_ routeName: String, routeArgs: Dictionary<String, Any>?, transparent: Bool, backgroundColor: UIColor?) {
        engineBinding = Fusion.instance.engineBinding
        if let backgroundColor = backgroundColor {
            fusionBackgroundColor = backgroundColor
        }
        guard engineBinding?.engine != nil else {
            return
        }
        isViewOpaque = !transparent
        engineBinding?.create(uniqueId, name: routeName, args: routeArgs)
        onContainerCreate()
    }

    @nonobjc
    public convenience init(routeName: String, routeArgs: Dictionary<String, Any>?, transparent: Bool = false, backgroundColor: Int) {
        let alpha = CGFloat((backgroundColor & 0xFF000000) >> 24) / 255.0
        let red = CGFloat((backgroundColor & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((backgroundColor & 0xFF00) >> 8) / 255.0
        let blue = CGFloat(backgroundColor & 0xFF) / 255.0
        let bgColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        self.init(routeName: routeName, routeArgs: routeArgs, transparent: transparent, backgroundColor: bgColor)
    }

    @objc func fusion_decodeRestorableState(_ coder: NSCoder) {
        engineBinding = Fusion.instance.engineBinding
        isViewOpaque = coder.decodeBool(forKey: FusionConstant.FUSION_RESTORATION_OPAQUE_KEY)
        if let uniqueId = coder.decodeObject(forKey: FusionConstant.FUSION_RESTORATION_UNIQUE_ID_KEY) as? String {
            self.uniqueId = uniqueId
        }
        let classSet = [NSArray.self, NSDictionary.self, NSString.self, NSNumber.self]
        if let history = coder.decodeObject(of: classSet, forKey: FusionConstant.FUSION_RESTORATION_HISTORY_KEY) as? [Dictionary<String, Any?>] {
            engineBinding?.restore(uniqueId, history: history)
        }
    }

    @objc func fusion_encodeRestorableState(_ coder: NSCoder) {
        coder.encode(uniqueId, forKey: FusionConstant.FUSION_RESTORATION_UNIQUE_ID_KEY)
        coder.encode(history, forKey: FusionConstant.FUSION_RESTORATION_HISTORY_KEY)
        coder.encode(isViewOpaque, forKey: FusionConstant.FUSION_RESTORATION_OPAQUE_KEY)
    }

    private func attachToContainer() {
        if !isAttached {
            engineBinding?.engine?.viewController = self
        }
        if let engine = engineBinding?.engine {
            (self as? FusionMessengerHandler)?.configureFlutterChannel(binaryMessenger: engine.binaryMessenger)
        }
    }

    private func detachFromContainer() {
        if isAttached {
            engineBinding?.engine?.viewController = nil
        }
        (self as? FusionMessengerHandler)?.releaseFlutterChannel()
    }

    @objc func onContainerCreate() {
        if isViewOpaque {
            modalPresentationStyle = .fullScreen
            view.backgroundColor = fusionBackgroundColor
        } else {
            modalPresentationStyle = .overFullScreen
        }
        FusionStackManager.instance.add(self)
    }

    @objc func onContainerVisible() {
        FusionStackManager.instance.add(self)
        engineBinding?.switchTop(uniqueId) {
            self.attachToContainer()
            self.updateSystemOverlayStyle()
        }
        engineBinding?.notifyPageVisible(uniqueId)
        self.attachToContainer()
    }

    private func updateSystemOverlayStyle() {
        engineBinding?.checkStyle { statusBarStyle in
            NotificationCenter.default.post(
                name: .OverlayStyleUpdateNotificationName,
                object: nil,
                userInfo: [FusionConstant.OverlayStyleUpdateNotificationKey: statusBarStyle.rawValue]
            )
        }
    }

    @objc func onContainerInvisible() {
        engineBinding?.notifyPageInvisible(uniqueId)
        detachFromContainer()
    }

    @objc func onContainerDestroy() {
        FusionStackManager.instance.remove(self)
        engineBinding?.destroy(uniqueId)
    }
}
