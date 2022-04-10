package com.gtbluesky.fusion.navigator

import android.app.Activity
import com.gtbluesky.fusion.Fusion
import com.gtbluesky.fusion.controller.FusionActivity
import java.lang.ref.WeakReference

internal object FusionStackManager {
    private val stack = ArrayList<FusionPageModel>()

    private fun getTopPage(): FusionPageModel? {
        if (stack.isEmpty()) return null
        return stack.last()
    }

    fun add(activity: Activity) {
        stack.add(FusionPageModel(WeakReference(activity)))
    }

    fun remove(activity: Activity) {
        stack.forEach {
            if (it.nativePage.get() == activity) {
                stack.remove(it)
                return
            }
        }
    }

    fun move2Top(activity: Activity) {
        stack.forEach {
            if (it.nativePage.get() == activity) {
                stack.remove(it)
                stack.add(it)
                return
            }
        }
    }

    /**
     * 0表示打开Native页面
     * 1表示在新Flutter容器打开Flutter页面
     * null表示在原Flutter容器打开Flutter页面，Native只需同步Flutter栈信息
     */
    fun push(name: String?, arguments: MutableMap<String, Any>?) {
        if (name.isNullOrEmpty()) return
        when (arguments?.remove("fusion_push_mode")) {
            0 -> {
                Fusion.delegate.pushNativeRoute(name, arguments)
            }
            1 -> {
                Fusion.delegate.pushFlutterRoute(name, arguments)
            }
            else -> {
                getTopPage()?.flutterPages?.add(name)
            }
        }
    }

    fun pop() {
        if (getTopPage()?.nativePage?.get() is FusionActivity && getTopPage()?.flutterPages?.size ?: 0 > 1) {
            getTopPage()?.flutterPages?.removeLast()
        } else {
            getTopPage()?.nativePage?.get()?.finish()
        }
    }

    fun notifyEnterForeground() {
        stack.forEach {
            (it.nativePage.get() as? FusionActivity)?.engineBinding?.notifyEnterForeground()
        }
    }

    fun notifyEnterBackground() {
        stack.forEach {
            (it.nativePage.get() as? FusionActivity)?.engineBinding?.notifyEnterBackground()
        }
    }
}