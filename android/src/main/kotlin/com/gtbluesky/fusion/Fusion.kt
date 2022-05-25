package com.gtbluesky.fusion

import android.app.Activity
import android.app.Application
import android.net.Uri
import android.os.Bundle
import com.gtbluesky.fusion.constant.FusionConstant
import com.gtbluesky.fusion.container.FusionContainer
import com.gtbluesky.fusion.engine.FusionEngineBinding
import com.gtbluesky.fusion.navigator.FusionStackManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineGroup
import io.flutter.embedding.engine.dart.DartExecutor
import java.util.*

object Fusion {
    private var engineGroup: FlutterEngineGroup? = null
    internal var cachedEngine: FlutterEngine? = null
        private set
    internal var engineBinding: FusionEngineBinding? = null
        private set
    internal lateinit var delegate: FusionRouteDelegate
        private set
    private lateinit var context: Application

    fun install(context: Application, delegate: FusionRouteDelegate) {
        this.context = context
        this.delegate = delegate
        engineGroup = FlutterEngineGroup(context)
        cachedEngine = createAndRunEngine()
        engineBinding = FusionEngineBinding(false)
        engineBinding?.attach()
        context.registerActivityLifecycleCallbacks(FusionLifecycleCallbacks())
    }

    fun uninstall() {
        engineBinding?.detach()
        engineBinding = null
        engineGroup = null
        cachedEngine = null
    }

    fun createAndRunEngine(): FlutterEngine? {
        return engineGroup?.createAndRunEngine(
            context,
            DartExecutor.DartEntrypoint.createDefault(),
            initialRouteUri()
        )
    }

    private fun initialRouteUri(): String {
        val uniqueId = UUID.randomUUID().toString()
        val uriBuilder = Uri.parse(FusionConstant.INITIAL_ROUTE).buildUpon()
        uriBuilder.appendQueryParameter("uniqueId", uniqueId)
        return uriBuilder.build().toString()
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
        if (--activityReferences == 0 && !isActivityChangingConfigurations) {
            FusionStackManager.notifyEnterBackground()
        } else if (activity is FusionContainer) {
            Fusion.engineBinding?.notifyPageInvisible()
        }
    }

    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {
    }

    override fun onActivityDestroyed(activity: Activity) {
        FusionStackManager.remove(activity)
    }

}