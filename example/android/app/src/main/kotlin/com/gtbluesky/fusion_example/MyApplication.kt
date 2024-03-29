package com.gtbluesky.fusion_example

import android.content.Intent
import android.graphics.Color
import android.util.Log
import com.gtbluesky.fusion.Fusion
import com.gtbluesky.fusion.FusionRouteDelegate
import com.gtbluesky.fusion.container.buildFusionIntent
import io.flutter.app.FlutterApplication

class MyApplication : FlutterApplication(), FusionRouteDelegate {
    companion object {
        private const val TAG = "MyApplication"
    }

    override fun onCreate() {
        super.onCreate()
        Fusion.install(this, this)
    }

    override fun pushNativeRoute(name: String, arguments: Map<String, Any>?) {
        when (name) {
            "/normal" -> {
                val intent = Intent(applicationContext, NormalActivity::class.java)
                    .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                (arguments?.get("title") as? String).let {
                    intent.putExtra("title", it)
                }
                startActivity(intent)
            }
            else -> {
                Log.e(TAG, "pushNativeRoute error, name=$name")
            }
        }
    }

    override fun pushFlutterRoute(name: String, arguments: Map<String, Any>?) {
        Log.d(TAG, "pushFlutterRoute: name=${name}, arguments=${arguments}")
        val transparent = (arguments?.get("transparent") as? Boolean) ?: false
        val backgroundColor = (arguments?.get("backgroundColor") as? Long) ?: Color.WHITE
        val clazz = if (transparent) {
            TransparentFusionActivity::class.java
        } else {
            CustomFusionActivity::class.java
        }
        startActivity(
            buildFusionIntent(
                applicationContext,
                clazz,
                name,
                arguments,
                transparent,
                backgroundColor.toInt()
            ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        )
    }
}