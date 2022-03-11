package com.gtbluesky.fusion.controller

import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import com.gtbluesky.fusion.engine.EngineBinding
import com.gtbluesky.fusion.constant.FusionConstant
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import java.io.Serializable

class FusionActivity : FlutterActivity() {

    private lateinit var engineBinding: EngineBinding

    companion object {
        @JvmStatic
        fun buildIntent(
            context: Context,
            routeName: String,
            routeArguments: Map<String, Any>? = null
        ): Intent {
            return FusionFlutterIntentBuilder(FusionActivity::class.java).setInitialRoute(
                routeName,
                routeArguments
            ).build(context)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        val routeName = intent.getStringExtra(FusionConstant.ROUTE_NAME) ?: FusionConstant.INITIAL_ROUTE
        val routeArguments =
            intent.getSerializableExtra(FusionConstant.ROUTE_ARGUMENTS) as? Map<String, Any>
        engineBinding = EngineBinding(context, routeName, routeArguments).also {
            it.attach()
        }
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            window.statusBarColor = Color.TRANSPARENT
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        engineBinding.detach()
    }

    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        return engineBinding.engine
    }

    private class FusionFlutterIntentBuilder(activityClass: Class<out FusionActivity>) :
        FlutterActivity.NewEngineIntentBuilder(activityClass) {
        private var routeName: String = FusionConstant.INITIAL_ROUTE
        private var routeArguments: Map<String, Any>? = null

        fun setInitialRoute(
            name: String,
            arguments: Map<String, Any>?
        ): FusionFlutterIntentBuilder {
            routeName = name
            routeArguments = arguments
            return this
        }

        override fun build(context: Context): Intent {
            return super.build(context).also {
                it.putExtra(FusionConstant.ROUTE_NAME, routeName)
                it.putExtra(FusionConstant.ROUTE_ARGUMENTS, routeArguments as Serializable)
            }
        }
    }
}