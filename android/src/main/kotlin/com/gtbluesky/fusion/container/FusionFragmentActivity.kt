package com.gtbluesky.fusion.container

import android.app.ActivityManager
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import com.gtbluesky.fusion.constant.FusionConstant
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode
import io.flutter.embedding.android.FlutterFragment
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.android.RenderMode
import io.flutter.embedding.android.TransparencyMode

open class FusionFragmentActivity : FlutterFragmentActivity(), FusionContainer {

    private var flutterFragment: FusionFragment? = null

    override fun history() = flutterFragment?.history() ?: mutableListOf()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // 2、Fragment恢复
        if (flutterFragment == null) {
            flutterFragment = supportFragmentManager.findFragmentByTag("flutter_fragment") as? FusionFragment
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            window.statusBarColor = Color.TRANSPARENT
        }
    }

    // 1、Fragment首次创建
    override fun createFlutterFragment(): FlutterFragment {
        val routeName =
            intent.getStringExtra(FusionConstant.ROUTE_NAME) ?: FusionConstant.INITIAL_ROUTE
        val routeArguments =
            intent.getSerializableExtra(FusionConstant.ROUTE_ARGUMENTS) as? Map<String, Any>
        val transparencyMode = if (backgroundMode == BackgroundMode.opaque) {
            TransparencyMode.opaque
        } else {
            TransparencyMode.transparent
        }
        return FusionFragment.FusionFlutterFragmentBuilder(FusionFragment::class.java)
            .initialRoute(routeName, routeArguments)
            .reuseMode(true)
            .renderMode(RenderMode.texture)
            .transparencyMode(transparencyMode)
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