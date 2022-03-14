package com.gtbluesky.fusion_example

import android.app.Application
import android.content.Intent
import android.util.Log
import com.gtbluesky.fusion.Fusion
import com.gtbluesky.fusion.FusionRouteDelegate
import com.gtbluesky.fusion.controller.buildFusionIntent
import com.gtbluesky.fusion.navigator.FusionStackManager
import io.flutter.app.FlutterApplication

class MyApplication : FlutterApplication(), FusionRouteDelegate {
    companion object {
        private const val TAG = "MyApplication"
    }
    override fun onCreate() {
        super.onCreate()
        Fusion.install(this, this)
    }

    override fun pushNativeRoute(name: String?, arguments: Map<String, Any>?) {
        when (name) {
            "/normal" -> {
                FusionStackManager.getTopActivity()?.let {
                    val intent = Intent(it, NormalActivity::class.java)
                    (arguments?.get("title") as? String).let {
                        intent.putExtra("title", it)
                    }
                    it.startActivity(intent)
                }
            }
            else -> {
                Log.e(TAG, "pushNativeRoute error, name=$name")
            }
        }
    }

    override fun pushFlutterRoute(name: String?, arguments: Map<String, Any>?) {
        when (name) {
            "/test" -> {
                FusionStackManager.getTopActivity()?.let {
                    it.startActivity(buildFusionIntent(it, CustomFusionActivity::class.java, name, arguments))
                }
            }
            else -> {
                Log.e(TAG, "pushFlutterRoute error, name=$name")
            }
        }
    }
}