package com.gtbluesky.fusion.engine

import com.gtbluesky.fusion.Fusion
import com.gtbluesky.fusion.constant.FusionConstant
import com.gtbluesky.fusion.navigator.FusionStackManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.systemchannels.PlatformChannel
import io.flutter.plugin.common.MethodChannel
import java.util.*

internal class FusionEngineBinding(var engine: FlutterEngine?) {
    private var navigationChannel: MethodChannel? = null
    private var notificationChannel: MethodChannel? = null
    private var platformChannel: MethodChannel? = null
    private val historyList: List<Map<String, Any?>>
        get() {
            return FusionStackManager.containerStack.map {
                mapOf(
                    "uniqueId" to it.get()?.uniqueId(),
                    "history" to it.get()?.history()
                )
            }
        }

    init {
        engine?.let {
            navigationChannel = MethodChannel(
                it.dartExecutor.binaryMessenger,
                FusionConstant.FUSION_NAVIGATION_CHANNEL
            )
            notificationChannel = MethodChannel(
                it.dartExecutor.binaryMessenger,
                FusionConstant.FUSION_NOTIFICATION_CHANNEL
            )
            platformChannel = MethodChannel(
                it.dartExecutor.binaryMessenger,
                FusionConstant.FUSION_PLATFORM_CHANNEL
            )
        }
    }

    fun attach() {
        navigationChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "open" -> {
                    val name = call.argument<String>("name")
                    if (name == null) {
                        result.success(null)
                        return@setMethodCallHandler
                    }
                    val arguments = call.argument<Map<String, Any>?>("arguments")
                    Fusion.delegate.pushFlutterRoute(name, arguments)
                    result.success(null)
                }
                "push" -> {
                    val name = call.argument<String>("name")
                    if (name == null) {
                        result.success(null)
                        return@setMethodCallHandler
                    }
                    val arguments = call.argument<Map<String, Any>?>("arguments")
                    Fusion.delegate.pushNativeRoute(name, arguments)
                    result.success(null)
                }
                "destroy" -> {
                    val uniqueId = call.argument<String>("uniqueId")
                    if (uniqueId == null) {
                        result.success(false)
                        return@setMethodCallHandler
                    }
                    val container = FusionStackManager.findContainer(uniqueId)
                    if (container != null) {
                        FusionStackManager.closeContainer(container)
                        result.success(true)
                    } else {
                        result.success(false)
                    }
                }
                "restore" -> {
                    result.success(historyList)
                }
                "sync" -> {
                    val uniqueId = call.argument<String>("uniqueId")
                    val pages = call.argument<List<Map<String, Any?>>>("pages")
                    if (uniqueId == null || pages == null) {
                        result.success(false)
                        return@setMethodCallHandler
                    }
                    FusionStackManager.findContainer(uniqueId)?.history()?.let {
                        it.clear()
                        it.addAll(pages)
                    }
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        notificationChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "sendMessage" -> {
                    val name = call.argument<String>("name")
                    if (name == null) {
                        result.success(null)
                        return@setMethodCallHandler
                    }
                    val body = call.argument<MutableMap<String, Any>>("body")
                    FusionStackManager.sendMessage(name, body)
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    // external function
    fun push(name: String, arguments: Map<String, Any>?) {
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

    fun pop(result: Any?) {
        navigationChannel?.invokeMethod(
            "pop",
            mapOf(
                "result" to result
            ),
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

    // internal function
    fun open(uniqueId: String, name: String, arguments: Map<String, Any>? = null) {
        navigationChannel?.invokeMethod(
            "open",
            mapOf(
                "uniqueId" to uniqueId,
                "name" to name,
                "arguments" to arguments
            )
        )
    }

    fun switchTop(uniqueId: String) {
        navigationChannel?.invokeMethod(
            "switchTop",
            mapOf(
                "uniqueId" to uniqueId,
            )
        )
    }

    /**
     * Restore the specified container in flutter side
     * @param uniqueId: container's uniqueId
     * @param history: container's history
     */
    fun restore(uniqueId: String, history: List<Map<String, Any?>>) {
        navigationChannel?.invokeMethod(
            "restore",
            mapOf(
                "uniqueId" to uniqueId,
                "history" to history,
            )
        )
    }

    /**
     * Destroy the specified container in flutter side
     * @param uniqueId: container's uniqueId
     */
    fun destroy(uniqueId: String) {
        navigationChannel?.invokeMethod(
            "destroy",
            mapOf(
                "uniqueId" to uniqueId,
            )
        )
    }

    fun notifyPageVisible(uniqueId: String) {
        notificationChannel?.invokeMethod(
            "notifyPageVisible",
            mapOf(
                "uniqueId" to uniqueId,
            )
        )
    }

    fun notifyPageInvisible(uniqueId: String) {
        notificationChannel?.invokeMethod(
            "notifyPageInvisible",
            mapOf(
                "uniqueId" to uniqueId,
            )
        )
    }

    fun notifyEnterForeground() {
        notificationChannel?.invokeMethod("notifyEnterForeground", null)
    }

    fun notifyEnterBackground() {
        notificationChannel?.invokeMethod("notifyEnterBackground", null)
    }

    fun dispatchMessage(msg: Map<String, Any?>) {
        notificationChannel?.invokeMethod("dispatchMessage", msg)
    }

    @Suppress("UNCHECKED_CAST")
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
        navigationChannel?.setMethodCallHandler(null)
        navigationChannel = null
        notificationChannel?.setMethodCallHandler(null)
        notificationChannel = null
        platformChannel = null
        engine?.destroy()
        engine = null
    }
}