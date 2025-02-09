package com.gtbluesky.fusion.container

import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.view.View
import android.view.ViewGroup
import androidx.annotation.ColorInt
import com.gtbluesky.fusion.constant.FusionConstant
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.android.RenderMode
import io.flutter.embedding.android.TransparencyMode
import java.io.Serializable

@JvmOverloads
fun <T : FusionContainer> buildFusionIntent(
    context: Context,
    clazz: Class<T>,
    routeName: String,
    routeArgs: Map<String, Any>? = null,
    transparent: Boolean = false,
    @ColorInt backgroundColor: Int = Color.WHITE
): Intent {
    val backgroundMode = if (transparent) {
        BackgroundMode.transparent
    } else {
        BackgroundMode.opaque
    }
    return Intent(context, clazz).also {
        it.putExtra(FusionConstant.EXTRA_BACKGROUND_MODE, backgroundMode.name)
        it.putExtra(FusionConstant.EXTRA_DESTROY_ENGINE_WITH_ACTIVITY, false)
        it.putExtra(FusionConstant.ROUTE_NAME, routeName)
        it.putExtra(FusionConstant.ROUTE_ARGS, routeArgs as? Serializable)
        it.putExtra(FusionConstant.EXTRA_BACKGROUND_COLOR, backgroundColor)
    }
}

@JvmOverloads
fun <T : FusionFragment> buildFusionFragment(
    clazz: Class<T>,
    routeName: String,
    routeArgs: Map<String, Any>? = null,
    transparent: Boolean = false,
    @ColorInt backgroundColor: Int = Color.WHITE
): T {
    val transparencyMode = if (transparent) {
        TransparencyMode.transparent
    } else {
        TransparencyMode.opaque
    }
    return FusionFragment.FusionFlutterFragmentBuilder(clazz)
        .initialRoute(routeName, routeArgs)
        .backgroundColor(backgroundColor)
        .renderMode(RenderMode.texture)
        .transparencyMode(transparencyMode)
        .build<T>()
}

fun findFlutterView(view: View?): FlutterView? {
    if (view is FlutterView) {
        return view
    }
    if (view is ViewGroup) {
        for (i in 0 until view.childCount) {
            val child = view.getChildAt(i)
            val fv = findFlutterView(child)
            if (fv != null) {
                return fv
            }
        }
    }
    return null
}

/** Performs the given action on each view in this view group. */
inline fun ViewGroup.forEach(action: (view: View) -> Unit) {
    for (index in 0 until childCount) {
        action(getChildAt(index))
    }
}