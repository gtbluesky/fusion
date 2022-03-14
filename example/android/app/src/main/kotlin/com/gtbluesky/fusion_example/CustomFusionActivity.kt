package com.gtbluesky.fusion_example

import android.util.Log
import com.gtbluesky.fusion.controller.FusionActivity
import com.gtbluesky.fusion.channel.FusionMessengerProvider
import io.flutter.plugin.common.BinaryMessenger

class CustomFusionActivity : FusionActivity(), FusionMessengerProvider {

    override fun configureFlutterChannel(binaryMessenger: BinaryMessenger) {
        Log.d("CustomFusionActivity", "configureFlutterChannel")
    }

}