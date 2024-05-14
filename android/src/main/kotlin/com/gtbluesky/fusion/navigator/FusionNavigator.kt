package com.gtbluesky.fusion.navigator

import com.gtbluesky.fusion.Fusion
import com.gtbluesky.fusion.event.FusionEventManager
import com.gtbluesky.fusion.event.FusionEventType

object FusionNavigator {
    /**
     * 将对应路由入栈
     */
    @JvmStatic
    @JvmOverloads
    fun push(routeName: String, routeArgs: Map<String, Any>? = null, routeType: FusionRouteType = FusionRouteType.ADAPTION) {
        when (routeType) {
            FusionRouteType.FLUTTER_WITH_CONTAINER -> Fusion.delegate.pushFlutterRoute(routeName, routeArgs)
            FusionRouteType.NATIVE -> Fusion.delegate.pushNativeRoute(routeName, routeArgs)
            else -> Fusion.engineBinding?.push(routeName, routeArgs, routeType)
        }
    }

    /**
     * 在当前Flutter容器中将栈顶路由替换为对应路由
     */
    @JvmStatic
    @JvmOverloads
    fun replace(routeName: String, routeArgs: Map<String, Any>? = null) {
        Fusion.engineBinding?.replace(routeName, routeArgs)
    }

    /**
     * 在当前Flutter容器中将栈顶路由出栈
     */
    @JvmStatic
    @JvmOverloads
    fun <T> pop(result: T? = null) {
        Fusion.engineBinding?.pop(result)
    }

    /**
     * 在当前Flutter容器中将栈顶路由出栈，可被WillPopScope拦截
     */
    @JvmStatic
    @JvmOverloads
    fun <T> maybePop(result: T? = null) {
        Fusion.engineBinding?.maybePop(result)
    }

    /**
     * 在当前Flutter容器中移除对应路由
     * @param routeName: 路由名
     */
    @JvmStatic
    fun remove(routeName: String) {
        Fusion.engineBinding?.remove(routeName)
    }
}

interface FusionRouteDelegate {
    fun pushNativeRoute(name: String, args: Map<String, Any>?)
    fun pushFlutterRoute(name: String, args: Map<String, Any>?)
}

enum class FusionRouteType {
    FLUTTER,
    FLUTTER_WITH_CONTAINER,
    NATIVE,
    ADAPTION
}