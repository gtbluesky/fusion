import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { buildFusionParams, Fusion, FusionConstant, FusionPage, FusionRouteDelegate } from 'fusion';
import { router, window } from '@kit.ArkUI';
import hilog from '@ohos.hilog';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import { MethodChannel } from '@ohos/flutter_ohos';

export default class EntryAbility extends UIAbility implements FusionRouteDelegate {
  private static TAG = 'EntryAbility'
  private mainWindow: window.Window | null = null
  private windowStage: window.WindowStage | null = null

  override onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Fusion.instance.install(this.context, this, (engine) => {
      if (engine == null) {
        return
      }
      GeneratedPluginRegistrant.registerWith(engine)
    })
    const channel = new MethodChannel(Fusion.instance.defaultEngine?.dartExecutor!, 'container_unrelated_channel')
    channel.setMethodCallHandler({
      onMethodCall(call, result) {
        result.success(`container_unrelated_channel：${this}_${call.method}`)
      }
    })
  }

  override onWindowStageCreate(windowStage: window.WindowStage): void {
    this.windowStage = windowStage
    this.mainWindow = windowStage.getMainWindowSync()
    // Fusion no longer forces fullscreen; set window layout here if needed.
    this.mainWindow.setWindowLayoutFullScreen(true)
    windowStage.loadContent('pages/IndexPage')
  }

  pushNativeRoute(name: string, args: Map<string, Object> | null): void {
    hilog.debug(0xFF00, EntryAbility.TAG, `pushNativeRoute: name=${name}, args=${args}`)
    switch (name) {
      case '/native_normal':
        Fusion.instance.navPathStack?.disableAnimation(false)
        Fusion.instance.navPathStack?.pushPathByName('NormalPage', args)
        break;
      case '/native_tab_fixed':
        Fusion.instance.navPathStack?.disableAnimation(false)
        Fusion.instance.navPathStack?.pushPathByName('TabScenePage', args)
        break;
      default:
        break;
    }
  }

  pushFlutterRoute(name: string, args: Map<string, Object> | null): void {
    hilog.debug(0xFF00, EntryAbility.TAG, `pushFlutterRoute: name=${name}, args=${args}`)
    const transparent = (args?.get('transparent') ?? false) as boolean
    const backgroundColor = (args?.get('backgroundColor') ?? 0xFFFFFFFF) as number
    const params = buildFusionParams(name, args, transparent, backgroundColor)
    const topUrl = router.getState().path + router.getState().name
    // if (useRoot) {
    //   try {
    //     await window.findWindow(FusionConstant.TRANSPARENT_WINDOW).destroyWindow()
    //   } catch (error) {
    //     LogTool.e(EntryAbility.TAG, error)
    //   }
    // }
    if (topUrl === 'pages/IndexPage') {
      // router.pushUrl({url: 'pages/RouterFlutterPage', params: params})
      Fusion.instance.navPathStack?.disableAnimation(transparent)
      Fusion.instance.navPathStack?.pushPathByName('NavigationFlutterPage', params)
    } else {
      if (transparent) {
        params[FusionConstant.EXTRA_SUB_WINDOW] = true
        this.windowStage?.createSubWindow(FusionConstant.TRANSPARENT_WINDOW, (_, win) => {
          const record: Record<string, Object> = {
            'params': params
          }
          win.loadContentByName(FusionPage.ROUTE_NAME, new LocalStorage(record))
          win.showWindow()
        })
      } else {
        router.pushUrl({url: 'pages/RouterFlutterPage', params: params})
      }
    }
  }
}
