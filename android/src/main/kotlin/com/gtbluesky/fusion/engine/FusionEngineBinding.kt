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
import java.util.*

class FusionEngineBinding(
    context: Context,
    private val childMode: Boolean,
    routeName: String,
    routeArguments: Map<String, Any>?
) {
    private var channel: MethodChannel? = null
    internal val engine: FlutterEngine
    private val history = mutableListOf<Map<String, Any?>>()

    init {
        // Flutter 页面唯一标识符
        val uniqueId = UUID.randomUUID().toString()
        val uriBuilder = Uri.parse(routeName).buildUpon()
        routeArguments?.forEach {
            uriBuilder.appendQueryParameter(it.key, it.value.toString())
        }
        uriBuilder.appendQueryParameter("uniqueId", uniqueId)
        history.add(
            mapOf(
                "name" to routeName,
                "arguments" to routeArguments,
                "uniqueId" to uniqueId
            )
        )
        val routeUri = uriBuilder.build().toString()
        engine = Fusion.engineGroup.createAndRunEngine(
            context,
            DartExecutor.DartEntrypoint.createDefault(),
            routeUri
        )
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
                    if (name.isNullOrEmpty()) {
                        result.success(null)
                        return@setMethodCallHandler
                    }
                    val arguments = call.argument<Map<String, Any>?>("arguments")
                    val isFlutterPage = call.argument<Boolean>("isFlutterPage") ?: false
                    if (isFlutterPage) {
                        if (childMode) {
                            //在新Flutter容器打开Flutter页面
                            Fusion.delegate.pushFlutterRoute(name, arguments)
                            result.success(null)
                        } else {
                            //在原Flutter容器打开Flutter页面
                            history.add(mapOf(
                                "name" to name,
                                "arguments" to arguments,
                                "uniqueId" to UUID.randomUUID().toString()
                            ))
                            result.success(history)
                        }
                    } else {
                        //打开Native页面
                        Fusion.delegate.pushNativeRoute(name, arguments)
                        result.success(null)
                    }
                }
                "pop" -> {
                    if (history.size > 1) {
                        history.removeLast()
                        result.success(history)
                    } else {
                        FusionStackManager.closeTopContainer()
                        result.success(null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    fun notifyPageVisible() {
        channel?.invokeMethod("onPageVisible", null)
    }

    fun notifyPageInvisible() {
        channel?.invokeMethod("onPageInvisible", null)
    }

    fun notifyEnterForeground() {
        channel?.invokeMethod("onForeground", null)
    }

    fun notifyEnterBackground() {
        channel?.invokeMethod("onBackground", null)
    }

    fun detach() {
        channel?.setMethodCallHandler(null)
        channel = null
    }
}