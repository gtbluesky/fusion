package com.gtbluesky.fusion.container

import android.content.Context
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import com.gtbluesky.fusion.Fusion
import com.gtbluesky.fusion.constant.FusionConstant
import com.gtbluesky.fusion.engine.FusionEngineBinding
import io.flutter.embedding.android.FlutterFragment
import io.flutter.embedding.android.FlutterFragmentActivity

open class FusionFragmentActivity : FlutterFragmentActivity(), FusionContainer {

    private val history = mutableListOf<Map<String, Any?>>()
    private var engineBinding: FusionEngineBinding? = null

    override fun provideFlutterEngine(context: Context) = engineBinding?.engine

    override fun onCreate(savedInstanceState: Bundle?) {
        engineBinding = Fusion.engineBinding
        val routeName =
            intent.getStringExtra(FusionConstant.ROUTE_NAME) ?: FusionConstant.INITIAL_ROUTE
        val routeArguments =
            intent.getSerializableExtra(FusionConstant.ROUTE_ARGUMENTS) as? Map<String, Any>
        engineBinding?.push(routeName, routeArguments)
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            window.statusBarColor = Color.TRANSPARENT
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        engineBinding?.pop()
        engineBinding = null
    }

    override fun createFlutterFragment(): FlutterFragment {
        return FusionFragment.FusionFlutterFragmentBuilder(FusionFragment::class.java)
            .setNestMode(false)
            .build<FusionFragment>()
    }

    override fun history() = history
}