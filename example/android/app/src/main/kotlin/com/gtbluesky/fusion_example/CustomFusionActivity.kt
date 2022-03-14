package com.gtbluesky.fusion_example

import android.util.Log
import com.gtbluesky.fusion.controller.FusionActivity
import com.gtbluesky.fusion.engine.FusionMessengerProvider
import io.flutter.plugin.common.BinaryMessenger

class CustomFusionActivity : FusionActivity(), FusionMessengerProvider {

    override fun configureFlutterChannel(binaryMessenger: BinaryMessenger) {
        Log.d("CustomFusionActivity", "configureFlutterChannel")
    }

}