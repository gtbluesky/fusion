package com.gtbluesky.fusion_example

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.gtbluesky.fusion.navigator.FusionNavigator
import com.gtbluesky.fusion_example.databinding.ActivityNormalBinding

class NormalActivity : AppCompatActivity() {
    private lateinit var binding: ActivityNormalBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityNormalBinding.inflate(layoutInflater)
        setContentView(binding.root)
        val title = intent.getStringExtra("title")
        binding.tvA.text = "title=$title"
        binding.tvB.setOnClickListener {
            FusionNavigator.sendMessage("msg2")
        }
        binding.tvC.setOnClickListener {
            FusionNavigator.open("/test", mapOf("title" to "Normal Flutter Page"))
        }
        binding.tvD.setOnClickListener {
            FusionNavigator.open("/transparent", mapOf("title" to "Transparent Flutter Page", "transparent" to true))
        }
    }
}