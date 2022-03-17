package com.gtbluesky.fusion_example

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.gtbluesky.fusion.navigator.FusionNavigator
import com.gtbluesky.fusion_example.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity() {
    private lateinit var activityMainBinding: ActivityMainBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        activityMainBinding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(activityMainBinding.root)
        activityMainBinding.tvFlutterActivity.setOnClickListener {
            FusionNavigator.push("/test", mapOf("title" to "Android Flutter Page"))
        }
        activityMainBinding.tvFlutterFragment.setOnClickListener {
            startActivity(Intent(this, FragmentSceneActivity::class.java))
        }
    }
}