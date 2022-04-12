package com.gtbluesky.fusion.navigator

import android.app.Activity
import com.gtbluesky.fusion.controller.FusionActivity
import java.lang.ref.WeakReference

internal object FusionStackManager {
    private val stack = mutableListOf<WeakReference<Activity>>()

    private fun getTopContainer(): Activity? {
        if (stack.isEmpty()) return null
        return stack.last().get()
    }

    fun add(activity: Activity) {
        stack.add(WeakReference(activity))
    }

    fun remove(activity: Activity) {
        stack.forEach {
            if (it.get() == activity) {
                stack.remove(it)
                return
            }
        }
    }

    fun move2Top(activity: Activity) {
        stack.forEach {
            if (it.get() == activity) {
                stack.remove(it)
                stack.add(it)
                return
            }
        }
    }

    fun closeTopContainer() {
        getTopContainer()?.finish()
    }

    fun notifyEnterForeground() {
        stack.forEach {
            (it.get() as? FusionActivity)?.engineBinding?.notifyEnterForeground()
        }
    }

    fun notifyEnterBackground() {
        stack.forEach {
            (it.get() as? FusionActivity)?.engineBinding?.notifyEnterBackground()
        }
    }
}