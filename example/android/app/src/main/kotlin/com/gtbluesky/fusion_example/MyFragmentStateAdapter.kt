package com.gtbluesky.fusion_example

import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import androidx.viewpager2.adapter.FragmentStateAdapter

class MyFragmentStateAdapter(activity: FragmentActivity) : FragmentStateAdapter(activity) {
    private val list = mutableListOf<Fragment>()

    fun addFragment(fragment: Fragment) {
        list.add(fragment)
    }

    override fun getItemCount() = list.size

    override fun createFragment(position: Int) = list[position]
}