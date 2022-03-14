package com.gtbluesky.fusion.controller

import android.content.Context
import android.os.Bundle
import com.gtbluesky.fusion.engine.FusionEngineBinding
import com.gtbluesky.fusion.constant.FusionConstant
import io.flutter.embedding.android.FlutterFragment
import io.flutter.embedding.android.RenderMode
import io.flutter.embedding.engine.FlutterEngine
import java.io.Serializable

class FusionFragment : FlutterFragment() {

    private lateinit var engineBinding: FusionEngineBinding

    companion object {
        @JvmStatic
        fun buildFragment(
            routeName: String,
            routeArguments: Map<String, Any>? = null
        ): FusionFragment {
            return FusionFlutterFragmentBuilder(FusionFragment::class.java).setInitialRoute(
                routeName,
                routeArguments
            ).renderMode(RenderMode.texture).build<FusionFragment>()
        }
    }

    override fun onAttach(context: Context) {
        val routeName = arguments?.getString(FusionConstant.ROUTE_NAME) ?: FusionConstant.INITIAL_ROUTE
        val routeArguments =
            arguments?.getSerializable(FusionConstant.ROUTE_ARGUMENTS) as? Map<String, Any>
        engineBinding = FusionEngineBinding(context, routeName, routeArguments)
        super.onAttach(context)
    }

    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        return engineBinding.engine
    }

    private class FusionFlutterFragmentBuilder(fragmentClass: Class<out FusionFragment>) :
        FlutterFragment.NewEngineFragmentBuilder(fragmentClass) {

        private var routeName: String = FusionConstant.INITIAL_ROUTE
        private var routeArguments: Map<String, Any>? = null

        fun setInitialRoute(
            name: String,
            arguments: Map<String, Any>?
        ): FusionFlutterFragmentBuilder {
            routeName = name
            routeArguments = arguments
            return this
        }

        override fun createArgs(): Bundle {
            return super.createArgs().also {
                it.putString(FusionConstant.ROUTE_NAME, routeName)
                it.putSerializable(FusionConstant.ROUTE_ARGUMENTS, routeArguments as? Serializable)
            }
        }
    }
}