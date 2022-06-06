package com.gtbluesky.fusion.container

import android.app.Activity
import android.content.Context
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import com.gtbluesky.fusion.Fusion
import com.gtbluesky.fusion.channel.FusionMessengerProvider
import com.gtbluesky.fusion.constant.FusionConstant
import com.gtbluesky.fusion.engine.FusionEngineBinding
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.systemchannels.PlatformChannel
import io.flutter.plugin.platform.PlatformPlugin

open class FusionActivity : FlutterActivity(), FusionContainer {

    private val history = mutableListOf<Map<String, Any?>>()
    private var engineBinding: FusionEngineBinding? = null
    private var platformPlugin: PlatformPlugin? = null

    override fun history() = history

    override fun onCreate(savedInstanceState: Bundle?) {
        engineBinding = Fusion.engineBinding
        configurePlatformChannel()
        val routeName =
            intent.getStringExtra(FusionConstant.ROUTE_NAME) ?: FusionConstant.INITIAL_ROUTE
        val routeArguments =
            intent.getSerializableExtra(FusionConstant.ROUTE_ARGUMENTS) as? Map<String, Any>
        engineBinding?.push(routeName, routeArguments)
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            window.statusBarColor = Color.TRANSPARENT
        }
        platformPlugin?.updateSystemUiOverlays()
    }

    override fun onStart() {
        super.onStart()
        configurePlatformChannel()
        if (this !is FusionMessengerProvider) {
            return
        }
        engineBinding?.engine?.let {
            this.configureFlutterChannel(it.dartExecutor.binaryMessenger)
        }
    }

    override fun onStop() {
        super.onStop()
        releasePlatformChannel()
        if (this !is FusionMessengerProvider) {
            return
        }
        this.releaseFlutterChannel()
    }

    override fun onDestroy() {
        super.onDestroy()
        history.clear()
        engineBinding?.pop()
        engineBinding = null
    }

    override fun onBackPressed() {
        engineBinding?.pop(true)
    }

    override fun provideFlutterEngine(context: Context) = engineBinding?.engine

    override fun providePlatformPlugin(
        activity: Activity?,
        flutterEngine: FlutterEngine
    ): PlatformPlugin? {
        return null
    }

    override fun detachFromFlutterEngine() {}

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
}