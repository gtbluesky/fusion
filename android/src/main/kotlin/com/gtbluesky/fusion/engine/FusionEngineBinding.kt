package com.gtbluesky.fusion.engine

import com.gtbluesky.fusion.Fusion
import com.gtbluesky.fusion.constant.FusionConstant
import com.gtbluesky.fusion.container.FusionContainer
import com.gtbluesky.fusion.navigator.FusionStackManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.util.*

class FusionEngineBinding(
    private val isNested: Boolean
) {
    private var container: FusionContainer? = null
    private var channel: MethodChannel? = null
    internal var engine: FlutterEngine? = null
    private var eventChannel: EventChannel? = null
    private var eventSink: EventChannel.EventSink? = null
    private val history: List<Map<String, Any?>>
        get() {
            return FusionStackManager.stack.flatMap {
                (it.get() as? FusionContainer)?.history() ?: listOf()
            }
        }

    init {
        engine = if (isNested) {
            Fusion.createAndRunEngine()
        } else {
            Fusion.cachedEngine
        }?.also {
            channel = MethodChannel(it.dartExecutor.binaryMessenger, FusionConstant.FUSION_CHANNEL)
            eventChannel =
                EventChannel(it.dartExecutor.binaryMessenger, FusionConstant.FUSION_EVENT_CHANNEL)
        }
    }

    internal fun attach(container: FusionContainer? = null) {
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
                        if (isNested) {
                            if (container?.history()?.isEmpty() == true) {
                                // 在原Flutter容器打开Flutter页面
                                // 即用户可见的第一个页面
                                container.history().add(
                                    mapOf(
                                        "name" to name,
                                        "arguments" to arguments,
                                        "uniqueId" to UUID.randomUUID().toString(),
                                        "home" to true
                                    )
                                )
                                result.success(container.history())
                            } else {
                                // 在新Flutter容器打开Flutter页面
                                Fusion.delegate.pushFlutterRoute(name, arguments)
                                result.success(null)
                            }
                        } else {
                            // 在原Flutter容器打开Flutter页面
                            val topContainer = FusionStackManager.getTopContainer()
                            if (topContainer !is FusionContainer) {
                                result.success(null)
                                return@setMethodCallHandler
                            }
                            val home = topContainer.history().isEmpty()
                            topContainer.history().add(
                                mapOf(
                                    "name" to name,
                                    "arguments" to arguments,
                                    "uniqueId" to UUID.randomUUID().toString(),
                                    "home" to home
                                )
                            )
                            result.success(history)
                        }
                    } else {
                        // 打开Native页面
                        Fusion.delegate.pushNativeRoute(name, arguments)
                        result.success(null)
                    }
                }
                "replace" -> {
                    if (isNested) {
                        result.success(null)
                        return@setMethodCallHandler
                    }
                    val name = call.argument<String>("name")
                    if (name.isNullOrEmpty()) {
                        result.success(null)
                        return@setMethodCallHandler
                    }
                    val arguments = call.argument<Map<String, Any>?>("arguments")
                    val topContainer = FusionStackManager.getTopContainer()
                    if (topContainer !is FusionContainer) {
                        result.success(null)
                        return@setMethodCallHandler
                    }
                    topContainer.history().removeLast()
                    val home = topContainer.history().isEmpty()
                    topContainer.history().add(
                        mapOf(
                            "name" to name,
                            "arguments" to arguments,
                            "uniqueId" to UUID.randomUUID().toString(),
                            "home" to home
                        )
                    )
                    result.success(history)
                }
                "pop" -> {
                    if (isNested) {
                        if (container?.history()?.isEmpty() == true) {
                            result.success(container.history())
                            detach()
                        } else {
                            // 在flutter页面中点击pop，仅关闭容器
                            FusionStackManager.closeTopContainer()
                            result.success(null)
                        }
                    } else {
                        val topContainer = FusionStackManager.getTopContainer()
                        if (topContainer is FusionContainer) {
                            if (topContainer.history().size == 1) {
                                // 仅关闭flutter容器
                                FusionStackManager.closeTopContainer()
                                result.success(null)
                            } else {
                                // flutter页面pop
                                topContainer.history().removeLast()
                                result.success(history)
                            }
                        } else {
                            // flutter容器关闭后
                            // 仅刷新history，让容器第一个可见Flutter页面出栈
                            result.success(history)
                        }
                    }
                }
                "remove" -> {
                    if (isNested) {
                        result.success(null)
                        return@setMethodCallHandler
                    }
                    val name = call.argument<String>("name")
                    if (name.isNullOrEmpty()) {
                        result.success(null)
                        return@setMethodCallHandler
                    }
                    val topContainer = FusionStackManager.getTopContainer()
                    if (topContainer !is FusionContainer) {
                        result.success(null)
                        return@setMethodCallHandler
                    }
                    val all = call.argument<Boolean>("all") ?: false
                    if (all) {
                        topContainer.history().removeAll {
                            it["name"] == name
                        }
                    } else {
                        val index = topContainer.history().indexOfLast {
                            it["name"] == name
                        }
                        if (index >= 0) {
                            topContainer.history().removeAt(index)
                        }
                    }
                    result.success(history)
                }
                "sendMessage" -> {
                    val msgName = call.argument<String>("msgName")
                    if (msgName.isNullOrEmpty()) {
                        result.success(null)
                        return@setMethodCallHandler
                    }
                    val msgBody = call.argument<MutableMap<String, Any>>("msgBody")
                    FusionStackManager.sendMessage(msgName, msgBody)
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        eventChannel?.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                this@FusionEngineBinding.eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
    }

    internal fun push(name: String, arguments: Map<String, Any>? = null) {
        channel?.invokeMethod(
            "push",
            mapOf(
                "name" to name,
                "arguments" to arguments
            )
        )
    }

    internal fun replace(name: String, arguments: Map<String, Any>?) {
        channel?.invokeMethod(
            "replace",
            mapOf(
                "name" to name,
                "arguments" to arguments
            )
        )
    }

    internal fun pop(active: Boolean = false, result: Any? = null) {
        channel?.invokeMethod(
            "pop",
            mapOf(
                "active" to active,
                "result" to result
            )
        )
    }

    internal fun remove(name: String, all: Boolean) {
        channel?.invokeMethod(
            "remove",
            mapOf(
                "name" to name,
                "all" to all
            )
        )
    }

    internal fun notifyPageVisible() {
        channel?.invokeMethod("notifyPageVisible", null)
    }

    internal fun notifyPageInvisible() {
        channel?.invokeMethod("notifyPageInvisible", null)
    }

    internal fun notifyEnterForeground() {
        channel?.invokeMethod("notifyEnterForeground", null)
    }

    internal fun notifyEnterBackground() {
        channel?.invokeMethod("notifyEnterBackground", null)
    }

    internal fun sendMessage(msg: Map<String, Any?>) {
        eventSink?.success(msg)
    }

    internal fun detach() {
        container = null
        channel?.setMethodCallHandler(null)
        channel = null
        eventChannel?.setStreamHandler(null)
        eventChannel = null
        engine?.destroy()
        engine = null
    }
}