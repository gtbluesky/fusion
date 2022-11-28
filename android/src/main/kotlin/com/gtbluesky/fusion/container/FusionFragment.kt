package com.gtbluesky.fusion.container

import android.app.Activity
import android.content.Context
import android.graphics.Color
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.annotation.ColorInt
import androidx.core.view.forEach
import com.gtbluesky.fusion.Fusion
import com.gtbluesky.fusion.constant.FusionConstant
import com.gtbluesky.fusion.handler.FusionMessengerHandler
import com.gtbluesky.fusion.navigator.FusionStackManager
import io.flutter.embedding.android.*
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.systemchannels.PlatformChannel
import io.flutter.plugin.platform.PlatformPlugin
import java.io.Serializable
import java.util.*

open class FusionFragment : FlutterFragment(), FusionContainer {

    private val history = mutableListOf<Map<String, Any?>>()
    private var platformPlugin: PlatformPlugin? = null
    private var maskView: View? = null
    private var flutterView: FlutterView? = null
    private var isAttached = false
    internal var uniqueId = "container_${UUID.randomUUID()}"
    private var engineBinding = Fusion.engineBinding

    override fun uniqueId() = uniqueId

    override fun history() = history

    override fun isTransparent() = transparencyMode.name == TransparencyMode.transparent.name

    @Suppress("UNCHECKED_CAST")
    override fun onCreate(savedInstanceState: Bundle?) {
        // detach
        val top = FusionStackManager.getTopContainer()
        if (activity is FusionFragmentActivity) {
            if (top != activity) {
                top?.detachFromEngine()
            }
        } else {
            if (top != this) {
                top?.detachFromEngine()
            }
        }
        super.onCreate(savedInstanceState)
        val routeName =
            arguments?.getString(FusionConstant.ROUTE_NAME) ?: FusionConstant.INITIAL_ROUTE
        val routeArguments =
            arguments?.getSerializable(FusionConstant.ROUTE_ARGUMENTS) as? Map<String, Any>
        savedInstanceState?.getString(FusionConstant.FUSION_RESTORATION_UNIQUE_ID_KEY)?.let {
            uniqueId = it
        }
        val restoredHistory =
            savedInstanceState?.getSerializable(FusionConstant.FUSION_RESTORATION_HISTORY_KEY) as? List<Map<String, Any>>
        if (restoredHistory == null) {
            engineBinding?.open(uniqueId, routeName, routeArguments)
        } else {
            engineBinding?.restore(uniqueId, restoredHistory)
        }
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        var view = super.onCreateView(inflater, container, savedInstanceState)
        flutterView = findFlutterView(view)
        flutterView?.detachFromFlutterEngine()
        // Fix the visibility bug from 3.0
        if (view == flutterView) {
            view = FrameLayout(context).also {
                it.addView(flutterView)
            }
        }
        onContainerCreate()
        return view
    }

    override fun removeMaskView() {
        maskView?.let {
            (it.parent as? FrameLayout)?.removeView(it)
        }
    }

    /**
     * Fragment Hide & Show 时调用
     */
    override fun onHiddenChanged(hidden: Boolean) {
        super.onHiddenChanged(hidden)
        if (flutterView == null) return
        if (hidden) {
            onContainerInvisible()
        } else {
            onContainerVisible()
        }
    }

    /**
     * 用于ViewPager切换Fragment时的判断
     * ViewPager2则直接通过onResume和onPause判断
     */
    @Deprecated("Deprecated in Java")
    override fun setUserVisibleHint(isVisibleToUser: Boolean) {
        super.setUserVisibleHint(isVisibleToUser)
        if (flutterView == null) return
        if (isVisibleToUser) {
            onContainerVisible()
        } else {
            onContainerInvisible()
        }
    }

    override fun onResume() {
        super.onResume()
        if (!isHidden) {
            onContainerVisible()
        }
        engineBinding?.latestStyle { systemChromeStyle ->
            updateSystemUiOverlays(systemChromeStyle)
        }
    }

    override fun onPause() {
        super.onPause()
        onContainerInvisible()
        engineBinding?.engine?.lifecycleChannel?.appIsResumed()
    }

    override fun onStop() {
        super.onStop()
        engineBinding?.engine?.lifecycleChannel?.appIsResumed()
    }

    override fun onDetach() {
        super.onDetach()
        if (FusionStackManager.isEmpty()) {
            engineBinding?.engine?.lifecycleChannel?.appIsPaused()
        } else {
            engineBinding?.engine?.lifecycleChannel?.appIsResumed()
        }
        engineBinding = null
    }

    override fun onDestroy() {
        super.onDestroy()
        onContainerDestroy()
    }

    private fun onContainerCreate() {
        val frameLayout = flutterView?.parent as? FrameLayout
        if (frameLayout != null && !isTransparent()) {
            val backgroundColor =
                arguments?.getInt(FusionConstant.EXTRA_BACKGROUND_COLOR) ?: Color.WHITE
            maskView = View(context)
            maskView?.setBackgroundColor(backgroundColor)
            frameLayout.addView(maskView)
        }
        if (FusionStackManager.isEmpty()) {
            engineBinding?.engine?.lifecycleChannel?.appIsResumed()
        }
        if (activity is FusionFragmentActivity) {
            FusionStackManager.add(activity as FusionContainer)
        } else {
            FusionStackManager.add(this)
        }
    }

    private fun onContainerVisible() {
        val top = FusionStackManager.getTopContainer()
        if (activity is FusionFragmentActivity) {
            if (top != activity) {
                top?.detachFromEngine()
            }
        } else {
            if (top != this) {
                top?.detachFromEngine()
            }
        }
        //切换Flutter容器和页面及原生容器栈的顺序
        if (activity is FusionFragmentActivity) {
            FusionStackManager.add(activity as FusionContainer)
        } else {
            FusionStackManager.add(this)
        }
        engineBinding?.switchTop(uniqueId)
        engineBinding?.notifyPageVisible(uniqueId)
        performAttach()
    }

    private fun onContainerInvisible() {
        engineBinding?.notifyPageInvisible(uniqueId)
    }

    private fun onContainerDestroy() {
        performDetach()
        history.clear()
        if (activity is FusionFragmentActivity) {
            FusionStackManager.remove(activity as FusionContainer)
        } else {
            FusionStackManager.remove(this)
        }
        engineBinding?.destroy(uniqueId)
    }

    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        outState.putString(
            FusionConstant.FUSION_RESTORATION_UNIQUE_ID_KEY,
            uniqueId
        )
        outState.putSerializable(
            FusionConstant.FUSION_RESTORATION_HISTORY_KEY,
            history as? Serializable
        )
    }

    override fun shouldAttachEngineToActivity() = false

    override fun shouldDispatchAppLifecycleState() = false

    @Suppress("UNCHECKED_CAST")
    private fun performAttach() {
        if (isAttached) return
        isAttached = true
        val engine = engineBinding?.engine ?: return
        // Attach plugins to the activity.
        try {
            val delegateField = findFlutterFragmentClass().getDeclaredField("delegate")
            delegateField.isAccessible = true
            (delegateField.get(this) as? ExclusiveAppComponent<Activity>)?.let {
                engine.activityControlSurface.attachToActivity(
                    it,
                    lifecycle
                )
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        configureChannel()
        // Attach rendering pipeline.
        flutterView?.attachToFlutterEngine(engine)
    }

    private fun performDetach() {
        if (!isAttached) return
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
        (activity as? FusionMessengerHandler)?.configureFlutterChannel(engine.dartExecutor.binaryMessenger)
    }

    private fun releaseChannel() {
        releasePlatformChannel()
        (activity as? FusionMessengerHandler)?.releaseFlutterChannel()
    }

    private fun configurePlatformChannel() {
        if (platformPlugin != null) return
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
        @ColorInt
        private var backgroundColor = Color.WHITE

        fun initialRoute(
            name: String,
            arguments: Map<String, Any>?
        ): FusionFlutterFragmentBuilder {
            routeName = name
            routeArguments = arguments
            return this
        }

        fun backgroundColor(@ColorInt color: Int): FusionFlutterFragmentBuilder {
            backgroundColor = color
            return this
        }

        override fun createArgs(): Bundle {
            return super.createArgs().also {
                it.putString(FusionConstant.ROUTE_NAME, routeName)
                it.putSerializable(FusionConstant.ROUTE_ARGUMENTS, routeArguments as? Serializable)
                it.putBoolean(FusionConstant.ARG_DESTROY_ENGINE_WITH_FRAGMENT, false)
                it.putInt(FusionConstant.EXTRA_BACKGROUND_COLOR, backgroundColor)
            }
        }
    }
}