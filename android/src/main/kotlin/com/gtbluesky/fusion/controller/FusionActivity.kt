package com.gtbluesky.fusion.controller

import android.content.Context
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import com.gtbluesky.fusion.constant.FusionConstant
import com.gtbluesky.fusion.engine.FusionEngineBinding
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

open class FusionActivity : FlutterActivity() {

    private lateinit var engineBinding: FusionEngineBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        val routeName =
            intent.getStringExtra(FusionConstant.ROUTE_NAME) ?: FusionConstant.INITIAL_ROUTE
        val routeArguments =
            intent.getSerializableExtra(FusionConstant.ROUTE_ARGUMENTS) as? Map<String, Any>
        engineBinding = FusionEngineBinding(context, routeName, routeArguments)
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
}