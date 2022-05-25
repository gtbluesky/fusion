package com.gtbluesky.fusion.container

import com.gtbluesky.fusion.engine.FusionEngineBinding

interface FusionContainer {
    fun history(): MutableList<Map<String, Any?>>
    fun engineBinding(): FusionEngineBinding? = null
}