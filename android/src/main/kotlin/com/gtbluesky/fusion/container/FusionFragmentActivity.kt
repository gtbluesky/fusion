package com.gtbluesky.fusion.container

import android.app.ActivityManager
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import com.gtbluesky.fusion.constant.FusionConstant
import io.flutter.embedding.android.FlutterFragment
import io.flutter.embedding.android.FlutterFragmentActivity

open class FusionFragmentActivity : FlutterFragmentActivity(), FusionContainer {

    private var flutterFragment: FusionFragment? = null

    override fun history() = flutterFragment?.history() ?: mutableListOf()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            window.statusBarColor = Color.TRANSPARENT
        }
    }

    override fun createFlutterFragment(): FlutterFragment {
        val routeName =
            intent.getStringExtra(FusionConstant.ROUTE_NAME) ?: FusionConstant.INITIAL_ROUTE
        val routeArguments =
            intent.getSerializableExtra(FusionConstant.ROUTE_ARGUMENTS) as? Map<String, Any>
        return FusionFragment.FusionFlutterFragmentBuilder(FusionFragment::class.java)
            .setInitialRoute(routeName, routeArguments)
            .setReuseMode(true)
            .build<FusionFragment>().also {
                flutterFragment = it
            }
    }

    override fun setTaskDescription(taskDescription: ActivityManager.TaskDescription?) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            if (taskDescription?.label.isNullOrEmpty()) {
                return
            }
        }
        super.setTaskDescription(taskDescription)
    }
}