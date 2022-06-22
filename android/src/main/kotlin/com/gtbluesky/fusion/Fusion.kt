package com.gtbluesky.fusion

import android.app.Activity
import android.app.Application
import android.os.Bundle
import com.gtbluesky.fusion.controller.FusionActivity
import com.gtbluesky.fusion.controller.FusionContainer
import com.gtbluesky.fusion.navigator.FusionStackManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineGroup
import io.flutter.embedding.engine.dart.DartExecutor

object Fusion {
    internal lateinit var engineGroup: FlutterEngineGroup
        private set
    internal lateinit var delegate: FusionRouteDelegate
        private set
    private var cachedEngine: FlutterEngine? = null

    fun install(context: Application, delegate: FusionRouteDelegate) {
        engineGroup = FlutterEngineGroup(context).apply {
            cachedEngine = createAndRunEngine(
                context,
                DartExecutor.DartEntrypoint.createDefault()
            )
        }
        this.delegate = delegate
        context.registerActivityLifecycleCallbacks(FusionLifecycleCallbacks())
    }
}

internal class FusionLifecycleCallbacks : Application.ActivityLifecycleCallbacks {

    private var activityReferences = 0
    private var isActivityChangingConfigurations = false

    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
        FusionStackManager.add(activity)
    }

    override fun onActivityStarted(activity: Activity) {
        if (++activityReferences == 1 && !isActivityChangingConfigurations) {
            FusionStackManager.notifyEnterForeground()
        } else if (activity is FusionContainer) {
            activity.provideEngineBinding().notifyPageVisible()
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
        if (--activityReferences == 0 && !isActivityChangingConfigurations) {
            FusionStackManager.notifyEnterBackground()
        } else if (activity is FusionContainer) {
            activity.provideEngineBinding().notifyPageInvisible()
        }
    }

    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {
    }

    override fun onActivityDestroyed(activity: Activity) {
        FusionStackManager.remove(activity)
    }

}