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
    public func open(_ name: String, arguments: Dictionary<String, Any>? = nil) {
        Fusion.instance.delegate?.pushFlutterRoute(name: name, arguments: arguments)
    }

    /**
     * 在当前Flutter容器中将对应路由入栈
     */
    public func push(_ name: String, arguments: Dictionary<String, Any>? = nil) {
        Fusion.instance.engineBinding?.push(name, arguments: arguments)
    }

    /**
     * 在当前Flutter容器中将栈顶路由替换为对应路由
     */
    public func replace(_ name: String, arguments: Dictionary<String, Any>? = nil) {
        Fusion.instance.engineBinding?.replace(name, arguments: arguments)
    }

    /**
     * 在当前Flutter容器中将栈顶路由出栈
     */
    public func pop<T>(_ result: T? = nil) {
        Fusion.instance.engineBinding?.pop(active: true, result: result)
    }

    /**
     * 在当前Flutter容器中移除对应路由
     * @param name: 路由名
     */
    public func remove(_ name: String) {
        Fusion.instance.engineBinding?.remove(name)
    }

    public func sendMessage(_ msgName: String, msgBody: Dictionary<String, Any>? = nil) {
        FusionStackManager.instance.sendMessage(msgName, msgBody: msgBody)
    }
}
