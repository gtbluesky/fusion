package com.gtbluesky.fusion.navigator

import android.app.Activity
import com.gtbluesky.fusion.Fusion
import com.gtbluesky.fusion.container.FusionContainer
import com.gtbluesky.fusion.notification.PageNotificationListener
import java.lang.ref.WeakReference

internal object FusionStackManager {
    val stack = mutableListOf<WeakReference<Activity>>()
    private val nestedStack = mutableListOf<WeakReference<FusionContainer>>()

    fun add(activity: Activity) {
        stack.add(WeakReference(activity))
    }

    fun remove(activity: Activity) {
        stack.removeAll { it.get() == activity }
    }

    fun move2Top(activity: Activity) {
        remove(activity)
        add(activity)
    }

    fun getTopContainer(): Activity? {
        if (stack.isEmpty()) return null
        return stack.last().get()
    }

    fun closeTopContainer() {
        getTopContainer()?.finish()
    }

    fun addChild(container: FusionContainer) {
        nestedStack.add(WeakReference(container))
    }

    fun removeChild(container: FusionContainer) {
        nestedStack.removeAll { it.get() == container }
    }

    fun notifyEnterForeground() {
        Fusion.engineBinding?.notifyEnterForeground()
        nestedStack.forEach {
            it.get()?.engineBinding()?.notifyEnterForeground()
        }
    }

    fun notifyEnterBackground() {
        Fusion.engineBinding?.notifyEnterBackground()
        nestedStack.forEach {
            it.get()?.engineBinding()?.notifyEnterBackground()
        }
    }

    fun sendMessage(msgName: String, msgBody: Map<String, Any>?) {
        val msg = mutableMapOf<String, Any?>("msgName" to msgName)
        msg["msgBody"] = msgBody
        Fusion.engineBinding?.sendMessage(msg)
        nestedStack.forEach {
            it.get()?.engineBinding()?.sendMessage(msg)
        }
        // 普通Activity
        stack.forEach {
            (it.get() as? PageNotificationListener)?.onReceive(msgName, msgBody)
        }
    }
}