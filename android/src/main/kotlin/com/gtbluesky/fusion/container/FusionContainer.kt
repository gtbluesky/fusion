package com.gtbluesky.fusion.container

internal interface FusionContainer {
    fun uniqueId(): String?
    fun history(): MutableList<Map<String, Any?>>
    fun isTransparent(): Boolean
    fun isAttached(): Boolean
    fun detachFromEngine()
    fun removeMaskView()
}