//
//  FusionEngineBinding.swift
//  fusion
//
//  Created by gtbluesky on 2022/3/10.
//

import Flutter
import Foundation

internal class FusionEngineBinding: NSObject {
    private var hostPush: FlutterBasicMessageChannel? = nil
    private var hostDestroy: FlutterBasicMessageChannel? = nil
    private var hostRestore: FlutterBasicMessageChannel? = nil
    private var hostSync: FlutterBasicMessageChannel? = nil
    private var hostDispatchEvent: FlutterBasicMessageChannel? = nil
    private var hostRemoveMaskView: FlutterBasicMessageChannel? = nil
    private var flutterCreate: FlutterBasicMessageChannel? = nil
    private var flutterSwitchTop: FlutterBasicMessageChannel? = nil
    private var flutterRestore: FlutterBasicMessageChannel? = nil
    private var flutterDestroy: FlutterBasicMessageChannel? = nil
    private var flutterPush: FlutterBasicMessageChannel? = nil
    private var flutterReplace: FlutterBasicMessageChannel? = nil
    private var flutterPop: FlutterBasicMessageChannel? = nil
    private var flutterMaybePop: FlutterBasicMessageChannel? = nil
    private var flutterRemove: FlutterBasicMessageChannel? = nil
    private var flutterNotifyPageVisible: FlutterBasicMessageChannel? = nil
    private var flutterNotifyPageInvisible: FlutterBasicMessageChannel? = nil
    private var flutterNotifyEnterForeground: FlutterBasicMessageChannel? = nil
    private var flutterNotifyEnterBackground: FlutterBasicMessageChannel? = nil
    private var flutterDispatchEvent: FlutterBasicMessageChannel? = nil
    private var flutterCheckStyle: FlutterBasicMessageChannel? = nil

    var engine: FlutterEngine? = nil

    private var historyList: [Dictionary<String, Any?>] {
        get {
            FusionStackManager.instance.containerStack.map {
                [
                    "uniqueId": $0.value?.uniqueId,
                    "history": $0.value?.history
                ]
            }
        }
    }

    init(_ engine: FlutterEngine?) {
        super.init()
        self.engine = engine;
        guard let engine = engine else {
            return
        }
        let binaryMessenger = engine.binaryMessenger
        hostPush = FlutterBasicMessageChannel(name: "\(FusionConstant.FUSION_CHANNEL)/host/push", binaryMessenger: binaryMessenger)
        hostDestroy = FlutterBasicMessageChannel(name: "\(FusionConstant.FUSION_CHANNEL)/host/destroy", binaryMessenger: binaryMessenger)
        hostRestore = FlutterBasicMessageChannel(name: "\(FusionConstant.FUSION_CHANNEL)/host/restore", binaryMessenger: binaryMessenger)
        hostSync = FlutterBasicMessageChannel(name: "\(FusionConstant.FUSION_CHANNEL)/host/sync", binaryMessenger: binaryMessenger)
        hostDispatchEvent = FlutterBasicMessageChannel(name: "\(FusionConstant.FUSION_CHANNEL)/host/dispatchEvent", binaryMessenger: binaryMessenger)
        hostRemoveMaskView = FlutterBasicMessageChannel(name: "\(FusionConstant.FUSION_CHANNEL)/host/removeMaskView", binaryMessenger: binaryMessenger)
        flutterCreate = FlutterBasicMessageChannel(name: "\(FusionConstant.FUSION_CHANNEL)/flutter/create", binaryMessenger: binaryMessenger)
        flutterSwitchTop = FlutterBasicMessageChannel(name: "\(FusionConstant.FUSION_CHANNEL)/flutter/switchTop", binaryMessenger: binaryMessenger)
        flutterRestore = FlutterBasicMessageChannel(name: "\(FusionConstant.FUSION_CHANNEL)/flutter/restore", binaryMessenger: binaryMessenger)
        flutterDestroy = FlutterBasicMessageChannel(name: "\(FusionConstant.FUSION_CHANNEL)/flutter/destroy", binaryMessenger: binaryMessenger)
        flutterPush = FlutterBasicMessageChannel(name: "\(FusionConstant.FUSION_CHANNEL)/flutter/push", binaryMessenger: binaryMessenger)
        flutterReplace = FlutterBasicMessageChannel(name: "\(FusionConstant.FUSION_CHANNEL)/flutter/replace", binaryMessenger: binaryMessenger)
        flutterPop = FlutterBasicMessageChannel(name: "\(FusionConstant.FUSION_CHANNEL)/flutter/pop", binaryMessenger: binaryMessenger)
        flutterMaybePop = FlutterBasicMessageChannel(name: "\(FusionConstant.FUSION_CHANNEL)/flutter/maybePop", binaryMessenger: binaryMessenger)
        flutterRemove = FlutterBasicMessageChannel(name: "\(FusionConstant.FUSION_CHANNEL)/flutter/remove", binaryMessenger: binaryMessenger)
        flutterNotifyPageVisible = FlutterBasicMessageChannel(name: "\(FusionConstant.FUSION_CHANNEL)/flutter/notifyPageVisible", binaryMessenger: binaryMessenger)
        flutterNotifyPageInvisible = FlutterBasicMessageChannel(name: "\(FusionConstant.FUSION_CHANNEL)/flutter/notifyPageInvisible", binaryMessenger: binaryMessenger)
        flutterNotifyEnterForeground = FlutterBasicMessageChannel(name: "\(FusionConstant.FUSION_CHANNEL)/flutter/notifyEnterForeground", binaryMessenger: binaryMessenger)
        flutterNotifyEnterBackground = FlutterBasicMessageChannel(name: "\(FusionConstant.FUSION_CHANNEL)/flutter/notifyEnterBackground", binaryMessenger: binaryMessenger)
        flutterDispatchEvent = FlutterBasicMessageChannel(name: "\(FusionConstant.FUSION_CHANNEL)/flutter/dispatchEvent", binaryMessenger: binaryMessenger)
        flutterCheckStyle = FlutterBasicMessageChannel(name: "\(FusionConstant.FUSION_CHANNEL)/flutter/checkStyle", binaryMessenger: binaryMessenger)
    }

    func attach() {
        hostPush?.setMessageHandler { (message: Any?, reply: @escaping FlutterReply) in
            guard let dict = message as? Dictionary<String, Any>, let name = dict["name"] as? String else {
                reply(nil)
                return
            }
            let args = dict["args"] as? Dictionary<String, Any>
            let type = dict["type"] as? Int
            if type == FusionRouteType.flutterWithContainer.rawValue {
                Fusion.instance.delegate?.pushFlutterRoute(name: name, args: args)
            } else if type == FusionRouteType.native.rawValue {
                Fusion.instance.delegate?.pushNativeRoute(name: name, args: args)
            }
            reply(nil)
        }
        hostDestroy?.setMessageHandler { (message: Any?, reply: @escaping FlutterReply) in
            guard let dict = message as? Dictionary<String, Any>, let uniqueId = dict["uniqueId"] as? String else {
                reply(false)
                return
            }
            if let container = FusionStackManager.instance.findContainer(uniqueId) {
                FusionStackManager.instance.closeContainer(container)
                reply(true)
            } else {
                reply(false)
            }
        }
        hostRestore?.setMessageHandler { (message: Any?, reply: @escaping FlutterReply) in
            reply(self.historyList)
        }
        hostSync?.setMessageHandler { (message: Any?, reply: @escaping FlutterReply) in
            guard let dict = message as? Dictionary<String, Any>, let hostPopGesture = dict["hostPopGesture"] as? Bool, let uniqueId = dict["uniqueId"] as? String, let history = dict["history"] as? [Dictionary<String, Any?>] else {
                reply(false)
                return
            }
            let container = FusionStackManager.instance.findContainer(uniqueId)
            container?.history.removeAll()
            container?.history.append(contentsOf: history)
            if container?.history.count == 1 && hostPopGesture {
                self.enablePopGesture()
            } else {
                self.disablePopGesture()
            }
            reply(true)
        }
        hostDispatchEvent?.setMessageHandler { (message: Any?, reply: @escaping FlutterReply) in
            guard let dict = message as? Dictionary<String, Any>, let name = dict["name"] as? String else {
                reply(nil)
                return
            }
            let args = dict["args"] as? Dictionary<String, Any>
            FusionEventManager.instance.send(name, args: args, type: .native)
            reply(nil)
        }
        hostRemoveMaskView?.setMessageHandler { (message: Any?, reply: @escaping FlutterReply) in
            guard let dict = message as? Dictionary<String, Any>, let uniqueId = dict["uniqueId"] as? String else {
                reply(nil)
                return
            }
            FusionStackManager.instance.findContainer(uniqueId)?.removeMask()
            reply(nil)
        }
    }

    // external function
    func push(_ name: String, args: Dictionary<String, Any>?, type: FusionRouteType) {
        flutterPush?.sendMessage([
            "name": name,
            "args": args as Any,
            "type": type.rawValue
        ])
    }

    func replace(_ name: String, args: Dictionary<String, Any>?) {
        flutterReplace?.sendMessage([
            "name": name,
            "args": args as Any
        ])
    }

    func pop(_ result: Any?) {
        flutterPop?.sendMessage([
            "result": result
        ])
    }

    func maybePop(_ result: Any?) {
        flutterMaybePop?.sendMessage([
            "result": result
        ])
    }

    func remove(_ name: String) {
        flutterRemove?.sendMessage([
            "name": name,
        ])
    }

    // internal function
    func enablePopGesture() {
        (UIApplication.roofViewController as? FusionPopGestureHandler)?.enablePopGesture()
    }

    func disablePopGesture() {
        (UIApplication.roofViewController as? FusionPopGestureHandler)?.disablePopGesture()
    }

    func create(_ uniqueId: String, name: String, args: Dictionary<String, Any>?) {
        flutterCreate?.sendMessage([
            "uniqueId": uniqueId,
            "name": name,
            "args": args as Any
        ])
    }

    func switchTop(_ uniqueId: String, _ callback: @escaping () -> Void) {
        flutterSwitchTop?.sendMessage(
            ["uniqueId": uniqueId],
            reply: { (_) in
                callback()
            }
        )
    }

    /**
     Restore the specified container in flutter side
     - Parameters:
       - uniqueId: container's uniqueId
       - history: container's history
     */
    func restore(_ uniqueId: String, history: [Dictionary<String, Any?>]) {
        flutterRestore?.sendMessage([
            "uniqueId": uniqueId,
            "history": history
        ])
    }

    /**
     Destroy the specified container in flutter side
     - Parameter uniqueId: container's uniqueId
     */
    func destroy(_ uniqueId: String) {
        flutterDestroy?.sendMessage([
            "uniqueId": uniqueId
        ])
    }

    func notifyPageVisible(_ uniqueId: String) {
        flutterNotifyPageVisible?.sendMessage([
            "uniqueId": uniqueId
        ])
    }

    func notifyPageInvisible(_ uniqueId: String) {
        flutterNotifyPageInvisible?.sendMessage([
            "uniqueId": uniqueId
        ])
    }

    func notifyEnterForeground() {
        flutterNotifyEnterForeground?.sendMessage(nil)
    }

    func notifyEnterBackground() {
        flutterNotifyEnterBackground?.sendMessage(nil)
    }

    func dispatchEvent(_ name: String, _ args: Dictionary<String, Any>?) {
        let msg: Dictionary<String, Any?> = ["name": name, "args": args]
        flutterDispatchEvent?.sendMessage(msg)
    }

    func checkStyle(_ callback: @escaping (_ statusBarStyle: UIStatusBarStyle) -> Void) {
        let infoValue = Bundle.main.object(forInfoDictionaryKey: "UIViewControllerBasedStatusBarAppearance") as? Bool
        if infoValue == false {
            return
        }
        flutterCheckStyle?.sendMessage(nil, reply: { (reply) in
            if (reply == nil) {
                return
            }
            if (reply is FlutterError) {
                return
            }
            if reply as? NSObject == FlutterMethodNotImplemented {
                return
            }
            var statusBarStyle: UIStatusBarStyle?
            if let map = reply as? Dictionary<String, Any> {
                let brightness = map["statusBarBrightness"] as? String
                if brightness == nil {
                    return
                }
                if brightness == "Brightness.dark" {
                    statusBarStyle = .lightContent
                } else if brightness == "Brightness.light" {
                    if #available(iOS 13, *) {
                        statusBarStyle = .darkContent
                    } else {
                        statusBarStyle = .default
                    }
                } else {
                    return
                }
            }
            guard let statusBarStyle = statusBarStyle else {
                return
            }
            callback(statusBarStyle)
        })
    }

    func detach() {
        hostPush?.setMessageHandler(nil)
        hostPush = nil
        hostDestroy?.setMessageHandler(nil)
        hostDestroy = nil
        hostRestore?.setMessageHandler(nil)
        hostRestore = nil
        hostSync?.setMessageHandler(nil)
        hostSync = nil
        hostDispatchEvent?.setMessageHandler(nil)
        hostDispatchEvent = nil
        hostRemoveMaskView?.setMessageHandler(nil)
        hostRemoveMaskView = nil
        flutterCreate = nil
        flutterSwitchTop = nil
        flutterRestore = nil
        flutterDestroy = nil
        flutterPush = nil
        flutterReplace = nil
        flutterPop = nil
        flutterMaybePop = nil
        flutterRemove = nil
        flutterNotifyPageVisible = nil
        flutterNotifyPageInvisible = nil
        flutterNotifyEnterForeground = nil
        flutterNotifyEnterBackground = nil
        flutterDispatchEvent = nil
        flutterCheckStyle = nil
        engine?.viewController = nil
        engine?.destroyContext()
        engine = nil
    }
}
