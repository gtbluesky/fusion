package com.gtbluesky.fusion_example

import android.graphics.Color
import android.os.Bundle
import android.view.View
import android.view.WindowManager
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import com.gtbluesky.fusion.container.FusionFragment
import com.gtbluesky.fusion.container.buildFusionFragment
import com.gtbluesky.fusion_example.databinding.ActivityTabBinding

class TabSceneActivity : FragmentActivity() {
    private lateinit var binding: ActivityTabBinding
    private var currentFragment: Fragment? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityTabBinding.inflate(layoutInflater)
        setContentView(binding.root)
        configureStatusBarForFullscreenFlutterExperience()
        val fragment0 = buildFusionFragment(
            CustomFusionFragment::class.java,
            "/background",
            mapOf("backgroundColor" to 0xFF546E7A),
            backgroundColor = 0xFF546E7A.toInt()
        )
        val fragment1 = buildFusionFragment(
            FusionFragment::class.java,
            "/lifecycle",
            mapOf("title" to "flutter1")
        )
        val fragment2 =
            buildFusionFragment(FusionFragment::class.java, "/web", mapOf("title" to "flutter2"))
        binding.rgVp.setOnCheckedChangeListener { _, checkedId ->
            when (checkedId) {
                binding.rbHome.id -> {
                    showFragment(fragment0)
                }
                binding.rbMsg.id -> {
                    showFragment(fragment1)
                }
                binding.rbMy.id -> {
                    showFragment(fragment2)
                }
            }
        }
        binding.rbHome.isChecked = true
        showFragment(fragment0)
    }

    private fun showFragment(fragment: Fragment) {
        if (currentFragment == fragment) return
        val transaction = supportFragmentManager.beginTransaction()
        currentFragment?.let {
            transaction.hide(it)
        }
        currentFragment = fragment
        if (fragment.isAdded) {
            transaction.show(fragment)
        } else {
            transaction.add(binding.fl.id, fragment).show(fragment)
        }
        transaction.commit()
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