package com.gtbluesky.fusion.engine

import com.gtbluesky.fusion.Fusion
import com.gtbluesky.fusion.constant.FusionConstant
import com.gtbluesky.fusion.container.FusionContainer
import com.gtbluesky.fusion.navigator.FusionStackManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.systemchannels.PlatformChannel
import io.flutter.plugin.common.MethodChannel
import java.util.*

internal class FusionEngineBinding(
    private val isReused: Boolean
) {
    private var container: FusionContainer? = null
    private var navigationChannel: MethodChannel? = null
    private var notificationChannel: MethodChannel? = null
    private var platformChannel: MethodChannel? = null
    var engine: FlutterEngine? = null
    private val history: List<Map<String, Any?>>
        get() {
            return FusionStackManager.pageStack.flatMap {
                it.get()?.history() ?: listOf()
            }
        }

    init {
        engine = if (!isReused) {
            Fusion.createAndRunEngine()
        } else {
            Fusion.defaultEngine
        }?.also {
            navigationChannel = MethodChannel(it.dartExecutor.binaryMessenger, FusionConstant.FUSION_NAVIGATION_CHANNEL)
            notificationChannel = MethodChannel(it.dartExecutor.binaryMessenger, FusionConstant.FUSION_NOTIFICATION_CHANNEL)
            platformChannel = MethodChannel(it.dartExecutor.binaryMessenger, FusionConstant.FUSION_PLATFORM_CHANNEL)
        }
    }

    fun attach(container: FusionContainer? = null) {
        navigationChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "push" -> {
                    val name = call.argument<String>("name")
                    if (name.isNullOrEmpty()) {
                        result.success(null)
                        return@setMethodCallHandler
                    }
                    val arguments = call.argument<Map<String, Any>?>("arguments")
                    val isFlutterPage = call.argument<Boolean>("flutter") ?: false
                    if (isFlutterPage) {
                        if (!isReused) {
                            if (container?.history()?.isEmpty() == true) {
                                // 在原Flutter容器打开Flutter页面
                                // 即用户可见的第一个页面
                                val pageInfo = mapOf(
                                    "name" to name,
                                    "arguments" to arguments,
                                    "uniqueId" to UUID.randomUUID().toString(),
                                    "home" to true
                                )
                                container.history().add(pageInfo)
                                result.success(pageInfo)
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
                            val pageInfo = mapOf(
                                "name" to name,
                                "arguments" to arguments,
                                "uniqueId" to UUID.randomUUID().toString(),
                                "home" to topContainer.history().isEmpty()
                            )
                            topContainer.history().add(pageInfo)
                            result.success(pageInfo)
                        }
                    } else {
                        // 打开Native页面
                        Fusion.delegate.pushNativeRoute(name, arguments)
                        result.success(null)
                    }
                }
                "replace" -> {
                    if (!isReused) {
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
                    val pageInfo = mapOf(
                        "name" to name,
                        "arguments" to arguments,
                        "uniqueId" to UUID.randomUUID().toString(),
                        "home" to topContainer.history().isEmpty()
                    )
                    topContainer.history().add(pageInfo)
                    result.success(pageInfo)
                }
                "pop" -> {
                    if (!isReused) {
                        if (container?.history()?.isEmpty() == true) {
                            result.success(true)
                            detach()
                        } else {
                            // 在flutter页面中点击pop，仅关闭容器
                            FusionStackManager.closeTopContainer()
                            result.success(false)
                        }
                    } else {
                        val topContainer = FusionStackManager.getTopContainer()
                        if (topContainer is FusionContainer) {
                            if (topContainer.history().size == 1) {
                                // 关闭flutter容器
                                FusionStackManager.closeTopContainer()
                                result.success(false)
                            } else {
                                // flutter页面pop
                                topContainer.history().removeLast()
                                result.success(true)
                            }
                        } else {
                            result.success(false)
                        }
                    }
                }
                "remove" -> {
                    if (!isReused) {
                        result.success(false)
                        return@setMethodCallHandler
                    }
                    val name = call.argument<String>("name")
                    if (name.isNullOrEmpty()) {
                        result.success(false)
                        return@setMethodCallHandler
                    }
                    val topContainer = FusionStackManager.getTopContainer()
                    if (topContainer !is FusionContainer) {
                        result.success(false)
                        return@setMethodCallHandler
                    }
                    val index = topContainer.history().indexOfLast {
                        it["name"] == name
                    }
                    if (index >= 0) {
                        topContainer.history().removeAt(index)
                    }
                    result.success(true)
                }
                "restoreHistory" -> {
                    if (isReused) {
                        result.success(history)
                    } else {
                        result.success(null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        notificationChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
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
    }

    fun push(name: String, arguments: Map<String, Any>? = null) {
        navigationChannel?.invokeMethod(
            "push",
            mapOf(
                "name" to name,
                "arguments" to arguments
            )
        )
    }

    fun replace(name: String, arguments: Map<String, Any>?) {
        navigationChannel?.invokeMethod(
            "replace",
            mapOf(
                "name" to name,
                "arguments" to arguments
            )
        )
    }

    fun pop(active: Boolean = false, result: Any? = null) {
        navigationChannel?.invokeMethod(
            "pop",
            mapOf(
                "active" to active,
                "result" to result
            )
        )
    }

    fun remove(name: String) {
        navigationChannel?.invokeMethod(
            "remove",
            mapOf(
                "name" to name,
            )
        )
    }

    fun restore(history: List<Map<String, Any?>>) {
        navigationChannel?.invokeMethod(
            "restore",
            history
        )
    }

    fun notifyPageVisible() {
        notificationChannel?.invokeMethod("notifyPageVisible", null)
    }

    fun notifyPageInvisible() {
        notificationChannel?.invokeMethod("notifyPageInvisible", null)
    }

    fun notifyEnterForeground() {
        notificationChannel?.invokeMethod("notifyEnterForeground", null)
    }

    fun notifyEnterBackground() {
        notificationChannel?.invokeMethod("notifyEnterBackground", null)
    }

    fun onReceive(msg: Map<String, Any?>) {
        notificationChannel?.invokeMethod("onReceive", msg)
    }

    fun latestStyle(callback: (systemChromeStyle: PlatformChannel.SystemChromeStyle) -> Unit) {
        platformChannel?.invokeMethod("latestStyle", null, object : MethodChannel.Result {
            override fun success(result: Any?) {
                val systemChromeStyle = decodeSystemChromeStyle(result as? Map<String, Any>)
                    ?: return
                callback(systemChromeStyle)
            }

            override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {}

            override fun notImplemented() {}

        })
    }

    private fun decodeSystemChromeStyle(styleMap: Map<String, Any>?): PlatformChannel.SystemChromeStyle? {
        if (styleMap == null) {
            return null
        }
        val statusBarColor = styleMap["statusBarColor"] as? Int
        val statusBarIconBrightness =
            if (styleMap["statusBarIconBrightness"] == "Brightness.light") {
                PlatformChannel.Brightness.LIGHT
            } else {
                PlatformChannel.Brightness.DARK
            }
        val systemStatusBarContrastEnforced =
            styleMap["systemStatusBarContrastEnforced"] as? Boolean
        val systemNavigationBarColor = styleMap["systemNavigationBarColor"] as? Int
        val systemNavigationBarIconBrightness =
            if (styleMap["systemNavigationBarIconBrightness"] == "Brightness.light") {
                PlatformChannel.Brightness.LIGHT
            } else {
                PlatformChannel.Brightness.DARK
            }
        val systemNavigationBarDividerColor = styleMap["systemNavigationBarDividerColor"] as? Int
        val systemNavigationBarContrastEnforced =
            styleMap["systemNavigationBarContrastEnforced"] as? Boolean
        return PlatformChannel.SystemChromeStyle(
            statusBarColor,
            statusBarIconBrightness,
            systemStatusBarContrastEnforced,
            systemNavigationBarColor,
            systemNavigationBarIconBrightness,
            systemNavigationBarDividerColor,
            systemNavigationBarContrastEnforced
        )
    }

    fun detach() {
        container = null
        navigationChannel?.setMethodCallHandler(null)
        navigationChannel = null
        notificationChannel?.setMethodCallHandler(null)
        notificationChannel = null
        platformChannel = null
        engine?.destroy()
        engine = null
    }
}