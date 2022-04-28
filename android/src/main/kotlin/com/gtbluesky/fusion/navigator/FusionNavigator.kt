package com.gtbluesky.fusion.navigator

import com.gtbluesky.fusion.Fusion

object FusionNavigator {
    @JvmOverloads
    fun push(name: String, arguments: Map<String, Any>? = null) {
        Fusion.delegate.pushFlutterRoute(name, arguments)
    }

    @JvmOverloads
    fun sendMessage(msgName: String, msgBody: Map<String, Any>? = null) {
        FusionStackManager.sendMessage(msgName, msgBody)
    }
}