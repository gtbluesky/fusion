package com.gtbluesky.fusion.container

internal interface FusionContainer {
    fun uniqueId(): String?

    fun history(): MutableList<Map<String, Any?>>

    fun isTransparent(): Boolean

    fun isAttached(): Boolean

    fun removeMask()

    fun detachFromContainer()

    // To avoid compilation errors caused by the lack of "attachToEngineAutomatically()"
    // in `FlutterActivityAndFragmentDelegate` before Flutter 3.16.
    fun attachToEngineAutomatically(): Boolean = false
}