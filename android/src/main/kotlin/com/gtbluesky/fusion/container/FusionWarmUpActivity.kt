package com.gtbluesky.fusion.container

import android.app.Activity
import android.app.ActivityManager
import android.content.Context
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import com.gtbluesky.fusion.Fusion
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.android.RenderMode
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.platform.PlatformPlugin

internal class FusionWarmUpActivity : FlutterActivity() {

    private var flutterView: FlutterView? = null
    private var isAttached = false
    private var engineBinding = Fusion.engineBinding

    override fun getRenderMode() = RenderMode.texture

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            window.statusBarColor = Color.TRANSPARENT
        }
        flutterView = findFlutterView(window.decorView)
        flutterView?.detachFromFlutterEngine()
    }

    override fun onResume() {
        super.onResume()
        onContainerVisible()
        Handler(Looper.getMainLooper()).postDelayed({
            finish()
        }, 500)
    }

    override fun onDestroy() {
        onContainerDestroy()
        super.onDestroy()
        engineBinding = null
    }

    private fun onContainerVisible() {
        performAttach()
    }

    private fun onContainerDestroy() {
        performDetach()
    }

    override fun shouldAttachEngineToActivity() = false

    private fun performAttach() {
        if (isAttached) return
        isAttached = true
        val engine = engineBinding?.engine ?: return
        // Attach plugins to the activity.
        engine.activityControlSurface.attachToActivity(
            delegate,
            lifecycle
        )
        // Attach rendering pipeline.
        flutterView?.attachToFlutterEngine(engine)
    }

    private fun performDetach() {
        if (!isAttached) return
        isAttached = false
        val engine = engineBinding?.engine ?: return
        // Plugins are no longer attached to the activity.
        engine.activityControlSurface.detachFromActivity()
        // Detach rendering pipeline.
        flutterView?.detachFromFlutterEngine()
    }

    override fun provideFlutterEngine(context: Context) = engineBinding?.engine

    override fun providePlatformPlugin(
        activity: Activity?,
        flutterEngine: FlutterEngine
    ): PlatformPlugin? = null

    override fun detachFromFlutterEngine() {}

    override fun setTaskDescription(taskDescription: ActivityManager.TaskDescription?) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            if (taskDescription?.label.isNullOrEmpty()) {
                return
            }
        }
        super.setTaskDescription(taskDescription)
    }

    override fun onBackPressed() {
        engineBinding?.maybePop(null)
    }
}