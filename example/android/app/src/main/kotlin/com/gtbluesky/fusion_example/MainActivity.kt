package com.gtbluesky.fusion_example

import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.GravityCompat
import com.gtbluesky.fusion.container.buildFusionFragment
import com.gtbluesky.fusion.navigator.FusionNavigator
import com.gtbluesky.fusion.navigator.FusionRouteType
import com.gtbluesky.fusion.event.FusionEventManager
import com.gtbluesky.fusion_example.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity() {
    private lateinit var activityMainBinding: ActivityMainBinding
    private var hasOpened = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        activityMainBinding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(activityMainBinding.root)
        setListener()
        FusionEventManager.register("custom_event", ::onReceive)
    }

    private fun onReceive(args: Map<String, Any>?) {
        Toast.makeText(
            this,
            "onReceive: args=$args",
            Toast.LENGTH_SHORT
        ).show()
    }

    private fun setListener() {
        activityMainBinding.tvFlutterActivity.setOnClickListener {
            FusionNavigator.push(
                "/index",
                mapOf(
                    "title" to "Android Flutter Page"
                ),
                FusionRouteType.ADAPTION
            )
        }
        activityMainBinding.tvTransparentFlutterActivity.setOnClickListener {
            FusionNavigator.push(
                "/transparent",
                mapOf(
                    "title" to "Transparent Flutter Page",
                    "transparent" to true
                ),
                FusionRouteType.FLUTTER_WITH_CONTAINER
            )
        }
        activityMainBinding.tvFlutterTab.setOnClickListener {
            FusionNavigator.push(
                "/native_tab_fixed",
                routeType = FusionRouteType.NATIVE
            )
        }
//        activityMainBinding.tvFlutterViewpager.setOnClickListener {
//            FusionNavigator.push(
//                "/native_tab_sliding",
//                routeType = FusionRouteType.NATIVE
//            )
//        }
        activityMainBinding.tvFlutterDrawer.setOnClickListener {
            if (!hasOpened) {
                hasOpened = true
                val flutterFragment =
                    buildFusionFragment(CustomFusionFragment::class.java, "/lifecycle")
                supportFragmentManager.beginTransaction()
                    .replace(activityMainBinding.flutterLayout.id, flutterFragment).commit()
            }
            activityMainBinding.drawerLayout.openDrawer(GravityCompat.START)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        FusionEventManager.unregister("custom_event")
    }
}