package com.gtbluesky.fusion.container

import android.app.ActivityManager
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
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

    override fun uniqueId() = flutterFragment?.uniqueId()

    override fun history() = flutterFragment?.history() ?: mutableListOf()

    override fun isTransparent() = backgroundMode.name == BackgroundMode.transparent.name

    override fun isAttached() = flutterFragment?.isAttached() ?: false

    override fun removeMask() {
        flutterFragment?.removeMask()
    }

    override fun detachFromContainer() {
        flutterFragment?.detachFromContainer()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Fragment恢复
        if (flutterFragment == null) {
            flutterFragment =
                supportFragmentManager.findFragmentByTag("flutter_fragment") as? FusionFragment
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            window.statusBarColor = Color.TRANSPARENT
        }
    }

    // Fragment首次创建
    @Suppress("UNCHECKED_CAST")
    override fun createFlutterFragment(): FlutterFragment {
        val routeName =
            intent.getStringExtra(FusionConstant.ROUTE_NAME) ?: FusionConstant.INITIAL_ROUTE
        val routeArgs =
            intent.getSerializableExtra(FusionConstant.ROUTE_ARGS) as? Map<String, Any>
        val transparencyMode = if (backgroundMode == BackgroundMode.opaque) {
            TransparencyMode.opaque
        } else {
            TransparencyMode.transparent
        }
        val backgroundColor = intent.getIntExtra(FusionConstant.EXTRA_BACKGROUND_COLOR, Color.WHITE)
        if (!isTransparent()) {
            window.setBackgroundDrawable(ColorDrawable(backgroundColor))
        }
        return FusionFragment.FusionFlutterFragmentBuilder(FusionFragment::class.java)
            .initialRoute(routeName, routeArgs)
            .backgroundColor(backgroundColor)
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