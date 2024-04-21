import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { buildFusionParams, Fusion, FusionRouteDelegate, FusionConstant, FusionPage } from '@ohos/fusion';
import { router, window } from '@kit.ArkUI';
import hilog from '@ohos.hilog';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import { MethodChannel } from '@ohos/flutter_ohos';
import IndexPage from '../pages/IndexPage';
import TabScenePage from '../pages/TabScenePage';

export default class EntryAbility extends UIAbility implements FusionRouteDelegate {
  private static TAG = 'EntryAbility'
  private mainWindow: window.Window | null = null
  private windowStage: window.WindowStage | null = null
  private mainLocalStorage: LocalStorage | null = null

  override async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    await Fusion.instance.install(this.context, this)
    GeneratedPluginRegistrant.registerWith(Fusion.instance.defaultEngine!)
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
    this.mainLocalStorage = new LocalStorage()
    windowStage.loadContentByName(IndexPage.ROUTE_NAME, this.mainLocalStorage)
  }

  pushNativeRoute(name: string, args: Map<string, Object> | null): void {
    hilog.debug(0xFF00, EntryAbility.TAG, `pushNativeRoute: name=${name}, args=${args}`)
    switch (name) {
      case '/native_normal':
        router.pushNamedRoute({
          name: IndexPage.ROUTE_NAME,
          params: args,
        })
        break;
      case '/native_tab_fixed':
        router.pushNamedRoute({
          name: TabScenePage.ROUTE_NAME,
          params: args,
        })
        break;
      default:
        break;
    }
  }

  pushFlutterRoute(name: string, args: Map<string, Object> | null): void {
    hilog.debug(0xFF00, EntryAbility.TAG, `pushFlutterRoute: name=${name}, args=${args}`)
    const transparent = (args?.get('transparent') ?? false) as boolean
    const backgroundColor = (args?.get('backgroundColor') ?? BigInt(0xFFFFFFFF)) as bigint
    const params = buildFusionParams(name, args, transparent, backgroundColor)
    if (transparent) {
      this.windowStage?.createSubWindow(FusionConstant.TRANSPARENT_WINDOW, (_, win) => {
        const record: Record<string, Object> = {
          'params': params
        }
        win.loadContentByName(FusionPage.ROUTE_NAME, new LocalStorage(record))
        win.showWindow()
      })
    } else {
      this.mainLocalStorage?.setOrCreate('params', params)
      router.pushNamedRoute({name: FusionPage.ROUTE_NAME})
      // router.pushUrl({url: customFusionPageUrl})
    }
  }
}
