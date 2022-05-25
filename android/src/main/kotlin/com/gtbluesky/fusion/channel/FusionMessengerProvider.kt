package com.gtbluesky.fusion.channel

import io.flutter.plugin.common.BinaryMessenger

interface FusionMessengerProvider {
    fun configureFlutterChannel(binaryMessenger: BinaryMessenger)
    fun releaseFlutterChannel()
}