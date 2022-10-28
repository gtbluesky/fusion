package com.gtbluesky.fusion.notification

import android.app.Activity
import androidx.fragment.app.Fragment
import java.lang.ref.WeakReference

interface FusionNotificationListener {
    fun onReceive(name: String, body: Map<String, Any>?)
}

object FusionNotificationBinding {
    private val listeners = mutableListOf<WeakReference<FusionNotificationListener>>()

    fun register(listener: FusionNotificationListener) {
        if (listener !is Activity && listener !is Fragment) {
            return
        }
        unregister(listener)
        listeners.add(WeakReference(listener))
    }

    fun unregister(listener: FusionNotificationListener) {
        if (listener !is Activity && listener !is Fragment) {
            return
        }
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