package com.gtbluesky.fusion.container

import android.app.Activity
import android.content.Context
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.gtbluesky.fusion.Fusion
import com.gtbluesky.fusion.channel.FusionMessengerProvider
import com.gtbluesky.fusion.constant.FusionConstant
import com.gtbluesky.fusion.engine.FusionEngineBinding
import com.gtbluesky.fusion.navigator.FusionStackManager
import io.flutter.embedding.android.ExclusiveAppComponent
import io.flutter.embedding.android.FlutterFragment
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.android.RenderMode
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.systemchannels.PlatformChannel
import io.flutter.plugin.platform.PlatformPlugin
import java.io.Serializable

open class FusionFragment : FlutterFragment(), FusionContainer {

    private var isReused = false
    private val history = mutableListOf<Map<String, Any?>>()
    private var engineBinding: FusionEngineBinding? = null
    private var platformPlugin: PlatformPlugin? = null
    private var flutterView: FlutterView? = null
    private var isAttached = false

    override fun engineBinding() = engineBinding

    override fun history() = history

    override fun getRenderMode() = RenderMode.texture

    override fun onAttach(context: Context) {
        isReused = arguments?.getBoolean(FusionConstant.REUSE_MODE) ?: false
        engineBinding = if (isReused) {
            Fusion.engineBinding
        } else {
            FusionEngineBinding(false)
        }
        super.onAttach(context)
        if (isReused) {
            return
        }
        engineBinding?.attach(this)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        val routeName =
            arguments?.getString(FusionConstant.ROUTE_NAME) ?: FusionConstant.INITIAL_ROUTE
        val routeArguments =
            arguments?.getSerializable(FusionConstant.ROUTE_ARGUMENTS) as? Map<String, Any>
        engineBinding?.push(routeName, routeArguments)
        super.onCreate(savedInstanceState)
        if (isReused) {
            return
        }
        FusionStackManager.addChild(this)
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        val view = super.onCreateView(inflater, container, savedInstanceState)
        if (isReused) {
            flutterView = findFlutterView(view)
            flutterView?.detachFromFlutterEngine()
        }
        return view
    }

    override fun onStart() {
        super.onStart()
        if (isReused) {
            performAttach()
            platformPlugin?.updateSystemUiOverlays()
        } else {
            val engine = engineBinding?.engine ?: return
            (this as? FusionMessengerProvider)?.configureFlutterChannel(engine.dartExecutor.binaryMessenger)
        }
    }

    override fun onPause() {
        super.onPause()
        if (isReused) {
            performDetach()
        } else {
            (this as? FusionMessengerProvider)?.releaseFlutterChannel()
        }
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
        try {
            val delegateField = this.javaClass.superclass.getDeclaredField("delegate")
            delegateField.isAccessible = true
            val delegate = delegateField.get(this) as ExclusiveAppComponent<Activity>
            engine.activityControlSurface.attachToActivity(
                delegate,
                lifecycle
            )
        } catch (e: Exception) {
            e.printStackTrace()
        }
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
    ): PlatformPlugin? {
        return if (isReused) {
            null
        } else {
            super.providePlatformPlugin(activity, flutterEngine)
        }
    }

    override fun detachFromFlutterEngine() {
        if (isReused) {
            return
        }
        super.detachFromFlutterEngine()
    }

    private fun configureChannel() {
        val engine = engineBinding?.engine ?: return
        configurePlatformChannel()
        (activity as? FusionMessengerProvider)?.configureFlutterChannel(engine.dartExecutor.binaryMessenger)
    }

    private fun releaseChannel() {
        releasePlatformChannel()
        (activity as? FusionMessengerProvider)?.releaseFlutterChannel()
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
        NewEngineFragmentBuilder(fragmentClass) {

        private var routeName: String = FusionConstant.INITIAL_ROUTE
        private var routeArguments: Map<String, Any>? = null
        private var isReused = false

        fun setInitialRoute(
            name: String,
            arguments: Map<String, Any>?
        ): FusionFlutterFragmentBuilder {
            routeName = name
            routeArguments = arguments
            return this
        }

        fun setReuseMode(isReused: Boolean): FusionFlutterFragmentBuilder {
            this.isReused = isReused
            return this
        }

        override fun createArgs(): Bundle {
            return super.createArgs().also {
                it.putString(FusionConstant.ROUTE_NAME, routeName)
                it.putSerializable(FusionConstant.ROUTE_ARGUMENTS, routeArguments as? Serializable)
                it.putBoolean(FusionConstant.ARG_DESTROY_ENGINE_WITH_FRAGMENT, false)
                it.putBoolean(FusionConstant.REUSE_MODE, isReused)
            }
        }
    }
}