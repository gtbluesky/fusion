package com.gtbluesky.fusion.navigator

import com.gtbluesky.fusion.Fusion

object FusionNavigator {
    @JvmOverloads
    fun push(name: String, arguments: Map<String, Any>? = null) {
        Fusion.delegate.pushFlutterRoute(name, arguments)
    }
}