package com.gtbluesky.fusion_example

import android.util.Log
import com.gtbluesky.fusion.controller.FusionActivity
import com.gtbluesky.fusion.engine.FusionEngineProvider
import io.flutter.embedding.engine.FlutterEngine

class CustomFusionActivity : FusionActivity(), FusionEngineProvider {

    override fun onEngineCreated(engine: FlutterEngine) {
        Log.d("CustomFusionActivity", "onEngineCreated")
    }

}