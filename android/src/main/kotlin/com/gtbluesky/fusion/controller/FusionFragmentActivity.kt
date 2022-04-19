package com.gtbluesky.fusion.controller

import android.content.Context
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import com.gtbluesky.fusion.constant.FusionConstant
import com.gtbluesky.fusion.engine.FusionEngineBinding
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

open class FusionFragmentActivity : FlutterFragmentActivity(), FusionContainer {

    private lateinit var engineBinding: FusionEngineBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        val routeName =
            intent.getStringExtra(FusionConstant.ROUTE_NAME) ?: FusionConstant.INITIAL_ROUTE
        val routeArguments =
            intent.getSerializableExtra(FusionConstant.ROUTE_ARGUMENTS) as? Map<String, Any>
        engineBinding = FusionEngineBinding(this, false, routeName, routeArguments)
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            window.statusBarColor = Color.TRANSPARENT
        }
    }

    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        return engineBinding.engine
    }

    override fun provideEngineBinding(): FusionEngineBinding {
        return engineBinding
    }

    override fun onDestroy() {
        super.onDestroy()
        engineBinding.detach()
    }
}