package com.gtbluesky.fusion.navigator

import android.app.Activity
import com.gtbluesky.fusion.Fusion
import java.lang.ref.WeakReference
import kotlin.collections.ArrayList

object FusionStackManager {
    private val stack = ArrayList<WeakReference<Activity>>()

    fun getTopActivity(): Activity? {
        if (stack.isEmpty()) return null
        return stack.last().get()
    }

    internal fun add(activity: Activity) {
        stack.add(WeakReference(activity))
    }

    internal fun remove(activity: Activity) {
        stack.forEach {
            if (it.get() == activity) {
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

        } else {
            Fusion.delegate.pushNativeRoute(name, arguments)
        }
    }

    internal fun pop() {

    }
}