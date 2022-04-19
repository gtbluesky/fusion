package com.gtbluesky.fusion.controller

import android.content.Context
import android.content.Intent
import com.gtbluesky.fusion.constant.FusionConstant
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode
import java.io.Serializable

fun <T : FusionContainer> buildFusionIntent(
    context: Context,
    clz: Class<T>,
    routeName: String,
    routeArguments: Map<String, Any>? = null
): Intent {
    return Intent(context, clz).also {
        it.putExtra(FusionConstant.EXTRA_INITIAL_ROUTE, FusionConstant.DEFAULT_ENGINE)
        it.putExtra(FusionConstant.EXTRA_BACKGROUND_MODE, BackgroundMode.opaque.name)
        it.putExtra(FusionConstant.EXTRA_DESTROY_ENGINE_WITH_ACTIVITY, true)
        it.putExtra(FusionConstant.ROUTE_NAME, routeName)
        it.putExtra(FusionConstant.ROUTE_ARGUMENTS, routeArguments as? Serializable)
    }
}