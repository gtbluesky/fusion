package com.gtbluesky.fusion.container

import android.app.Activity
import android.content.Context
import android.os.Bundle
import com.gtbluesky.fusion.Fusion
import com.gtbluesky.fusion.channel.FusionMessengerProvider
import com.gtbluesky.fusion.constant.FusionConstant
import com.gtbluesky.fusion.engine.FusionEngineBinding
import com.gtbluesky.fusion.navigator.FusionStackManager
import io.flutter.embedding.android.FlutterFragment
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.systemchannels.PlatformChannel
import io.flutter.plugin.platform.PlatformPlugin
import java.io.Serializable

open class FusionFragment : FlutterFragment(), FusionContainer {

    private var isNested = true
    private val history = mutableListOf<Map<String, Any?>>()
    private var engineBinding: FusionEngineBinding? = null
    private var platformPlugin: PlatformPlugin? = null

    override fun engineBinding() = engineBinding

    override fun history() = history

    override fun onAttach(context: Context) {
        isNested = arguments?.getBoolean(FusionConstant.NESTED_MODE) ?: true
        engineBinding = if (isNested) {
            FusionEngineBinding(isNested)
        } else {
            Fusion.engineBinding
        }
        super.onAttach(context)
        if (isNested) {
            engineBinding?.attach(this)
        } else {
            configurePlatformChannel()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        val routeName =
            arguments?.getString(FusionConstant.ROUTE_NAME) ?: FusionConstant.INITIAL_ROUTE
        val routeArguments =
            arguments?.getSerializable(FusionConstant.ROUTE_ARGUMENTS) as? Map<String, Any>
        engineBinding?.push(routeName, routeArguments)
        super.onCreate(savedInstanceState)
        if (isNested) {
            FusionStackManager.addChild(this)
        } else {
            platformPlugin?.updateSystemUiOverlays()
        }
    }

    override fun onStart() {
        super.onStart()
        engineBinding?.engine?.let {
            if (isNested) {
                (this as? FusionMessengerProvider)?.configureFlutterChannel(it.dartExecutor.binaryMessenger)
            } else {
                configurePlatformChannel()
                (activity as? FusionMessengerProvider)?.configureFlutterChannel(it.dartExecutor.binaryMessenger)
            }
        }
    }

    override fun onStop() {
        super.onStop()
        if (isNested) {
            (this as? FusionMessengerProvider)?.releaseFlutterChannel()
        } else {
            releasePlatformChannel()
            (activity as? FusionMessengerProvider)?.releaseFlutterChannel()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        history.clear()
        if (isNested) {
            FusionStackManager.removeChild(this)
        }
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
        return if (isNested) {
            super.providePlatformPlugin(activity, flutterEngine)
        } else {
            null
        }
    }

    override fun detachFromFlutterEngine() {
        if (isNested) {
            super.detachFromFlutterEngine()
        }
    }

    private fun configurePlatformChannel() {
        if (platformPlugin != null) {
            return
        }
        val platformChannel = engineBinding?.engine?.platformChannel ?: return
        platformPlugin = activity?.let { PlatformPlugin(it, platformChannel) } ?: return
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

    internal class FusionFlutterFragmentBuilder(fragmentClass: Class<out FusionFragment>) :
        FlutterFragment.NewEngineFragmentBuilder(fragmentClass) {

        private var routeName: String = FusionConstant.INITIAL_ROUTE
        private var routeArguments: Map<String, Any>? = null
        private var isNested = true

        fun setInitialRoute(
            name: String,
            arguments: Map<String, Any>?
        ): FusionFlutterFragmentBuilder {
            routeName = name
            routeArguments = arguments
            return this
        }

        fun setNestMode(isNested: Boolean): FusionFlutterFragmentBuilder {
            this.isNested = isNested
            return this
        }

        override fun createArgs(): Bundle {
            return super.createArgs().also {
                it.putString(FusionConstant.ROUTE_NAME, routeName)
                it.putSerializable(FusionConstant.ROUTE_ARGUMENTS, routeArguments as? Serializable)
                it.putBoolean(FusionConstant.ARG_DESTROY_ENGINE_WITH_FRAGMENT, false)
                it.putBoolean(FusionConstant.NESTED_MODE, isNested)
            }
        }
    }
}