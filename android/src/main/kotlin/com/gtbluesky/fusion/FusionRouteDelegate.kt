package com.gtbluesky.fusion

interface FusionRouteDelegate {
    fun pushNativeRoute(name: String, args: Map<String, Any>?)
    fun pushFlutterRoute(name: String, args: Map<String, Any>?)
}