package com.gtbluesky.fusion.engine

import io.flutter.embedding.engine.FlutterEngine

interface EngineProvider {
    fun onEngineCreated(engine: FlutterEngine)
}