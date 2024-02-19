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

export default class FusionEntry extends FlutterEntry implements FusionContainer {
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
    throw new Error('Method not implemented.');
  }

  /* override */ isAttached(): boolean {
    return this._isAttached
  }

  /* override */ removeMask(): void {
    throw new Error('Method not implemented.');
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
      this.platformPlugin = new PlatformPlugin(platformChannel!, this.uiAbility!.context)
    }
    // Configure custom channel
    if (ToolUtils.implementsInterface(this, 'configureFlutterChannel')) {
      (this as object as FusionMessengerHandler)?.configureFlutterChannel(engine.dartExecutor.getBinaryMessenger())
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
      (this as object as FusionMessengerHandler)?.releaseFlutterChannel()
    }
  }

  private onContainerCreate(): void {
    if (!this.isTransparent) {
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
    ++FusionStackManager.instance.visibleContainerCount
  }

  private updateSystemOverlayStyle() {
    this.engineBinding?.checkStyle((systemChromeStyle) => {
      //todo
      this.platformPlugin?.updateSystemUiOverlays()
    })
  }

  private onContainerInvisible(): void {
    this.engineBinding?.notifyPageInvisible(this._uniqueId)
    --FusionStackManager.instance.visibleContainerCount
  }

  private onContainerDestroy(): void {
    this.detachFromContainer()
    this._history.clear()
    FusionStackManager.instance.remove(this)
    this.engineBinding?.destroy(this._uniqueId)
  }

  constructor(context: Context, params: ESObject = {}) {
    super(context, params)
    this.onContainerCreate()
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
  }

  override shouldAttachEngineToAbility(): boolean {
    return false
  }

  detachFromFlutterEngine(): void {
  }

  provideFlutterEngine(context: Context): FlutterEngine {
    return this.engineBinding?.engine!
  }
}