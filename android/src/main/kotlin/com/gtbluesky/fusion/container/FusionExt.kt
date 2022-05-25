package com.gtbluesky.fusion.container

import android.content.Context
import android.content.Intent
import com.gtbluesky.fusion.constant.FusionConstant
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode
import java.io.Serializable

fun <T : FusionContainer> buildFusionIntent(
    context: Context,
    clazz: Class<T>,
    routeName: String,
    routeArguments: Map<String, Any>? = null
): Intent {
    return Intent(context, clazz).also {
        it.putExtra(FusionConstant.EXTRA_BACKGROUND_MODE, BackgroundMode.opaque.name)
        it.putExtra(FusionConstant.EXTRA_DESTROY_ENGINE_WITH_ACTIVITY, false)
        it.putExtra(FusionConstant.ROUTE_NAME, routeName)
        it.putExtra(FusionConstant.ROUTE_ARGUMENTS, routeArguments as? Serializable)
    }
}

@JvmOverloads
fun <T : FusionFragment> buildFragment(
    clazz: Class<T>,
    routeName: String,
    routeArguments: Map<String, Any>? = null
): T {
    return FusionFragment.FusionFlutterFragmentBuilder(clazz)
        .setInitialRoute(routeName, routeArguments)
        .build<T>()
}