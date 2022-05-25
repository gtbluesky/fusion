package com.gtbluesky.fusion.container

import android.content.Context
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import com.gtbluesky.fusion.Fusion
import com.gtbluesky.fusion.channel.FusionMessengerProvider
import com.gtbluesky.fusion.constant.FusionConstant
import com.gtbluesky.fusion.engine.FusionEngineBinding
import io.flutter.embedding.android.FlutterActivity

open class FusionActivity : FlutterActivity(), FusionContainer {

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

    override fun detachFromFlutterEngine() {}

    override fun onStart() {
        super.onStart()
        if (this !is FusionMessengerProvider) {
            return
        }
        engineBinding?.engine?.let {
            this.configureFlutterChannel(it.dartExecutor.binaryMessenger)
        }
    }

    override fun onStop() {
        super.onStop()
        if (this !is FusionMessengerProvider) {
            return
        }
        this.releaseFlutterChannel()
    }

    override fun onDestroy() {
        super.onDestroy()
        engineBinding?.pop()
        engineBinding = null
    }

    override fun history() = history
}