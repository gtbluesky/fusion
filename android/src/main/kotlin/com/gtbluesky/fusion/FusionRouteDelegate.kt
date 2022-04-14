package com.gtbluesky.fusion

interface FusionRouteDelegate {
    fun pushNativeRoute(name: String, arguments: Map<String, Any>?)
    fun pushFlutterRoute(name: String, arguments: Map<String, Any>?)
}