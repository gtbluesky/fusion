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
import com.gtbluesky.fusion.Fusion
import com.gtbluesky.fusion.constant.FusionConstant
import com.gtbluesky.fusion.handler.FusionMessengerHandler
import io.flutter.embedding.android.*
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.platform.PlatformPlugin
import java.io.Serializable
import java.util.*

open class FusionFragment : FlutterFragment(), FusionContainer {
    private val history = mutableListOf<Map<String, Any?>>()
    private var maskView: View? = null
    private var flutterView: FlutterView? = null
    private var isAttached = false
    private var uniqueId = "container_${UUID.randomUUID()}"
    private var engineBinding = Fusion.engineBinding
    private var platformPlugin: PlatformPlugin? = null

    override fun uniqueId() = uniqueId

    override fun history() = history

    override fun isTransparent() = transparencyMode.name == TransparencyMode.transparent.name

    override fun isAttached() = isAttached

    override fun removeMask() {
        maskView?.let {
            it.postDelayed({
                (it.parent as? FrameLayout)?.removeView(it)
            }, 100)
        }
        maskView = null
    }

    @Suppress("UNCHECKED_CAST")
    private fun attachToContainer() {
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
        // Attach rendering pipeline.
        flutterView?.attachToFlutterEngine(engine)
        // 配置PlatformChannel和CustomChannel是因为其和Activity相关联
        // 而三方插件和Activity无关，一个Engine配置一次即可
        // Configure platform channel
        if (platformPlugin == null) {
            val platformChannel = engineBinding?.engine?.platformChannel ?: return
            platformPlugin = activity?.let { PlatformPlugin(it, platformChannel, this) } ?: return
        }
        // Configure custom channel
        if (activity is FusionFragmentActivity) {
            (activity as? FusionMessengerHandler)?.configureFlutterChannel(engine.dartExecutor.binaryMessenger)
        } else {
            (this as? FusionMessengerHandler)?.configureFlutterChannel(engine.dartExecutor.binaryMessenger)
        }
    }

    override fun detachFromContainer() {
        if (!isAttached) return
        isAttached = false
        val engine = engineBinding?.engine ?: return
        // Plugins are no longer attached to the activity.
        engine.activityControlSurface.detachFromActivity()
        // Detach rendering pipeline.
        flutterView?.detachFromFlutterEngine()
        // Fixed since 3.0 stable
        flutterView?.forEach {
            if (it is FlutterImageView) {
                flutterView?.removeView(it)
            }
        }
        // Release platform channel
        platformPlugin?.destroy()
        platformPlugin = null
        // Release custom channel
        (activity as? FusionMessengerHandler)?.releaseFlutterChannel()
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
                top?.detachFromContainer()
            }
        } else {
            if (top != this) {
                top?.detachFromContainer()
            }
        }
        // 切换Flutter容器和页面及原生容器栈的顺序
        if (activity is FusionFragmentActivity) {
            FusionStackManager.add(activity as FusionContainer)
        } else {
            FusionStackManager.add(this)
        }
        engineBinding?.switchTop(uniqueId) {
            this.attachToContainer()
            this.updateSystemOverlayStyle()
        }
        engineBinding?.notifyPageVisible(uniqueId)
    }

    private fun updateSystemOverlayStyle() {
        engineBinding?.checkStyle { systemChromeStyle ->
            try {
                val field = platformPlugin?.javaClass?.getDeclaredField("currentTheme")
                field?.isAccessible = true
                field?.set(platformPlugin, systemChromeStyle)
            } catch (e: Exception) {
                e.printStackTrace()
            }
            platformPlugin?.updateSystemUiOverlays()
        }
    }

    private fun onContainerInvisible() {
        engineBinding?.notifyPageInvisible(uniqueId)
    }

    private fun onContainerDestroy() {
        detachFromContainer()
        history.clear()
        if (activity is FusionFragmentActivity) {
            FusionStackManager.remove(activity as FusionContainer)
        } else {
            FusionStackManager.remove(this)
        }
        engineBinding?.destroy(uniqueId)
    }

    @Suppress("UNCHECKED_CAST")
    override fun onCreate(savedInstanceState: Bundle?) {
        // Detach
        val top = FusionStackManager.getTopContainer()
        if (activity is FusionFragmentActivity) {
            if (top != activity) {
                top?.detachFromContainer()
            }
        } else {
            if (top != this) {
                top?.detachFromContainer()
            }
        }
        super.onCreate(savedInstanceState)
        val routeName =
            arguments?.getString(FusionConstant.ROUTE_NAME) ?: FusionConstant.INITIAL_ROUTE
        val routeArgs =
            arguments?.getSerializable(FusionConstant.ROUTE_ARGS) as? Map<String, Any>
        savedInstanceState?.getString(FusionConstant.FUSION_RESTORATION_UNIQUE_ID_KEY)?.let {
            uniqueId = it
        }
        val restoredHistory =
            savedInstanceState?.getSerializable(FusionConstant.FUSION_RESTORATION_HISTORY_KEY) as? List<Map<String, Any>>
        if (restoredHistory == null) {
            engineBinding?.create(uniqueId, routeName, routeArgs)
        } else {
            engineBinding?.restore(uniqueId, restoredHistory)
        }
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

    /**
     * Fragment Hide & Show 时调用
     * 首个Fragment显示时不调用
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
        if (!isHidden && userVisibleHint) {
            onContainerVisible()
        }
    }

    override fun onPause() {
        super.onPause()
        if (!isHidden && userVisibleHint) {
            onContainerInvisible()
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        onContainerDestroy()
    }

    override fun onDetach() {
        super.onDetach()
        if (FusionStackManager.isEmpty()) {
            engineBinding?.engine?.lifecycleChannel?.appIsPaused()
        }
        engineBinding = null
    }

    override fun onBackPressed() {
        engineBinding?.maybePop(null)
    }

    override fun shouldAttachEngineToActivity() = false

    override fun shouldDispatchAppLifecycleState() = false

    override fun attachToEngineAutomatically() = false

    override fun detachFromFlutterEngine() {}

    override fun provideFlutterEngine(context: Context) = engineBinding?.engine

    override fun providePlatformPlugin(
        activity: Activity?,
        flutterEngine: FlutterEngine
    ): PlatformPlugin? = null

    internal class FusionFlutterFragmentBuilder(fragmentClass: Class<out FusionFragment>) :
        NewEngineFragmentBuilder(fragmentClass) {
        private var routeName: String = FusionConstant.INITIAL_ROUTE
        private var routeArgs: Map<String, Any>? = null

        @ColorInt
        private var backgroundColor = Color.WHITE

        fun initialRoute(
            name: String,
            args: Map<String, Any>?
        ): FusionFlutterFragmentBuilder {
            routeName = name
            routeArgs = args
            return this
        }

        fun backgroundColor(@ColorInt color: Int): FusionFlutterFragmentBuilder {
            backgroundColor = color
            return this
        }

        override fun createArgs(): Bundle {
            return super.createArgs().also {
                it.putString(FusionConstant.ROUTE_NAME, routeName)
                it.putSerializable(FusionConstant.ROUTE_ARGS, routeArgs as? Serializable)
                it.putBoolean(FusionConstant.ARG_DESTROY_ENGINE_WITH_FRAGMENT, false)
                it.putInt(FusionConstant.EXTRA_BACKGROUND_COLOR, backgroundColor)
            }
        }
    }
}