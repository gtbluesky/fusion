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
     * 将对应路由入栈
     */
    public func push(_ routeName: String, routeArgs: Dictionary<String, Any>? = nil, routeType: FusionRouteType = FusionRouteType.adaption) {
        switch routeType {
        case .flutterWithContainer:
            Fusion.instance.delegate?.pushFlutterRoute(name: routeName, args: routeArgs)
        case .native:
            Fusion.instance.delegate?.pushNativeRoute(name: routeName, args: routeArgs)
        default:
            Fusion.instance.engineBinding?.push(routeName, args: routeArgs, type: routeType)
        }
    }

    /**
     * 在当前Flutter容器中将栈顶路由替换为对应路由
     */
    public func replace(_ routeName: String, routeArgs: Dictionary<String, Any>? = nil) {
        Fusion.instance.engineBinding?.replace(routeName, args: routeArgs)
    }

    /**
     * 在当前Flutter容器中将栈顶路由出栈
     */
    public func pop<T>(_ result: T? = nil) {
        Fusion.instance.engineBinding?.pop(result)
    }

    /**
     * 在当前Flutter容器中将栈顶路由出栈，可被WillPopScope拦截
     */
    public func maybePop<T>(_ result: T? = nil) {
        Fusion.instance.engineBinding?.maybePop(result)
    }

    /**
     * 在当前Flutter容器中移除对应路由
     * @param routeName: 路由名
     */
    public func remove(_ routeName: String) {
        Fusion.instance.engineBinding?.remove(routeName)
    }

    public func sendMessage(_ name: String, body: Dictionary<String, Any>? = nil) {
        FusionStackManager.instance.sendMessage(name, body: body)
    }
}

@objc public protocol FusionRouteDelegate {
    func pushNativeRoute(name: String, args: Dictionary<String, Any>?)
    func pushFlutterRoute(name: String, args: Dictionary<String, Any>?)
}

@objc public enum FusionRouteType: Int {
    case flutter
    case flutterWithContainer
    case native
    case adaption
}
