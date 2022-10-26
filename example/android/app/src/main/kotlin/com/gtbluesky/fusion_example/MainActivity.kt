package com.gtbluesky.fusion_example

import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.GravityCompat
import com.gtbluesky.fusion.container.buildFusionFragment
import com.gtbluesky.fusion.navigator.FusionNavigator
import com.gtbluesky.fusion.notification.PageNotificationListener
import com.gtbluesky.fusion_example.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity(), PageNotificationListener {
    private lateinit var activityMainBinding: ActivityMainBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        activityMainBinding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(activityMainBinding.root)
        val flutterFragment = buildFusionFragment(CustomFusionFragment::class.java, "/lifecycle")
        supportFragmentManager.beginTransaction()
            .replace(activityMainBinding.flutterLayout.id, flutterFragment).commit()
        setListener()
    }

    private fun setListener() {
        activityMainBinding.tvFlutterActivity.setOnClickListener {
            FusionNavigator.open("/lifecycle", mapOf("title" to "Android Flutter Page"))
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
        activityMainBinding.tvFlutterFragment.setOnClickListener {
            startActivity(Intent(this, FragmentSceneActivity::class.java))
        }
        activityMainBinding.tvFlutterDrawer.setOnClickListener {
            activityMainBinding.drawerLayout.openDrawer(GravityCompat.START)
        }
    }

    override fun onReceive(msgName: String, msgBody: Map<String, Any>?) {
        Toast.makeText(this, "onReceive: msgName=$msgName, msgBody=$msgBody", Toast.LENGTH_SHORT)
            .show()
    }
}