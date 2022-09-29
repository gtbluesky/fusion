package com.gtbluesky.fusion.container

import android.app.Activity
import android.app.ActivityManager
import android.content.Context
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import com.gtbluesky.fusion.Fusion
import com.gtbluesky.fusion.channel.FusionMessengerProvider
import com.gtbluesky.fusion.constant.FusionConstant
import com.gtbluesky.fusion.engine.FusionEngineBinding
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.android.RenderMode
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.systemchannels.PlatformChannel
import io.flutter.plugin.platform.PlatformPlugin

open class FusionActivity : FlutterActivity(), FusionContainer {

    private val history = mutableListOf<Map<String, Any?>>()
    private var engineBinding: FusionEngineBinding? = null
    private var platformPlugin: PlatformPlugin? = null
    private var flutterView: FlutterView? = null
    private var isAttached = false

    override fun history() = history

    override fun getRenderMode() = RenderMode.texture

    override fun onCreate(savedInstanceState: Bundle?) {
        engineBinding = Fusion.engineBinding
        val routeName =
            intent.getStringExtra(FusionConstant.ROUTE_NAME) ?: FusionConstant.INITIAL_ROUTE
        val routeArguments =
            intent.getSerializableExtra(FusionConstant.ROUTE_ARGUMENTS) as? Map<String, Any>
        engineBinding?.push(routeName, routeArguments)
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            window.statusBarColor = Color.TRANSPARENT
        }
        flutterView = findFlutterView(window.decorView)
        flutterView?.detachFromFlutterEngine()
    }

    override fun onStart() {
        super.onStart()
        performAttach()
        platformPlugin?.updateSystemUiOverlays()
    }

    override fun onPause() {
        super.onPause()
        performDetach()
    }

    override fun onDestroy() {
        super.onDestroy()
        history.clear()
        engineBinding?.pop()
        engineBinding = null
    }

    private fun performAttach() {
        if (isAttached) {
            return
        }
        val engine = engineBinding?.engine ?: return
        // Attach plugins to the activity.
        engine.activityControlSurface.attachToActivity(
            delegate,
            lifecycle
        )
        configureChannel()
        // Attach rendering pipeline.
        flutterView?.attachToFlutterEngine(engine)
        isAttached = true
    }

    private fun performDetach() {
        if (!isAttached) {
            return
        }
        val engine = engineBinding?.engine ?: return
        // Plugins are no longer attached to the activity.
        engine.activityControlSurface.detachFromActivity()
        releaseChannel()
        // Detach rendering pipeline.
        flutterView?.detachFromFlutterEngine()
        isAttached = false
    }

    override fun provideFlutterEngine(context: Context) = engineBinding?.engine

    override fun providePlatformPlugin(
        activity: Activity?,
        flutterEngine: FlutterEngine
    ): PlatformPlugin? = null

    override fun detachFromFlutterEngine() {}

    private fun configureChannel() {
        configurePlatformChannel()
        val engine = engineBinding?.engine ?: return
        (this as? FusionMessengerProvider)?.configureFlutterChannel(engine.dartExecutor.binaryMessenger)
    }

    private fun releaseChannel() {
        releasePlatformChannel()
        (this as? FusionMessengerProvider)?.releaseFlutterChannel()
    }

    private fun configurePlatformChannel() {
        if (platformPlugin != null) {
            return
        }
        val platformChannel = engineBinding?.engine?.platformChannel ?: return
        platformPlugin = PlatformPlugin(this, platformChannel)
        val clazz = Class.forName("io.flutter.plugin.platform.PlatformPlugin")
        val field = clazz.getDeclaredField("currentTheme")
        field.isAccessible = true
        Fusion.currentTheme?.let {
            field.set(platformPlugin, it)
        }
    }

    private fun releasePlatformChannel() {
        val clazz = Class.forName("io.flutter.plugin.platform.PlatformPlugin")
        val field = clazz.getDeclaredField("currentTheme")
        field.isAccessible = true
        (field.get(platformPlugin) as? PlatformChannel.SystemChromeStyle)?.let {
            Fusion.currentTheme = it
        }
        platformPlugin?.destroy()
        platformPlugin = null
    }

    override fun setTaskDescription(taskDescription: ActivityManager.TaskDescription?) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            if (taskDescription?.label.isNullOrEmpty()) {
                return
            }
        }
        super.setTaskDescription(taskDescription)
    }
}