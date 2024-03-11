import FlutterEngine from '@ohos/flutter_ohos/src/main/ets/embedding/engine/FlutterEngine'
import FlutterEngineGroup from '@ohos/flutter_ohos/src/main/ets/embedding/engine/FlutterEngineGroup'
import { Options } from '@ohos/flutter_ohos/src/main/ets/embedding/engine/FlutterEngineGroup'
import FusionEngineBinding from './engine/FusionEngineBinding'
import FusionRouteDelegate from './FusionRouteDelegate'
import FusionConstant from './constant/FusionConstant'
import { DartEntrypoint } from '@ohos/flutter_ohos/src/main/ets/embedding/engine/dart/DartExecutor'
import AbilityLifecycleCallback from '@ohos.app.ability.AbilityLifecycleCallback'
import UIAbility from '@ohos.app.ability.UIAbility'
import FusionStackManager from './container/FusionStackManager'
import { FlutterManager, FlutterPlugin } from '@ohos/flutter_ohos'
import List from '@ohos.util.List'
import { window } from '@kit.ArkUI'

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

  private context: Context | null = null
  private lifecycleCallback: AbilityLifecycleCallback | null = null
  private isRunning = false
  private callbackId = -1

  static get instance(): Fusion {
    return Fusion._instance
  }

  private constructor() {
  }

  public async install(context: Context, delegate: FusionRouteDelegate, plugins: List<FlutterPlugin> | null = null): Promise<void> {
    if (this.isRunning) {
      return
    }
    this.isRunning = true
    this.context = context
    this._delegate = delegate
    this.lifecycleCallback = new FusionLifecycleCallback()
    this.callbackId = this.context.getApplicationContext().on('abilityLifecycle', this.lifecycleCallback)
    this._engineGroup = new FlutterEngineGroup()
    await this._engineGroup.checkLoader(context, null)
    this._defaultEngine = await this.createAndRunEngine(plugins ?? new List<FlutterPlugin>())
    this._engineBinding = new FusionEngineBinding(this._defaultEngine)
    this._engineBinding?.attach()
  }

  private async createAndRunEngine(plugins: List<FlutterPlugin>, initialRoute: string = FusionConstant.INITIAL_ROUTE): Promise<FlutterEngine | null> {
    let option = new Options(this.context!)
    option.setDartEntrypoint(DartEntrypoint.createDefault())
    option.setInitialRoute(initialRoute)
    option.setPlugins(plugins)
    // GeneratedPluginRegister里会通过getPlugins()来注册插件
    // 而getPlugins()需要自行在Ability里实现，即自行调用GeneratedPluginRegistrant.registerWithRegistry并将结果返回
    return this._engineGroup!.createAndRunEngineByOptions(option)
  }

  public uninstall(): void {
    this.context?.getApplicationContext().off('abilityLifecycle', this.callbackId)
    this.lifecycleCallback = null
    this._engineBinding?.detach()
    this._engineBinding = null
    this._engineGroup = null
    this._defaultEngine = null
    this.isRunning = false
  }
}

class FusionLifecycleCallback extends AbilityLifecycleCallback {
  private isLaunching = true

  onAbilityCreate(ability: UIAbility): void {
    FlutterManager.getInstance().pushUIAbility(ability)
  }

  onWindowStageCreate(ability: UIAbility, windowStage: window.WindowStage): void {
    FlutterManager.getInstance().pushWindowStage(ability, windowStage)
  }

  onWindowStageDestroy(ability: UIAbility, windowStage: window.WindowStage): void {
    FlutterManager.getInstance().popWindowStage(ability)
  }

  onAbilityDestroy(ability: UIAbility): void {
    FlutterManager.getInstance().popUIAbility(ability)
  }

  onAbilityForeground(ability: UIAbility): void {
    // 首次启动不触发进入前台回调，与iOS保持一致
    if (this.isLaunching) {
      this.isLaunching = false
      return
    }
    FusionStackManager.instance.notifyEnterForeground()
  }

  onAbilityBackground(ability: UIAbility): void {
    FusionStackManager.instance.notifyEnterBackground()
  }
}