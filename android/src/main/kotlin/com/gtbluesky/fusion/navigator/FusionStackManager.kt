package com.gtbluesky.fusion.navigator

import android.app.Activity
import com.gtbluesky.fusion.Fusion
import com.gtbluesky.fusion.container.FusionContainer
import com.gtbluesky.fusion.container.FusionFragment
import com.gtbluesky.fusion.notification.PageNotificationListener
import java.lang.ref.WeakReference

internal object FusionStackManager {
    val pageStack = mutableListOf<WeakReference<FusionContainer>>()
    private val childPageStack = mutableListOf<WeakReference<FusionFragment>>()

    fun add(container: FusionContainer) {
        pageStack.add(WeakReference(container))
    }

    fun remove(container: FusionContainer) {
        pageStack.removeAll {
            it.get() == container || it.get() == null
        }
    }

    fun getTopContainer(): FusionContainer? {
        if (pageStack.isEmpty()) return null
        return pageStack.last().get()
    }

    fun closeTopContainer() {
        val top = getTopContainer()
        if (top is Activity) {
            top.finish()
            // 透明容器则关闭退出动画
            if (top.isTransparent()) {
                top.overridePendingTransition(0, 0)
            }
        }
    }

    fun addChild(container: FusionFragment) {
        childPageStack.add(WeakReference(container))
    }

    fun removeChild(container: FusionFragment) {
        childPageStack.removeAll {
            it.get() == container || it.get() == null
        }
    }

    fun notifyEnterForeground() {
        Fusion.engineBinding?.notifyEnterForeground()
        childPageStack.forEach {
            it.get()?.engineBinding?.notifyEnterForeground()
        }
    }

    fun notifyEnterBackground() {
        Fusion.engineBinding?.notifyEnterBackground()
        childPageStack.forEach {
            it.get()?.engineBinding?.notifyEnterBackground()
        }
    }

    fun sendMessage(msgName: String, msgBody: Map<String, Any>?) {
        val msg = mutableMapOf<String, Any?>("msgName" to msgName)
        msg["msgBody"] = msgBody
        Fusion.engineBinding?.onReceive(msg)
        childPageStack.forEach {
            it.get()?.engineBinding?.onReceive(msg)
        }
        // 普通Activity
        pageStack.forEach {
            (it.get() as? PageNotificationListener)?.onReceive(msgName, msgBody)
        }
    }
}