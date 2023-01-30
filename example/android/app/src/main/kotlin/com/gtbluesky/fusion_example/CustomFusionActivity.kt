package com.gtbluesky.fusion_example

import android.util.Log
import com.gtbluesky.fusion.container.FusionActivity
import com.gtbluesky.fusion.handler.FusionMessengerHandler
import com.gtbluesky.fusion.container.FusionFragmentActivity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

open class CustomFusionActivity : FusionFragmentActivity(), FusionMessengerHandler {

    private var channel: MethodChannel? = null

    override fun configureFlutterChannel(binaryMessenger: BinaryMessenger) {
        Log.d(this.toString(), "configureFlutterChannel")
        channel = MethodChannel(binaryMessenger, "custom_channel")
        channel?.setMethodCallHandler { call, result ->
            result.success("Custom Channel：${this}_${call.method}")
        }
    }

    override fun releaseFlutterChannel() {
        Log.d(this.toString(), "releaseFlutterChannel")
        channel?.setMethodCallHandler(null)
        channel = null
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(this::class.java.simpleName, "onDestroy")
    }

}