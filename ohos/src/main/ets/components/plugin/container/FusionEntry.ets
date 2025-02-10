import FusionContainer from './FusionContainer';
import util from '@ohos.util';
import FusionStackManager from './FusionStackManager';
import { List } from '@kit.ArkTS';
import Fusion from '../Fusion';
import FusionMessengerHandler from '../handler/FusionMessengerHandler';
import { Context } from '@kit.AbilityKit';
import FusionConstant from '../constant/FusionConstant';
import { FlutterEngine, FlutterEntry, PlatformPlugin, ToolUtils } from '@ohos/flutter_ohos';

export default class FusionEntry extends FlutterEntry implements FusionContainer {
  private _context: Context
  private _params: Record<string, Object>
  private _history = new List<Map<string, Object | null>>()
  private _isAttached = false
  private _uniqueId = `container_${util.generateRandomUUID(false)}`
  private engineBinding = Fusion.instance.engineBinding
  private platformPlugin: PlatformPlugin | null = null
  public navDestinationId?: string | null

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

  attachToContainer(): void {
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
      this.platformPlugin.callback.mainWindow = this.windowStage?.getMainWindowSync() ?? null
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
    // Plugins are no longer attached to the ability.
    engine.getAbilityControlSurface()?.detachFromAbility()
    // Detach rendering pipeline.
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
    this.engineBinding?.switchTop(this._uniqueId, () => {
      this.attachToContainer()
      this.updateSystemOverlayStyle()
    })
    this.engineBinding?.notifyPageVisible(this._uniqueId)
  }

  private updateSystemOverlayStyle(): void {
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

  get params(): Record<string, Object> {
    return this._params
  }

  override aboutToAppear(): void {
    const top = FusionStackManager.instance.getTopContainer()
    if (top != this) {
      top?.detachFromContainer()
    }
    super.aboutToAppear()
    const routeName = (this._params[FusionConstant.ROUTE_NAME] ?? FusionConstant.INITIAL_ROUTE) as string
    const routeArgs = this._params[FusionConstant.ROUTE_ARGS] as Map<string, Object>
    this.engineBinding?.create(this._uniqueId, routeName, routeArgs)
    this.getFlutterView()?.detachFromFlutterEngine()
    this.onContainerCreate()
    if (this.navDestinationId != null) {
      this._params['uniqueId'] = this._uniqueId
      this._params['navDestinationId'] = this.navDestinationId
    }
  }

  override onPageShow(): void {
    super.onPageShow()
    this.onContainerVisible()
  }

  override onPageHide(): void {
    super.onPageHide()
    this.onContainerInvisible()
  }

  override aboutToDisappear(): void {
    super.aboutToDisappear()
    this.onContainerDestroy()
    if (FusionStackManager.instance.isEmpty()) {
      this.engineBinding?.engine?.getLifecycleChannel()?.appIsPaused()
    }
    this.engineBinding = null
    // 透明FlutterPage下的FlutterPage需主动触发其onPageShow
    const previousIndex = this._params['previousIndex'] as number | null
    if (previousIndex == null) {
      return
    }
    const previousParam = Fusion.instance.navPathStack?.getParamByIndex(previousIndex) as Record<string, Object> | null
    if (previousParam == null) {
      return
    }
    const previousUniqueId = previousParam['uniqueId'] as string | null
    if (previousUniqueId == null) {
      return
    }
    const previousEntry = FusionStackManager.instance.findContainer(previousUniqueId) as FusionEntry | null
    previousEntry?.onPageShow()
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

  override attachToEngineAutomatically(): boolean {
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