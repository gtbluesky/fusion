package com.gtbluesky.fusion_example

import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.GravityCompat
import com.gtbluesky.fusion.container.buildFusionFragment
import com.gtbluesky.fusion.navigator.FusionNavigator
import com.gtbluesky.fusion.notification.FusionNotificationBinding
import com.gtbluesky.fusion.notification.FusionNotificationListener
import com.gtbluesky.fusion_example.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity(), FusionNotificationListener {
    private lateinit var activityMainBinding: ActivityMainBinding
    private var hasOpened = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        activityMainBinding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(activityMainBinding.root)
        setListener()
        FusionNotificationBinding.register(this)
    }

    private fun setListener() {
        activityMainBinding.tvFlutterActivity.setOnClickListener {
            FusionNavigator.open("/test", mapOf("title" to "Android Flutter Page"))
        }
        activityMainBinding.tvTransparentFlutterActivity.setOnClickListener {
            FusionNavigator.open(
                "/transparent",
                mapOf(
                    "title" to "Transparent Flutter Page",
                    "transparent" to true
                )
            )
        }
        activityMainBinding.tvFlutterViewpager.setOnClickListener {
            startActivity(Intent(this, ViewPagerSceneActivity::class.java))
        }
        activityMainBinding.tvFlutterTab.setOnClickListener {
            startActivity(Intent(this, TabSceneActivity::class.java))
        }
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

    override fun onReceive(name: String, body: Map<String, Any>?) {
        Toast.makeText(this, "onReceive: name=$name, body=$body", Toast.LENGTH_SHORT)
            .show()
    }

    override fun onDestroy() {
        super.onDestroy()
        FusionNotificationBinding.unregister(this)
    }
}