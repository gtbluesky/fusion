package com.gtbluesky.fusion_example

import android.app.Application
import android.content.Intent
import android.util.Log
import com.gtbluesky.fusion.Fusion
import com.gtbluesky.fusion.controller.FusionActivity
import com.gtbluesky.fusion.FusionRouteDelegate
import com.gtbluesky.fusion.navigator.FusionStackManager

class MyApplication : Application() {
    companion object {
        private const val TAG = "MyApplication"
    }
    override fun onCreate() {
        super.onCreate()
        Fusion.install(this, object : FusionRouteDelegate {
            override fun pushNativeRoute(name: String?, arguments: Map<String, Any>?) {
                when (name) {
                    "/a" -> {
                        FusionStackManager.getTopActivity()?.let {
                            val intent = Intent(it, AActivity::class.java)
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
                            it.startActivity(FusionActivity.buildIntent(it, name, arguments))
                        }
                    }
                    else -> {
                        Log.e(TAG, "pushFlutterRoute error, name=$name")
                    }
                }
            }
        })
    }
}