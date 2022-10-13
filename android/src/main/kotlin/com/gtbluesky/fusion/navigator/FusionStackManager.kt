package com.gtbluesky.fusion.navigator

import android.app.Activity
import com.gtbluesky.fusion.Fusion
import com.gtbluesky.fusion.container.FusionContainer
import com.gtbluesky.fusion.notification.PageNotificationListener
import java.lang.ref.WeakReference

internal object FusionStackManager {
    val stack = mutableListOf<WeakReference<Activity>>()
    private val childPageStack = mutableListOf<WeakReference<FusionContainer>>()

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

    fun topIsFusionContainer() = getTopContainer() is FusionContainer

    fun closeTopContainer() {
        getTopContainer()?.finish()
    }

    fun addChild(container: FusionContainer) {
        childPageStack.add(WeakReference(container))
    }

    fun removeChild(container: FusionContainer) {
        childPageStack.removeAll { it.get() == container }
    }

    fun notifyEnterForeground() {
        Fusion.engineBinding?.notifyEnterForeground()
        childPageStack.forEach {
            it.get()?.engineBinding()?.notifyEnterForeground()
        }
    }

    fun notifyEnterBackground() {
        Fusion.engineBinding?.notifyEnterBackground()
        childPageStack.forEach {
            it.get()?.engineBinding()?.notifyEnterBackground()
        }
    }

    fun sendMessage(msgName: String, msgBody: Map<String, Any>?) {
        val msg = mutableMapOf<String, Any?>("msgName" to msgName)
        msg["msgBody"] = msgBody
        Fusion.engineBinding?.sendMessage(msg)
        childPageStack.forEach {
            it.get()?.engineBinding()?.sendMessage(msg)
        }
        // 普通Activity
        stack.forEach {
            (it.get() as? PageNotificationListener)?.onReceive(msgName, msgBody)
        }
    }
}