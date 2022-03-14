package com.gtbluesky.fusion.engine

import io.flutter.embedding.engine.FlutterEngine

interface FusionEngineProvider {
    fun onEngineCreated(engine: FlutterEngine)
}