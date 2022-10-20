package com.gtbluesky.fusion.container

import android.app.Activity
import android.content.Context
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.gtbluesky.fusion.Fusion
import com.gtbluesky.fusion.constant.FusionConstant
import com.gtbluesky.fusion.engine.FusionEngineBinding
import com.gtbluesky.fusion.handler.FusionMessengerHandler
import com.gtbluesky.fusion.navigator.FusionStackManager
import io.flutter.embedding.android.ExclusiveAppComponent
import io.flutter.embedding.android.FlutterFragment
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.android.TransparencyMode
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.systemchannels.PlatformChannel
import io.flutter.plugin.platform.PlatformPlugin
import java.io.Serializable

open class FusionFragment : FlutterFragment(), FusionContainer {

    private var isReused = false
    private val history = mutableListOf<Map<String, Any?>>()
    internal var engineBinding: FusionEngineBinding? = null
    private var platformPlugin: PlatformPlugin? = null
    private var flutterView: FlutterView? = null
    private var isAttached = false

    override fun history() = history

    override fun isTransparent() = transparencyMode.name == TransparencyMode.transparent.name

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

    @Suppress("UNCHECKED_CAST")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val routeName =
            arguments?.getString(FusionConstant.ROUTE_NAME) ?: FusionConstant.INITIAL_ROUTE
        val routeArguments =
            arguments?.getSerializable(FusionConstant.ROUTE_ARGUMENTS) as? Map<String, Any>
        val restoredHistory =
            savedInstanceState?.getSerializable(FusionConstant.FUSION_RESTORATION_BUNDLE_KEY) as? List<Map<String, Any?>>
        if (restoredHistory != null) {
            history.addAll(restoredHistory)
            engineBinding?.restore(restoredHistory)
        } else {
            Handler(Looper.getMainLooper()).post {
                engineBinding?.push(routeName, routeArguments)
            }
        }
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

    override fun onResume() {
        super.onResume()
        if (isReused) {
            performAttach()
            engineBinding?.latestStyle { systemChromeStyle ->
                updateSystemUiOverlays(systemChromeStyle)
            }
        } else {
            val engine = engineBinding?.engine ?: return
            (this as? FusionMessengerHandler)?.configureFlutterChannel(engine.dartExecutor.binaryMessenger)
        }
    }

    override fun onPause() {
        super.onPause()
        if (isReused) {
            performDetach()
        } else {
            (this as? FusionMessengerHandler)?.releaseFlutterChannel()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        history.clear()
        engineBinding?.pop()
        engineBinding = null
        if (isReused) {
            return
        }
        FusionStackManager.removeChild(this)
    }

    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        outState.putSerializable(
            FusionConstant.FUSION_RESTORATION_BUNDLE_KEY,
            history as? Serializable
        )
    }

    override fun shouldAttachEngineToActivity(): Boolean {
        return !isReused
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
        // 复用情况下自行处理PlatformPlugin
        // 非复用情况下默认处理
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
        // 配置PlatformChannel和CustomChannel是因为其和Activity相关联
        // 而三方插件和Activity无关，一个Engine配置一次即可
        val engine = engineBinding?.engine ?: return
        configurePlatformChannel()
        (activity as? FusionMessengerHandler)?.configureFlutterChannel(engine.dartExecutor.binaryMessenger)
    }

    private fun releaseChannel() {
        releasePlatformChannel()
        (activity as? FusionMessengerHandler)?.releaseFlutterChannel()
    }

    private fun configurePlatformChannel() {
        if (platformPlugin != null) {
            return
        }
        val platformChannel = engineBinding?.engine?.platformChannel ?: return
        platformPlugin = activity?.let { PlatformPlugin(it, platformChannel) } ?: return
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

    internal class FusionFlutterFragmentBuilder(fragmentClass: Class<out FusionFragment>) :
        NewEngineFragmentBuilder(fragmentClass) {

        private var routeName: String = FusionConstant.INITIAL_ROUTE
        private var routeArguments: Map<String, Any>? = null
        private var isReused = false

        fun initialRoute(
            name: String,
            arguments: Map<String, Any>?
        ): FusionFlutterFragmentBuilder {
            routeName = name
            routeArguments = arguments
            return this
        }

        fun reuseMode(isReused: Boolean): FusionFlutterFragmentBuilder {
            this.isReused = isReused
            return this
        }

        override fun createArgs(): Bundle {
            return super.createArgs().also {
                it.putString(FusionConstant.ROUTE_NAME, routeName)
                it.putSerializable(FusionConstant.ROUTE_ARGUMENTS, routeArguments as? Serializable)
                it.putBoolean(FusionConstant.ARG_DESTROY_ENGINE_WITH_FRAGMENT, !isReused)
                it.putBoolean(FusionConstant.REUSE_MODE, isReused)
            }
        }
    }
}