package com.gtbluesky.fusion.navigator

import android.app.Activity
import android.view.ViewGroup
import androidx.drawerlayout.widget.DrawerLayout
import androidx.fragment.app.Fragment
import com.gtbluesky.fusion.Fusion
import com.gtbluesky.fusion.container.FusionContainer
import com.gtbluesky.fusion.container.FusionFragment
import com.gtbluesky.fusion.notification.FusionNotificationBinding
import java.lang.ref.WeakReference

internal object FusionStackManager {
    val pageStack = mutableListOf<WeakReference<FusionContainer>>()
    private val childPageStack = mutableListOf<WeakReference<FusionFragment>>()

    fun add(container: FusionContainer) {
        remove(container)
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
        removeChild(container)
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

    fun sendMessage(name: String, body: Map<String, Any>?) {
        // Native
        FusionNotificationBinding.dispatchMessage(name, body)
        val msg = mutableMapOf<String, Any?>("name" to name)
        msg["body"] = body
        // Default Engine
        Fusion.engineBinding?.dispatchMessage(msg)
        // Other Engines
        childPageStack.forEach {
            it.get()?.engineBinding?.dispatchMessage(msg)
        }
    }
}