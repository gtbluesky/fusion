package com.gtbluesky.fusion_example

import android.graphics.Color
import android.os.Bundle
import android.view.View
import android.view.WindowManager
import androidx.fragment.app.FragmentActivity
import androidx.viewpager2.widget.ViewPager2
import com.gtbluesky.fusion.container.FusionFragment
import com.gtbluesky.fusion.container.buildFusionFragment
import com.gtbluesky.fusion_example.databinding.ActivityFirstFragmentBinding

class ViewPagerSceneActivity : FragmentActivity() {
    private lateinit var binding: ActivityFirstFragmentBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityFirstFragmentBinding.inflate(layoutInflater)
        setContentView(binding.root)
        configureStatusBarForFullscreenFlutterExperience()
        val adapter = MyFragmentStateAdapter(this)
        binding.vp.adapter = adapter
        val fragment0 = buildFusionFragment(CustomFusionFragment::class.java,"/background", mapOf("backgroundColor" to 0xFF546E7A), backgroundColor = 0xFF546E7A.toInt())
        val fragment1 = buildFusionFragment(FusionFragment::class.java, "/lifecycle", mapOf("title" to "flutter1"))
        val fragment2 = buildFusionFragment(FusionFragment::class.java,"/web", mapOf("title" to "flutter2"))
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

    private fun configureStatusBarForFullscreenFlutterExperience() {
        window.let {
            it.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)
            it.statusBarColor = Color.TRANSPARENT
            it.decorView.systemUiVisibility =
                View.SYSTEM_UI_FLAG_LAYOUT_STABLE or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
        }
    }
}