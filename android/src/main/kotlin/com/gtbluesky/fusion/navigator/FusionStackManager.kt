package com.gtbluesky.fusion.navigator

import android.app.Activity
import android.view.ViewGroup
import androidx.drawerlayout.widget.DrawerLayout
import androidx.fragment.app.Fragment
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

    private fun getTopChildContainer(): FusionContainer? {
        if (childPageStack.isEmpty()) return null
        return childPageStack.last().get()
    }

    fun closeTopContainer() {
        var top = getTopChildContainer()
        // 关闭抽屉
        if (top is Fragment) {
            val frameLayout = top.view?.parent as? ViewGroup
            val drawerLayout = frameLayout?.parent
            if (drawerLayout is DrawerLayout && drawerLayout.isDrawerOpen(frameLayout)) {
                drawerLayout.closeDrawer(frameLayout)
                return
            }
        }
        // 关闭容器
        top = getTopContainer()
        if (top is Activity) {
            top.finish()
            // 透明容器则关闭退出动画
            if (top.isTransparent()) {
                top.overridePendingTransition(0, 0)
            }
            return
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