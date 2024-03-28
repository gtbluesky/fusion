package com.gtbluesky.fusion.engine

import com.gtbluesky.fusion.Fusion
import com.gtbluesky.fusion.constant.FusionConstant
import com.gtbluesky.fusion.container.FusionStackManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.systemchannels.PlatformChannel
import io.flutter.embedding.engine.systemchannels.PlatformViewsChannel
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.StandardMessageCodec

internal class FusionEngineBinding(engine: FlutterEngine?) {
    private var hostOpen: BasicMessageChannel<Any>? = null
    private var hostPush: BasicMessageChannel<Any>? = null
    private var hostDestroy: BasicMessageChannel<Any>? = null
    private var hostRestore: BasicMessageChannel<Any>? = null
    private var hostSync: BasicMessageChannel<Any>? = null
    private var hostSendMessage: BasicMessageChannel<Any>? = null
    private var hostRemoveMaskView: BasicMessageChannel<Any>? = null
    private var flutterOpen: BasicMessageChannel<Any>? = null
    private var flutterSwitchTop: BasicMessageChannel<Any>? = null
    private var flutterRestore: BasicMessageChannel<Any>? = null
    private var flutterDestroy: BasicMessageChannel<Any>? = null
    private var flutterPush: BasicMessageChannel<Any>? = null
    private var flutterReplace: BasicMessageChannel<Any>? = null
    private var flutterPop: BasicMessageChannel<Any>? = null
    private var flutterMaybePop: BasicMessageChannel<Any>? = null
    private var flutterRemove: BasicMessageChannel<Any>? = null
    private var flutterNotifyPageVisible: BasicMessageChannel<Any>? = null
    private var flutterNotifyPageInvisible: BasicMessageChannel<Any>? = null
    private var flutterNotifyEnterForeground: BasicMessageChannel<Any>? = null
    private var flutterNotifyEnterBackground: BasicMessageChannel<Any>? = null
    private var flutterDispatchMessage: BasicMessageChannel<Any>? = null
    private var flutterCheckStyle: BasicMessageChannel<Any>? = null

    var engine: FlutterEngine? = null
        private set

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
        this.engine = engine
        engine?.let {
            val binaryMessenger = it.dartExecutor.binaryMessenger
            val messageCodec = StandardMessageCodec.INSTANCE
            hostOpen = BasicMessageChannel(
                binaryMessenger,
                "${FusionConstant.FUSION_CHANNEL}/host/open",
                messageCodec
            )
            hostPush = BasicMessageChannel(
                binaryMessenger,
                "${FusionConstant.FUSION_CHANNEL}/host/push",
                messageCodec
            )
            hostDestroy = BasicMessageChannel(
                binaryMessenger,
                "${FusionConstant.FUSION_CHANNEL}/host/destroy",
                messageCodec
            )
            hostRestore = BasicMessageChannel(
                binaryMessenger,
                "${FusionConstant.FUSION_CHANNEL}/host/restore",
                messageCodec
            )
            hostSync = BasicMessageChannel(
                binaryMessenger,
                "${FusionConstant.FUSION_CHANNEL}/host/sync",
                messageCodec
            )
            hostSendMessage = BasicMessageChannel(
                binaryMessenger,
                "${FusionConstant.FUSION_CHANNEL}/host/sendMessage",
                messageCodec
            )
            hostRemoveMaskView = BasicMessageChannel(
                binaryMessenger,
                "${FusionConstant.FUSION_CHANNEL}/host/removeMaskView",
                messageCodec
            )
            flutterOpen = BasicMessageChannel(
                binaryMessenger,
                "${FusionConstant.FUSION_CHANNEL}/flutter/open",
                messageCodec
            )
            flutterSwitchTop = BasicMessageChannel(
                binaryMessenger,
                "${FusionConstant.FUSION_CHANNEL}/flutter/switchTop",
                messageCodec
            )
            flutterRestore = BasicMessageChannel(
                binaryMessenger,
                "${FusionConstant.FUSION_CHANNEL}/flutter/restore",
                messageCodec
            )
            flutterDestroy = BasicMessageChannel(
                binaryMessenger,
                "${FusionConstant.FUSION_CHANNEL}/flutter/destroy",
                messageCodec
            )
            flutterPush = BasicMessageChannel(
                binaryMessenger,
                "${FusionConstant.FUSION_CHANNEL}/flutter/push",
                messageCodec
            )
            flutterReplace = BasicMessageChannel(
                binaryMessenger,
                "${FusionConstant.FUSION_CHANNEL}/flutter/replace",
                messageCodec
            )
            flutterPop = BasicMessageChannel(
                binaryMessenger,
                "${FusionConstant.FUSION_CHANNEL}/flutter/pop",
                messageCodec
            )
            flutterMaybePop = BasicMessageChannel(
                binaryMessenger,
                "${FusionConstant.FUSION_CHANNEL}/flutter/maybePop",
                messageCodec
            )
            flutterRemove = BasicMessageChannel(
                binaryMessenger,
                "${FusionConstant.FUSION_CHANNEL}/flutter/remove",
                messageCodec
            )
            flutterNotifyPageVisible = BasicMessageChannel(
                binaryMessenger,
                "${FusionConstant.FUSION_CHANNEL}/flutter/notifyPageVisible",
                messageCodec
            )
            flutterNotifyPageInvisible = BasicMessageChannel(
                binaryMessenger,
                "${FusionConstant.FUSION_CHANNEL}/flutter/notifyPageInvisible",
                messageCodec
            )
            flutterNotifyEnterForeground = BasicMessageChannel(
                binaryMessenger,
                "${FusionConstant.FUSION_CHANNEL}/flutter/notifyEnterForeground",
                messageCodec
            )
            flutterNotifyEnterBackground = BasicMessageChannel(
                binaryMessenger,
                "${FusionConstant.FUSION_CHANNEL}/flutter/notifyEnterBackground",
                messageCodec
            )
            flutterDispatchMessage = BasicMessageChannel(
                binaryMessenger,
                "${FusionConstant.FUSION_CHANNEL}/flutter/dispatchMessage",
                messageCodec
            )
            flutterCheckStyle = BasicMessageChannel(
                binaryMessenger,
                "${FusionConstant.FUSION_CHANNEL}/flutter/checkStyle",
                messageCodec
            )
        }
    }

    @Suppress("UNCHECKED_CAST")
    fun attach() {
        hostOpen?.setMessageHandler { message, reply ->
            if (message !is Map<*, *>) {
                reply.reply(null)
                return@setMessageHandler
            }
            val name = message["name"] as? String
            if (name == null) {
                reply.reply(null)
                return@setMessageHandler
            }
            val args = message["args"] as? Map<String, Any>
            Fusion.delegate.pushFlutterRoute(name, args)
            reply.reply(null)
        }
        hostPush?.setMessageHandler { message, reply ->
            if (message !is Map<*, *>) {
                reply.reply(null)
                return@setMessageHandler
            }
            val name = message["name"] as? String
            if (name == null) {
                reply.reply(null)
                return@setMessageHandler
            }
            val args = message["args"] as? Map<String, Any>
            Fusion.delegate.pushNativeRoute(name, args)
            reply.reply(null)
        }
        hostDestroy?.setMessageHandler { message, reply ->
            if (message !is Map<*, *>) {
                reply.reply(null)
                return@setMessageHandler
            }
            val uniqueId = message["uniqueId"] as? String
            if (uniqueId == null) {
                reply.reply(false)
                return@setMessageHandler
            }
            val container = FusionStackManager.findContainer(uniqueId)
            if (container != null) {
                FusionStackManager.closeContainer(container)
                reply.reply(true)
            } else {
                reply.reply(false)
            }
        }
        hostRestore?.setMessageHandler { _, reply ->
            reply.reply(historyList)
        }
        hostSync?.setMessageHandler { message, reply ->
            if (message !is Map<*, *>) {
                reply.reply(null)
                return@setMessageHandler
            }
            val uniqueId = message["uniqueId"] as? String
            val history = message["history"] as? List<Map<String, Any?>>
            if (uniqueId == null || history == null) {
                reply.reply(false)
                return@setMessageHandler
            }
            FusionStackManager.findContainer(uniqueId)?.history()?.let {
                it.clear()
                it.addAll(history)
            }
            reply.reply(true)
        }
        hostSendMessage?.setMessageHandler { message, reply ->
            if (message !is Map<*, *>) {
                reply.reply(null)
                return@setMessageHandler
            }
            val name = message["name"] as? String
            if (name == null) {
                reply.reply(null)
                return@setMessageHandler
            }
            val body = message["body"] as? Map<String, Any>
            FusionStackManager.sendMessage(name, body)
            reply.reply(null)
        }
        hostRemoveMaskView?.setMessageHandler { message, reply ->
            if (message !is Map<*, *>) {
                reply.reply(null)
                return@setMessageHandler
            }
            val uniqueId = message["uniqueId"] as? String
            if (uniqueId == null) {
                reply.reply(null)
                return@setMessageHandler
            }
            FusionStackManager.findContainer(uniqueId)?.removeMask()
            reply.reply(null)
        }
    }

    // external function
    fun push(name: String, args: Map<String, Any>?) {
        flutterPush?.send(
            mapOf(
                "name" to name,
                "args" to args
            )
        )
    }

    fun replace(name: String, args: Map<String, Any>?) {
        flutterReplace?.send(
            mapOf(
                "name" to name,
                "args" to args
            )
        )
    }

    fun pop(result: Any?) {
        flutterPop?.send(
            mapOf(
                "result" to result
            )
        )
    }

    fun maybePop(result: Any?) {
        flutterMaybePop?.send(
            mapOf(
                "result" to result
            )
        )
    }

    fun remove(name: String) {
        flutterRemove?.send(
            mapOf(
                "name" to name,
            )
        )
    }

    // internal function
    fun open(uniqueId: String, name: String, args: Map<String, Any>? = null) {
        flutterOpen?.send(
            mapOf(
                "uniqueId" to uniqueId,
                "name" to name,
                "args" to args
            )
        )
    }

    fun switchTop(uniqueId: String) {
        flutterSwitchTop?.send(
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
        flutterRestore?.send(
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
        if (!FusionStackManager.isAttached()) {
            engine?.let {
                try {
                    val platformViewsChannelField = it.platformViewsController.javaClass.getDeclaredField("platformViewsChannel")
                    platformViewsChannelField.isAccessible = true
                    val platformViewsChannel = PlatformViewsChannel(it.dartExecutor)
                    platformViewsChannelField.set(it.platformViewsController, platformViewsChannel)
                    val channelHandlerField = it.platformViewsController.javaClass.getDeclaredField("channelHandler")
                    channelHandlerField.isAccessible = true
                    val channelHandler = channelHandlerField.get(it.platformViewsController) as? PlatformViewsChannel.PlatformViewsHandler
                    platformViewsChannel.setPlatformViewsHandler(channelHandler)
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }
        flutterDestroy?.send(
            mapOf(
                "uniqueId" to uniqueId,
            )
        )
    }

    fun notifyPageVisible(uniqueId: String) {
        flutterNotifyPageVisible?.send(
            mapOf(
                "uniqueId" to uniqueId,
            )
        )
    }

    fun notifyPageInvisible(uniqueId: String) {
        flutterNotifyPageInvisible?.send(
            mapOf(
                "uniqueId" to uniqueId,
            )
        )
    }

    fun notifyEnterForeground() {
        flutterNotifyEnterForeground?.send(null)
    }

    fun notifyEnterBackground() {
        flutterNotifyEnterBackground?.send(null)
    }

    fun dispatchMessage(msg: Map<String, Any?>) {
        flutterDispatchMessage?.send(msg)
    }

    @Suppress("UNCHECKED_CAST")
    fun checkStyle(callback: (systemChromeStyle: PlatformChannel.SystemChromeStyle) -> Unit) {
        flutterCheckStyle?.send(null) {
            val systemChromeStyle = decodeSystemChromeStyle(it as? Map<String, Any>)
                ?: return@send
            callback(systemChromeStyle)
        }
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
        hostOpen?.setMessageHandler(null)
        hostOpen = null
        hostPush?.setMessageHandler(null)
        hostPush = null
        hostDestroy?.setMessageHandler(null)
        hostDestroy = null
        hostRestore?.setMessageHandler(null)
        hostRestore = null
        hostSync?.setMessageHandler(null)
        hostSync = null
        hostSendMessage?.setMessageHandler(null)
        hostSendMessage = null
        hostRemoveMaskView?.setMessageHandler(null)
        hostRemoveMaskView = null
        flutterOpen = null
        flutterSwitchTop = null
        flutterRestore = null
        flutterDestroy = null
        flutterPush = null
        flutterReplace = null
        flutterPop = null
        flutterMaybePop = null
        flutterRemove = null
        flutterNotifyPageVisible = null
        flutterNotifyPageInvisible = null
        flutterNotifyEnterForeground = null
        flutterNotifyEnterBackground = null
        flutterDispatchMessage = null
        flutterCheckStyle = null
        engine?.destroy()
        engine = null
    }
}