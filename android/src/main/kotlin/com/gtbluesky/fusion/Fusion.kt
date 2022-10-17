package com.gtbluesky.fusion

import android.app.Activity
import android.app.Application
import android.os.Bundle
import android.os.Looper
import androidx.annotation.UiThread
import com.gtbluesky.fusion.constant.FusionConstant
import com.gtbluesky.fusion.container.FusionContainer
import com.gtbluesky.fusion.engine.FusionEngineBinding
import com.gtbluesky.fusion.navigator.FusionStackManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineGroup
import io.flutter.embedding.engine.dart.DartExecutor

object Fusion {
    var engineGroup: FlutterEngineGroup? = null
        private set
    var defaultEngine: FlutterEngine? = null
        private set
    internal var engineBinding: FusionEngineBinding? = null
        private set
    internal lateinit var delegate: FusionRouteDelegate
        private set
    private lateinit var context: Application
    private var lifecycleCallback: Application.ActivityLifecycleCallbacks? = null

    @UiThread
    fun install(context: Application, delegate: FusionRouteDelegate) {
        if (Looper.myLooper() != Looper.getMainLooper()) {
            throw RuntimeException(
                "Methods marked with @UiThread must be executed on the main thread. Current thread: ${Thread.currentThread().name}"
            )
        }
        this.context = context
        this.delegate = delegate
        engineGroup = FlutterEngineGroup(context)
        defaultEngine = createAndRunEngine(FusionConstant.REUSE_MODE)
        engineBinding = FusionEngineBinding(true)
        engineBinding?.attach()
        lifecycleCallback = FusionLifecycleCallbacks()
        context.registerActivityLifecycleCallbacks(lifecycleCallback)
    }

    @UiThread
    fun uninstall() {
        context.unregisterActivityLifecycleCallbacks(lifecycleCallback)
        lifecycleCallback = null
        engineBinding?.detach()
        engineBinding = null
        engineGroup = null
        defaultEngine = null
    }

    @UiThread
    fun createAndRunEngine(initialRoute: String = FusionConstant.INITIAL_ROUTE): FlutterEngine? {
        return engineGroup?.createAndRunEngine(
            context,
            DartExecutor.DartEntrypoint.createDefault(),
            initialRoute
        )
    }
}

internal class FusionLifecycleCallbacks : Application.ActivityLifecycleCallbacks {

    private var visibleActivityCount = 0
    private var isActivityChangingConfigurations = false

    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
        FusionStackManager.add(activity)
    }

    override fun onActivityStarted(activity: Activity) {
        if (++visibleActivityCount == 1 && !isActivityChangingConfigurations) {
            FusionStackManager.notifyEnterForeground()
        }
        if (activity is FusionContainer) {
            Fusion.engineBinding?.notifyPageVisible()
        }
    }

    override fun onActivityResumed(activity: Activity) {
        // 处理Activity存在复用的情况
        FusionStackManager.move2Top(activity)
    }

    override fun onActivityPaused(activity: Activity) {
    }

    override fun onActivityStopped(activity: Activity) {
        isActivityChangingConfigurations = activity.isChangingConfigurations
        if (--visibleActivityCount == 0 && !isActivityChangingConfigurations) {
            FusionStackManager.notifyEnterBackground()
        }
        if (activity is FusionContainer) {
            Fusion.engineBinding?.notifyPageInvisible()
        }
    }

    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {
    }

    override fun onActivityDestroyed(activity: Activity) {
        FusionStackManager.remove(activity)
    }

}