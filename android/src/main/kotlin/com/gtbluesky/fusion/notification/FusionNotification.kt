package com.gtbluesky.fusion.notification

import java.lang.ref.WeakReference

interface FusionNotificationListener {
    fun onReceive(name: String, body: Map<String, Any>?)
}

object FusionNotificationBinding {
    private val listeners = mutableListOf<WeakReference<FusionNotificationListener>>()

    fun register(listener: FusionNotificationListener) {
        unregister(listener)
        listeners.add(WeakReference(listener))
    }

    fun unregister(listener: FusionNotificationListener) {
        listeners.removeAll {
            it.get() == listener || it.get() == null
        }
    }

    internal fun dispatchMessage(name: String, body: Map<String, Any>?) {
        listeners.forEach {
            it.get()?.onReceive(name, body)
        }
    }
}

enum class FusionNotificationType {
    FLUTTER,
    NATIVE,
    GLOBAL
}