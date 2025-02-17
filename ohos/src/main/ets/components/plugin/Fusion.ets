import FusionEngineBinding from './engine/FusionEngineBinding'
import FusionConstant from './constant/FusionConstant'
import AbilityLifecycleCallback from '@ohos.app.ability.AbilityLifecycleCallback'
import UIAbility from '@ohos.app.ability.UIAbility'
import FusionStackManager from './container/FusionStackManager'
import { FlutterEngine, FlutterEngineGroup, FlutterManager } from '@ohos/flutter_ohos'
import { window } from '@kit.ArkUI'
import { FusionRouteDelegate } from './navigator/FusionNavigator'
import { Options } from '@ohos/flutter_ohos/src/main/ets/embedding/engine/FlutterEngineGroup'
import { DartEntrypoint } from '@ohos/flutter_ohos/src/main/ets/embedding/engine/dart/DartExecutor'

export default class Fusion {
  private static _instance = new Fusion()
  private _engineGroup: FlutterEngineGroup | null = null

  get engineGroup(): FlutterEngineGroup | null {
    return this._engineGroup
  }

  private _defaultEngine: FlutterEngine | null = null

  get defaultEngine(): FlutterEngine | null {
    return this._defaultEngine
  }

  private _engineBinding: FusionEngineBinding | null = null

  get engineBinding(): FusionEngineBinding | null {
    return this._engineBinding
  }

  private _delegate: FusionRouteDelegate | null = null

  get delegate(): FusionRouteDelegate | null {
    return this._delegate
  }

  private _navPathStack: NavPathStack | null = null

  get navPathStack(): NavPathStack | null {
    return this._navPathStack
  }

  private context: Context | null = null
  private lifecycleCallback: AbilityLifecycleCallback | null = null
  private isRunning = false
  private callbackId = -1

  static get instance(): Fusion {
    return Fusion._instance
  }

  private constructor() {
  }

  public install(context: Context, delegate: FusionRouteDelegate): void {
    if (this.isRunning) {
      return
    }
    this._navPathStack = new NavPathStack()
    this.isRunning = true
    this.context = context
    this._delegate = delegate
    this.lifecycleCallback = new FusionLifecycleCallback()
    this.callbackId = this.context.getApplicationContext().on('abilityLifecycle', this.lifecycleCallback)
    this._engineGroup = new FlutterEngineGroup()
    this._engineGroup.checkLoader(context, null)
    this._defaultEngine = this.createAndRunEngine()
    this._engineBinding = new FusionEngineBinding(this._defaultEngine)
    this._engineBinding?.attach()
  }

  private createAndRunEngine(initialRoute: string = FusionConstant.INITIAL_ROUTE): FlutterEngine | null{
    let option = new Options(this.context!)
    option.setDartEntrypoint(DartEntrypoint.createDefault())
    option.setInitialRoute(initialRoute)
    return this._engineGroup?.createAndRunEngineByOptions(option) ?? null
  }

  public uninstall(): void {
    this.context?.getApplicationContext().off('abilityLifecycle', this.callbackId)
    this.lifecycleCallback = null
    this._engineBinding?.detach()
    this._engineBinding = null
    this._engineGroup = null
    this._defaultEngine = null
    this.isRunning = false
    this._navPathStack = null
  }
}

class FusionLifecycleCallback extends AbilityLifecycleCallback {
  onAbilityCreate(ability: UIAbility): void {
    FlutterManager.getInstance().pushUIAbility(ability)
  }

  onWindowStageCreate(ability: UIAbility, windowStage: window.WindowStage): void {
    windowStage.getMainWindowSync().setWindowLayoutFullScreen(true)
    FlutterManager.getInstance().pushWindowStage(ability, windowStage)
  }

  onWindowStageDestroy(ability: UIAbility, windowStage: window.WindowStage): void {
    FlutterManager.getInstance().popWindowStage(ability)
  }

  onAbilityDestroy(ability: UIAbility): void {
    FlutterManager.getInstance().popUIAbility(ability)
  }

  onAbilityForeground(ability: UIAbility): void {
    FusionStackManager.instance.notifyEnterForeground()
  }

  onAbilityBackground(ability: UIAbility): void {
    FusionStackManager.instance.notifyEnterBackground()
  }
}