package com.gtbluesky.fusion_example

import android.os.Bundle
import android.util.Log
import androidx.fragment.app.FragmentActivity
import androidx.viewpager2.widget.ViewPager2
import com.gtbluesky.fusion.controller.FusionFragment
import com.gtbluesky.fusion.channel.FusionMessengerProvider
import com.gtbluesky.fusion_example.databinding.ActivityFirstFragmentBinding
import io.flutter.plugin.common.BinaryMessenger

class FragmentSceneActivity : FragmentActivity(), FusionMessengerProvider {
    private lateinit var binding: ActivityFirstFragmentBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityFirstFragmentBinding.inflate(layoutInflater)
        setContentView(binding.root)
        val adapter = MyFragmentStateAdapter(this)
        binding.vp.adapter = adapter
        val fragment0 = FusionFragment.buildFragment("/test", mapOf("title" to "f0"))
        val fragment1 = FusionFragment.buildFragment("/lifecycle", mapOf("title" to "f1"))
        val fragment2 = FusionFragment.buildFragment("/list", mapOf("title" to "f2"))
        adapter.addFragment(fragment0)
        adapter.addFragment(fragment1)
        adapter.addFragment(fragment2)
        binding.vp.currentItem = 0
        binding.vp.registerOnPageChangeCallback(object : ViewPager2.OnPageChangeCallback() {
            override fun onPageSelected(position: Int) {
                super.onPageSelected(position)
                when (position) {
                    0 -> {
                        binding.rbHome.isChecked = true
                        binding.rbMsg.isChecked = false
                        binding.rbMy.isChecked = false
                    }
                    1 -> {
                        binding.rbHome.isChecked = false
                        binding.rbMsg.isChecked = true
                        binding.rbMy.isChecked = false
                    }
                    2 -> {
                        binding.rbHome.isChecked = false
                        binding.rbMsg.isChecked = false
                        binding.rbMy.isChecked = true
                    }
                }
            }
        }
        )
        binding.rgVp.setOnCheckedChangeListener { group, checkedId ->
            when (checkedId) {
                binding.rbHome.id -> {
                    binding.vp.currentItem = 0
                }
                binding.rbMsg.id -> {
                    binding.vp.currentItem = 1
                }
                binding.rbMy.id -> {
                    binding.vp.currentItem = 2
                }
            }
        }
    }

    override fun configureFlutterChannel(binaryMessenger: BinaryMessenger) {
        Log.d("FragmentSceneActivity", "configureFlutterChannel")
    }
}