package com.gtbluesky.fusion.notification

interface PageNotificationListener {
    fun onReceive(msgName: String, msgBody: Map<String, Any>?)
}