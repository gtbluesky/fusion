package com.gtbluesky.fusion.container

internal interface FusionContainer {
    fun history(): MutableList<Map<String, Any?>>
    fun isTransparent(): Boolean
}