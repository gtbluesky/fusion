//
//  FusionNavigator.swift
//  fusion
//
//  Created by gtbluesky on 2022/3/10.
//

import Foundation

@objc public class FusionNavigator: NSObject {
    public static let instance = FusionNavigator()

    private override init() {
    }

    /**
     * 打开新Flutter容器并将对应路由入栈
     * Native页面跳转Flutter页面使用该API
     */
    public func open(name: String, arguments: Dictionary<String, Any>? = nil) {
        Fusion.instance.delegate?.pushFlutterRoute(name: name, arguments: arguments)
    }

    /**
     * 在当前Flutter容器中将对应路由入栈
     */
    public func push(name: String, arguments: Dictionary<String, Any>? = nil) {
        if !FusionStackManager.instance.topIsFusionContainer() {
            return
        }
        Fusion.instance.engineBinding?.push(name, arguments)
    }

    /**
     * 在当前Flutter容器中将栈顶路由替换为对应路由
     */
    public func replace(name: String, arguments: Dictionary<String, Any>? = nil) {
        if !FusionStackManager.instance.topIsFusionContainer() {
            return
        }
        Fusion.instance.engineBinding?.replace(name, arguments)
    }

    /**
     * 在当前Flutter容器中将栈顶路由出栈
     */
    public func pop<T>(result: T? = nil) {
        if !FusionStackManager.instance.topIsFusionContainer() {
            return
        }
        Fusion.instance.engineBinding?.pop(true, result)
    }

    /**
     * 在当前Flutter容器中移除对应路由
     * @param name: 路由名
     * @param all: 移除栈中所有与指定路由名相同的路由，否则移除最接近栈顶的路由
     */
    public func remove(name: String, all: Bool = false) {
        if !FusionStackManager.instance.topIsFusionContainer() {
            return
        }
        Fusion.instance.engineBinding?.remove(name: name, all: all)
    }

    public func sendMessage(msgName: String, msgBody: Dictionary<String, Any>? = nil) {
        FusionStackManager.instance.sendMessage(msgName, msgBody)
    }
}
