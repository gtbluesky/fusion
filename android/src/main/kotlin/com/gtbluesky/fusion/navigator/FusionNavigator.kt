package com.gtbluesky.fusion.navigator

import com.gtbluesky.fusion.Fusion

object FusionNavigator {
    fun push(name: String, arguments: Map<String, Any>?) {
        Fusion.delegate.pushFlutterRoute(name, arguments)
    }
}