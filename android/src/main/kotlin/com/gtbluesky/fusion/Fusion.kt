package com.gtbluesky.fusion

import android.app.Activity
import android.app.Application
import android.os.Bundle
import com.gtbluesky.fusion.navigator.FusionStackManager
import io.flutter.embedding.engine.FlutterEngineGroup

object Fusion {
    internal lateinit var engineGroup: FlutterEngineGroup
        private set
    internal lateinit var delegate: FusionRouteDelegate
        private set

    fun install(context: Application, delegate: FusionRouteDelegate) {
        engineGroup = FlutterEngineGroup(context)
        this.delegate = delegate
        context.registerActivityLifecycleCallbacks(object : Application.ActivityLifecycleCallbacks {
            override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
                FusionStackManager.add(activity)
            }

            override fun onActivityStarted(activity: Activity) {
            }

            override fun onActivityResumed(activity: Activity) {
                // 处理Activity存在复用的情况
                FusionStackManager.move2Top(activity)
            }

            override fun onActivityPaused(activity: Activity) {
            }

            override fun onActivityStopped(activity: Activity) {
            }

            override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {
            }

            override fun onActivityDestroyed(activity: Activity) {
                FusionStackManager.remove(activity)
            }

        })
    }
}