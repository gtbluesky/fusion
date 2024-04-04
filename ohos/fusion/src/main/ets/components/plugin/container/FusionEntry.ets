import FlutterEntry from '@ohos/flutter_ohos/src/main/ets/embedding/ohos/FlutterEntry';
import FusionContainer from './FusionContainer';
import util from '@ohos.util';
import FusionStackManager from './FusionStackManager';
import { List } from '@kit.ArkTS';
import Fusion from '../Fusion';
import PlatformPlugin from '@ohos/flutter_ohos/src/main/ets/plugin/PlatformPlugin';
import FusionMessengerHandler from '../handler/FusionMessengerHandler';
import ToolUtils from '@ohos/flutter_ohos/src/main/ets/util/ToolUtils';
import FlutterEngine from '@ohos/flutter_ohos/src/main/ets/embedding/engine/FlutterEngine';
import { Context } from '@kit.AbilityKit';
import FusionConstant from '../constant/FusionConstant';
import { window } from '@kit.ArkUI';

export default class FusionEntry extends FlutterEntry implements FusionContainer {
  private _context: Context
  private _params: Record<string, Object>
  private _history = new List<Map<string, Object | null>>()
  private _isAttached = false
  private _uniqueId = `container_${util.generateRandomUUID(false)}`
  private engineBinding = Fusion.instance.engineBinding
  private platformPlugin: PlatformPlugin | null = null

  /* override */ uniqueId(): string {
    return this._uniqueId
  }

  /* override */ history(): List<Map<string, Object | null>> {
    return this._history
  }

  /* override */ isTransparent(): boolean {
    return (this._params[FusionConstant.EXTRA_BACKGROUND_MODE] ?? false) as boolean
  }

  /* override */ isAttached(): boolean {
    return this._isAttached
  }

  /* override */ removeMask(): void {
    //todo
  }

  private attachToContainer(): void {
    if (this._isAttached) {
      return
    }
    this._isAttached = true
    const engine = this.engineBinding?.engine
    if (engine == null) {
      return
    }
    // Attach plugins to the ability.
    const exclusiveAppComponent = this.getExclusiveAppComponent()
    engine.getAbilityControlSurface()?.attachToAbility(exclusiveAppComponent)
    // Attach rendering pipeline.
    this.getFlutterView()?.attachToFlutterEngine(engine)
    // Configure platform channel
    if (this.platformPlugin == null) {
      let platformChannel = this.engineBinding?.engine?.getPlatformChannel()
      this.platformPlugin = new PlatformPlugin(platformChannel!, this._context)
    }
    // Configure custom channel
    if (ToolUtils.implementsInterface(this, 'configureFlutterChannel')) {
      (this as Object as FusionMessengerHandler)?.configureFlutterChannel(engine.dartExecutor.getBinaryMessenger())
    }
  }

  /* override */ detachFromContainer(): void {
    if (!this._isAttached) {
      return
    }
    this._isAttached = false
    let engine = this.engineBinding?.engine
    if (engine == null) {
      return
    }
    engine.getAbilityControlSurface()?.detachFromAbility()
    this.getFlutterView()?.detachFromFlutterEngine()
    // Release platform channel
    this.platformPlugin?.destroy()
    this.platformPlugin = null
    // Release custom channel
    if (ToolUtils.implementsInterface(this, 'releaseFlutterChannel')) {
      (this as Object as FusionMessengerHandler)?.releaseFlutterChannel()
    }
  }

  private onContainerCreate(): void {
    if (!this.isTransparent()) {
      // todo
    }
    if (FusionStackManager.instance.isEmpty()) {
      this.engineBinding?.engine?.getLifecycleChannel()?.appIsResumed()
    }
    FusionStackManager.instance.add(this)
  }

  private onContainerVisible(): void {
    const top = FusionStackManager.instance.getTopContainer()
    if (top != this) {
      top?.detachFromContainer()
    }
    FusionStackManager.instance.add(this)
    this.engineBinding?.switchTop(this._uniqueId)
    this.engineBinding?.notifyPageVisible(this._uniqueId)
    this.attachToContainer()
  }

  private updateSystemOverlayStyle() {
    this.engineBinding?.checkStyle((systemChromeStyle) => {
      if (this.platformPlugin == null) {
        return
      }
      this.platformPlugin.callback.currentTheme = systemChromeStyle
      this.platformPlugin.updateSystemUiOverlays()
    })
  }

  private onContainerInvisible(): void {
    this.engineBinding?.notifyPageInvisible(this._uniqueId)
  }

  private onContainerDestroy(): void {
    this.detachFromContainer()
    this._history.clear()
    FusionStackManager.instance.remove(this)
    this.engineBinding?.destroy(this._uniqueId)
  }

  constructor(context: Context, params: Record<string, Object> = {}) {
    super(context, params)
    this._context = context
    this._params = params
  }

  override async aboutToAppear() {
    const top = FusionStackManager.instance.getTopContainer()
    if (top != this) {
      top?.detachFromContainer()
    }
    await super.aboutToAppear()
    const routeName = (this._params[FusionConstant.ROUTE_NAME] ?? FusionConstant.INITIAL_ROUTE) as string
    const routeArgsRecord = (this._params[FusionConstant.ROUTE_ARGS] ?? {}) as Record<string, Object>
    const routeArgs = new Map<string, Object>(Object.entries(routeArgsRecord));
    window.getLastWindow(this._context, (_, win) => {
      win.setWindowLayoutFullScreen(true)
      if (this.isTransparent()) {
        win.setWindowBackgroundColor('#00000000')
      }
    })
    this.engineBinding?.create(this._uniqueId, routeName, routeArgs)
    this.getFlutterView()?.detachFromFlutterEngine()
    this.onContainerCreate()
  }

  override onPageShow(): void {
    super.onPageShow()
    this.onContainerVisible()
    this.updateSystemOverlayStyle()
  }

  override onPageHide(): void {
    super.onPageHide()
    this.onContainerInvisible()
  }

  override aboutToDisappear(): void {
    // 由于子窗口销毁时不走onPageHide()，因此在aboutToDisappear()处兜底
    if (this.isTransparent()) {
      this.onContainerInvisible()
    }
    super.aboutToDisappear()
    this.onContainerDestroy()
    if (FusionStackManager.instance.isEmpty()) {
      this.engineBinding?.engine?.getLifecycleChannel()?.appIsPaused()
    }
    this.engineBinding = null
  }

  override onBackPress(): void {
    this.engineBinding?.maybePop()
  }

  override shouldDestroyEngineWithHost(): boolean {
    return false
  }

  override shouldAttachEngineToAbility(): boolean {
    return false
  }

  override shouldDispatchAppLifecycleState(): boolean {
    return false
  }

  override detachFromFlutterEngine(): void {
  }

  override provideFlutterEngine(context: Context): FlutterEngine {
    return this.engineBinding?.engine!
  }

  override providePlatformPlugin(flutterEngine: FlutterEngine): PlatformPlugin | undefined {
    return undefined
  }
}