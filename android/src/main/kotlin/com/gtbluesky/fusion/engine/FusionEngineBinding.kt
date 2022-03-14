package com.gtbluesky.fusion.engine

import android.content.Context
import android.net.Uri
import com.gtbluesky.fusion.Fusion
import com.gtbluesky.fusion.channel.FusionMessengerProvider
import com.gtbluesky.fusion.constant.FusionConstant
import com.gtbluesky.fusion.navigator.FusionStackManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

internal class FusionEngineBinding(
    context: Context,
    routeName: String,
    routeArguments: Map<String, Any>?
) {
    private var channel: MethodChannel? = null
    internal val engine: FlutterEngine
    init {
        val uriBuilder = Uri.parse(routeName).buildUpon()
        routeArguments?.forEach {
            uriBuilder.appendQueryParameter(it.key, it.value.toString())
        }
        val routeUri = uriBuilder.build().toString()
        engine = Fusion.engineGroup.createAndRunEngine(context, DartExecutor.DartEntrypoint.createDefault(), routeUri)
        channel = MethodChannel(engine.dartExecutor.binaryMessenger, FusionConstant.FUSION_CHANNEL)
        attach()
        if (context is FusionMessengerProvider) {
            context.configureFlutterChannel(engine.dartExecutor.binaryMessenger)
        }
    }

    private fun attach() {
        channel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "push" -> {
                    val name = call.argument<String>("name")
                    val arguments = call.argument<Map<String, Any>?>("arguments")
                    FusionStackManager.push(name, arguments)
                    result.success(null)
                }
                "pop" -> {
                    FusionStackManager.pop()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    fun detach() {
        channel?.setMethodCallHandler(null)
        channel = null
    }
}