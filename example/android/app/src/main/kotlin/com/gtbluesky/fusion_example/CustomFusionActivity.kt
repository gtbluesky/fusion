package com.gtbluesky.fusion_example

import android.util.Log
import com.gtbluesky.fusion.controller.FusionActivity
import com.gtbluesky.fusion.channel.FusionMessengerProvider
import com.gtbluesky.fusion.controller.FusionFragmentActivity
import io.flutter.plugin.common.BinaryMessenger

class CustomFusionActivity : FusionFragmentActivity(), FusionMessengerProvider {

    override fun configureFlutterChannel(binaryMessenger: BinaryMessenger) {
        Log.d("CustomFusionActivity", "configureFlutterChannel")
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(this::class.java.simpleName, "onDestroy")
    }

}