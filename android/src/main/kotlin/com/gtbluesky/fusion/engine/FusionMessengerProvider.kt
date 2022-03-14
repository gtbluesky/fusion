package com.gtbluesky.fusion.engine

import io.flutter.plugin.common.BinaryMessenger

interface FusionMessengerProvider {
    fun configureFlutterChannel(binaryMessenger: BinaryMessenger)
}