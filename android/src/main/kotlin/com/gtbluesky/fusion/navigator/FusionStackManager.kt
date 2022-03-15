package com.gtbluesky.fusion.navigator

import android.app.Activity
import com.gtbluesky.fusion.Fusion
import java.lang.ref.WeakReference

object FusionStackManager {
    private val stack = ArrayList<FusionPageModel>()

    private fun getTopPage(): FusionPageModel? {
        if (stack.isEmpty()) return null
        return stack.last()
    }

    internal fun add(activity: Activity) {
        stack.add(FusionPageModel(WeakReference(activity)))
    }

    internal fun remove(activity: Activity) {
        stack.forEach {
            if (it.nativePage.get() == activity) {
                stack.remove(it)
                return
            }
        }
    }

    internal fun move2Top(activity: Activity) {
        remove(activity)
        add(activity)
    }

    /**
     * 表示打开的是Flutter页面，Native测只需同步Flutter栈信息
     * 表示打开的是Native页面
     */
    internal fun push(name: String?, arguments: Map<String, Any>?) {
        if (arguments?.get("flutter") != null) {
            name?.takeIf { it.isNotEmpty() }?.let {
                getTopPage()?.flutterPages?.add(it)
            }
        } else {
            Fusion.delegate.pushNativeRoute(name, arguments)
        }
    }

    internal fun pop() {
        if (getTopPage()?.flutterPages?.size ?: 0 > 1) {
            getTopPage()?.flutterPages?.removeLast()
        } else {
            getTopPage()?.nativePage?.get()?.finish()
        }
    }
}