package com.gtbluesky.fusion.controller

import android.content.Context
import android.content.Intent
import com.gtbluesky.fusion.constant.FusionConstant
import io.flutter.embedding.android.FlutterActivity
import java.io.Serializable

fun <T : FusionActivity> buildFusionIntent(
    context: Context,
    clz: Class<T>,
    routeName: String,
    routeArguments: Map<String, Any>? = null
): Intent {
    return FlutterActivity.NewEngineIntentBuilder(clz).build(context).also {
        it.putExtra(FusionConstant.ROUTE_NAME, routeName)
        it.putExtra(FusionConstant.ROUTE_ARGUMENTS, routeArguments as Serializable)
    }
}