package com.gtbluesky.fusion.navigator

import android.app.Activity
import com.gtbluesky.fusion.controller.FusionContainer
import com.gtbluesky.fusion.notification.PageNotificationListener
import java.lang.ref.WeakReference

internal object FusionStackManager {
    private val stack = mutableListOf<WeakReference<Activity>>()
    private val childPageStack = mutableListOf<WeakReference<FusionContainer>>()

    private fun getTopContainer(): Activity? {
        if (stack.isEmpty()) return null
        return stack.last().get()
    }

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
        stack.forEach {
            (it.get() as? FusionContainer)?.provideEngineBinding()?.notifyEnterForeground()
        }
    }

    fun notifyEnterBackground() {
        stack.forEach {
            (it.get() as? FusionContainer)?.provideEngineBinding()?.notifyEnterBackground()
        }
    }

    fun sendMessage(msgName: String, msgBody: Map<String, Any>?) {
        val msg = mutableMapOf<String, Any?>("msgName" to msgName)
        msg["msgBody"] = msgBody
        stack.forEach {
            (it.get() as? FusionContainer)?.provideEngineBinding()?.sendMessage(msg)
            (it.get() as? PageNotificationListener)?.onReceive(msgName, msgBody)
        }
        childPageStack.forEach {
            it.get()?.provideEngineBinding()?.sendMessage(msg)
        }
    }
}