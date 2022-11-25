package com.gtbluesky.fusion.container

internal interface FusionContainer {
    fun uniqueId(): String?
    fun history(): MutableList<Map<String, Any?>>
    fun isTransparent(): Boolean
    fun detachFromEngine()
    /**
     * Give the host application a chance to take control of the app lifecycle events.
     * from 3.0
     */
    fun shouldDispatchAppLifecycleState(): Boolean
}