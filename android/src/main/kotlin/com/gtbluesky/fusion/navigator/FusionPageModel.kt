package com.gtbluesky.fusion.navigator

import android.app.Activity
import java.lang.ref.WeakReference

data class FusionPageModel(
    val nativePage: WeakReference<Activity>,
    val flutterPages: MutableList<String> = arrayListOf()
)
