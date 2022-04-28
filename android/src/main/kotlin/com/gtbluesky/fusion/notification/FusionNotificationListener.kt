package com.gtbluesky.fusion.notification

interface FusionNotificationListener {
    fun onReceive(msgName: String, msgBody: Map<String, Any>?)
}