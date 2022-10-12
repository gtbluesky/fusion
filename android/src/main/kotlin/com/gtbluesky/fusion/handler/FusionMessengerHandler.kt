package com.gtbluesky.fusion.handler

import io.flutter.plugin.common.BinaryMessenger

interface FusionMessengerHandler {
    fun configureFlutterChannel(binaryMessenger: BinaryMessenger)
    fun releaseFlutterChannel()
}