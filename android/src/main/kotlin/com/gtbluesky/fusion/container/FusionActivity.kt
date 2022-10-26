package com.gtbluesky.fusion.container

import android.app.Activity
import android.app.ActivityManager
import android.content.Context
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.core.view.forEach
import com.gtbluesky.fusion.Fusion
import com.gtbluesky.fusion.constant.FusionConstant
import com.gtbluesky.fusion.engine.FusionEngineBinding
import com.gtbluesky.fusion.handler.FusionMessengerHandler
import com.gtbluesky.fusion.navigator.FusionStackManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode
import io.flutter.embedding.android.FlutterImageView
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.android.RenderMode
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.systemchannels.PlatformChannel
import io.flutter.plugin.platform.PlatformPlugin
import java.io.Serializable

open class FusionActivity : FlutterActivity(), FusionContainer {

    private val history = mutableListOf<Map<String, Any?>>()
    private var engineBinding: FusionEngineBinding? = null
    private var platformPlugin: PlatformPlugin? = null
    private var flutterView: FlutterView? = null
    private var isAttached = false

    override fun history() = history

    override fun isTransparent() = backgroundMode.name == BackgroundMode.transparent.name

    override fun getRenderMode() = RenderMode.texture

    @Suppress("UNCHECKED_CAST")
    override fun onCreate(savedInstanceState: Bundle?) {
        val top = FusionStackManager.getTopContainer()
        if (top != this) {
            top?.detachFromEngine()
        }
        engineBinding = Fusion.engineBinding
        super.onCreate(savedInstanceState)
        val routeName =
            intent.getStringExtra(FusionConstant.ROUTE_NAME) ?: FusionConstant.INITIAL_ROUTE
        val routeArguments =
            intent.getSerializableExtra(FusionConstant.ROUTE_ARGUMENTS) as? Map<String, Any>
        val restoredHistory =
            savedInstanceState?.getSerializable(FusionConstant.FUSION_RESTORATION_BUNDLE_KEY) as? List<Map<String, Any?>>
        if (restoredHistory != null) {
            history.addAll(restoredHistory)
            engineBinding?.restore(restoredHistory)
        } else {
            engineBinding?.push(routeName, routeArguments)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            window.statusBarColor = Color.TRANSPARENT
        }
        flutterView = findFlutterView(window.decorView)
        flutterView?.detachFromFlutterEngine()
        FusionStackManager.add(this)
    }

    override fun onResume() {
        super.onResume()
        val top = FusionStackManager.getTopContainer()
        if (top != this) {
            top?.detachFromEngine()
        }
        performAttach()
        engineBinding?.latestStyle { systemChromeStyle ->
            updateSystemUiOverlays(systemChromeStyle)
        }
    }

    override fun onDestroy() {
        performDetach()
        super.onDestroy()
        history.clear()
        engineBinding?.pop()
        engineBinding = null
        FusionStackManager.remove(this)
    }

    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        outState.putSerializable(
            FusionConstant.FUSION_RESTORATION_BUNDLE_KEY,
            history as? Serializable
        )
    }

    override fun shouldAttachEngineToActivity(): Boolean {
        return false
    }

    private fun performAttach() {
        if (isAttached) {
            return
        }
        isAttached = true
        val engine = engineBinding?.engine ?: return
        // Attach plugins to the activity.
        engine.activityControlSurface.attachToActivity(
            delegate,
            lifecycle
        )
        configureChannel()
        // Attach rendering pipeline.
        flutterView?.attachToFlutterEngine(engine)
    }

    private fun performDetach() {
        if (!isAttached) {
            return
        }
        isAttached = false
        val engine = engineBinding?.engine ?: return
        // Plugins are no longer attached to the activity.
        engine.activityControlSurface.detachFromActivity()
        releaseChannel()
        // Detach rendering pipeline.
        flutterView?.detachFromFlutterEngine()
        flutterView?.forEach {
            if (it is FlutterImageView) {
                flutterView?.removeView(it)
                return
            }
        }
    }

    override fun provideFlutterEngine(context: Context) = engineBinding?.engine

    override fun providePlatformPlugin(
        activity: Activity?,
        flutterEngine: FlutterEngine
    ): PlatformPlugin? = null

    override fun detachFromEngine() {
        performDetach()
    }

    override fun detachFromFlutterEngine() {}

    private fun configureChannel() {
        // 配置PlatformChannel和CustomChannel是因为其和Activity相关联
        // 而三方插件和Activity无关，一个Engine配置一次即可
        val engine = engineBinding?.engine ?: return
        configurePlatformChannel()
        (this as? FusionMessengerHandler)?.configureFlutterChannel(engine.dartExecutor.binaryMessenger)
    }

    private fun releaseChannel() {
        releasePlatformChannel()
        (this as? FusionMessengerHandler)?.releaseFlutterChannel()
    }

    private fun configurePlatformChannel() {
        if (platformPlugin != null) {
            return
        }
        val platformChannel = engineBinding?.engine?.platformChannel ?: return
        platformPlugin = PlatformPlugin(this, platformChannel)
    }

    private fun releasePlatformChannel() {
        platformPlugin?.destroy()
        platformPlugin = null
    }

    private fun updateSystemUiOverlays(systemChromeStyle: PlatformChannel.SystemChromeStyle) {
        try {
            val field = platformPlugin?.javaClass?.getDeclaredField("currentTheme")
            field?.isAccessible = true
            field?.set(platformPlugin, systemChromeStyle)
        } catch (e: Exception) {
            e.printStackTrace()
        }
        platformPlugin?.updateSystemUiOverlays()
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