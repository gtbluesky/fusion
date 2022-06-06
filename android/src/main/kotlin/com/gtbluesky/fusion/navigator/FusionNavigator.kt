package com.gtbluesky.fusion.navigator

import com.gtbluesky.fusion.Fusion

object FusionNavigator {


    /**
     * 打开新Flutter容器并将对应路由入栈
     * Native页面跳转Flutter页面使用该API
     */
    @JvmStatic
    @JvmOverloads
    fun open(name: String, arguments: Map<String, Any>? = null) {
        Fusion.delegate.pushFlutterRoute(name, arguments)
    }

    /**
     * 在当前Flutter容器中将对应路由入栈
     */
    @JvmStatic
    @JvmOverloads
    fun push(name: String, arguments: Map<String, Any>? = null) {
        if (!FusionStackManager.topIsFusionContainer()) {
            return
        }
        Fusion.engineBinding?.push(name, arguments)
    }

    /**
     * 在当前Flutter容器中将栈顶路由替换为对应路由
     */
    @JvmStatic
    @JvmOverloads
    fun replace(name: String, arguments: Map<String, Any>? = null) {
        if (!FusionStackManager.topIsFusionContainer()) {
            return
        }
        Fusion.engineBinding?.replace(name, arguments)
    }

    /**
     * 在当前Flutter容器中将栈顶路由出栈
     */
    @JvmStatic
    @JvmOverloads
    fun <T> pop(result: T? = null) {
        if (!FusionStackManager.topIsFusionContainer()) {
            return
        }
        Fusion.engineBinding?.pop(true, result)
    }

    /**
     * 在当前Flutter容器中移除对应路由
     * @param name: 路由名
     */
    @JvmStatic
    fun remove(name: String) {
        if (!FusionStackManager.topIsFusionContainer()) {
            return
        }
        Fusion.engineBinding?.remove(name)
    }

    @JvmStatic
    @JvmOverloads
    fun sendMessage(msgName: String, msgBody: Map<String, Any>? = null) {
        FusionStackManager.sendMessage(msgName, msgBody)
    }
}