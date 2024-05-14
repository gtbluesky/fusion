package com.gtbluesky.fusion.event

import com.gtbluesky.fusion.Fusion

typealias FusionEventCallback = (Map<String, Any>?) -> Unit

object FusionEventManager {
    private val callbackMap = mutableMapOf<String, MutableSet<FusionEventCallback>>()

    fun register(event: String, callback: FusionEventCallback) {
        val callbacks = callbackMap[event] ?: mutableSetOf()
        callbacks.add(callback)
        callbackMap[event] = callbacks
    }

    @JvmOverloads
    fun unregister(event: String, callback: FusionEventCallback? = null) {
        if (callback == null) {
            callbackMap.remove(event)
        } else {
            callbackMap[event]?.remove(callback)
        }
    }

    @JvmOverloads
    fun send(
        event: String,
        args: Map<String, Any>? = null,
        type: FusionEventType = FusionEventType.GLOBAL
    ) {
        when (type) {
            FusionEventType.FLUTTER -> {
                Fusion.engineBinding?.dispatchEvent(event, args)
            }

            FusionEventType.NATIVE -> {
                dispatchEvent(event, args)
            }

            FusionEventType.GLOBAL -> {
                dispatchEvent(event, args)
                Fusion.engineBinding?.dispatchEvent(event, args)
            }
        }
    }

    private fun dispatchEvent(name: String, args: Map<String, Any>?) {
        val callbacks = callbackMap[name]
        callbacks?.forEach { callback ->
            callback(args)
        }
    }
}

enum class FusionEventType {
    FLUTTER,
    NATIVE,
    GLOBAL
}