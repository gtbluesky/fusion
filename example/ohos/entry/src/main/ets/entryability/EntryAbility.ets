import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { buildFusionParams, Fusion, FusionRouteDelegate} from '@ohos/fusion';
import { router, window } from '@kit.ArkUI';
import hilog from '@ohos.hilog';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import FusionConstant from '@ohos/fusion/src/main/ets/components/plugin/constant/FusionConstant';

export default class EntryAbility extends UIAbility implements FusionRouteDelegate {
  private static TAG = 'EntryAbility'
  private mainWindow: window.Window | null = null
  private windowStage: window.WindowStage | null = null

  override async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    await Fusion.instance.install(this.context, this, GeneratedPluginRegistrant.getPlugins())
  }

  override onWindowStageCreate(windowStage: window.WindowStage): void {
    this.windowStage = windowStage
    this.mainWindow = windowStage.getMainWindowSync()
    windowStage.loadContent('pages/Index')
  }

  /* override */ pushNativeRoute(name: string, args: Map<string, Object> | null): void {
    hilog.debug(0xFF00, EntryAbility.TAG, `pushNativeRoute: name=${name}, args=${args}`)
    switch (name) {
      case '/normal':
        router.pushUrl({url: 'pages/NativePage', params: args})
      default:
        break;
    }
  }

  /* override */ pushFlutterRoute(name: string, args: Map<string, Object> | null): void {
    hilog.debug(0xFF00, EntryAbility.TAG, `pushFlutterRoute: name=${name}, args=${args}`)
    const transparent = (args?.get('transparent') ?? false) as boolean
    const backgroundColor = (args?.get('backgroundColor') ?? 0xFFFFFFFF) as number
    const params = buildFusionParams(name, args ?? new Map<string, Object>(), transparent, backgroundColor)
    const url = transparent ? 'pages/TransparentFusionPage' : 'pages/CustomFusionPage'
    if (transparent) {
      this.windowStage?.createSubWindow(FusionConstant.TRANSPARENT_WINDOW, (err, win) => {
        const record: Record<string, Object> = {'params': params}
        win.loadContent(url, new LocalStorage(record))
        win.setWindowLayoutFullScreen(true)
        win.showWindow()
      })
    } else {
      router.pushUrl({url: url, params: params})
      this.mainWindow?.setWindowLayoutFullScreen(true)
    }
  }
}
