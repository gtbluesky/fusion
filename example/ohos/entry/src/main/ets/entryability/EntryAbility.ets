import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { buildFusionParams, Fusion, FusionRouteDelegate } from 'fusion';
import { window } from '@kit.ArkUI';
import hilog from '@ohos.hilog';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import { MethodChannel } from '@ohos/flutter_ohos';

export default class EntryAbility extends UIAbility implements FusionRouteDelegate {
  private static TAG = 'EntryAbility'
  private mainWindow: window.Window | null = null
  private windowStage: window.WindowStage | null = null

  override onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Fusion.instance.install(this.context, this)
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
    const backgroundColor = (args?.get('backgroundColor') ?? BigInt(0xFFFFFFFF)) as bigint
    const params = buildFusionParams(name, args, transparent, backgroundColor)
    Fusion.instance.navPathStack?.disableAnimation(transparent)
    Fusion.instance.navPathStack?.pushPathByName('CustomFusionPage', params)
  }
}
