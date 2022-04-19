package com.gtbluesky.fusion.controller

import com.gtbluesky.fusion.engine.FusionEngineBinding

internal interface FusionContainer {
    fun provideEngineBinding(): FusionEngineBinding
}