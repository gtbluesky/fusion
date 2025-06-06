import { List } from '@kit.ArkTS';
import FusionEventManager from '../event/FusionEvent';
import FusionStackManager from '../container/FusionStackManager';
import FusionConstant from '../constant/FusionConstant';
import Fusion from '../Fusion';
import { FusionRouteType } from '../navigator/FusionNavigator';
import { FusionEventType } from '../event/FusionEvent';
import { BasicMessageChannel, FlutterEngine, StandardMessageCodec } from '@ohos/flutter_ohos';
import {
  Brightness,
  SystemChromeStyle } from '@ohos/flutter_ohos/src/main/ets/embedding/engine/systemchannels/PlatformChannel';

export default class FusionEngineBinding {
  private hostPush: BasicMessageChannel<Object> | null = null
  private hostDestroy: BasicMessageChannel<Object> | null = null
  private hostRestore: BasicMessageChannel<Object> | null = null
  private hostSync: BasicMessageChannel<Object> | null = null
  private hostDispatchEvent: BasicMessageChannel<Object> | null = null
  private flutterCreate: BasicMessageChannel<Object> | null = null
  private flutterSwitchTop: BasicMessageChannel<Object> | null = null
  private flutterRestore: BasicMessageChannel<Object> | null = null
  private flutterDestroy: BasicMessageChannel<Object> | null = null
  private flutterPush: BasicMessageChannel<Object> | null = null
  private flutterReplace: BasicMessageChannel<Object> | null = null
  private flutterPop: BasicMessageChannel<Object> | null = null
  private flutterMaybePop: BasicMessageChannel<Object> | null = null
  private flutterRemove: BasicMessageChannel<Object> | null = null
  private flutterNotifyPageVisible: BasicMessageChannel<Object> | null = null
  private flutterNotifyPageInvisible: BasicMessageChannel<Object> | null = null
  private flutterNotifyEnterForeground: BasicMessageChannel<Object> | null = null
  private flutterNotifyEnterBackground: BasicMessageChannel<Object> | null = null
  private flutterDispatchEvent: BasicMessageChannel<Object> | null = null
  private flutterCheckStyle: BasicMessageChannel<Object> | null = null
  private _engine: FlutterEngine | null

  public get engine(): FlutterEngine | null {
    return this._engine
  }

  private get historyList(): List<Map<string, Object | null>> {
    const list = new List<Map<string, Object | null>>()
    for (let value of FusionStackManager.instance.containerStack) {
      let map = new Map<string, Object | null>()
      map.set('uniqueId', value.deref()?.uniqueId() ?? null)
      map.set('history', value.deref()?.history() ?? null)
      list.add(map)
    }
    return list
  }

  constructor(engine: FlutterEngine | null) {
    this._engine = engine
    if (engine == null) {
      return
    }
    const binaryMessenger = engine.dartExecutor.getBinaryMessenger()
    const messageCodec = StandardMessageCodec.INSTANCE
    this.hostPush = new BasicMessageChannel(
      binaryMessenger,
      `${FusionConstant.FUSION_CHANNEL}/host/push`,
      messageCodec
    )
    this.hostDestroy = new BasicMessageChannel(
      binaryMessenger,
      `${FusionConstant.FUSION_CHANNEL}/host/destroy`,
      messageCodec
    )
    this.hostRestore = new BasicMessageChannel(
      binaryMessenger,
      `${FusionConstant.FUSION_CHANNEL}/host/restore`,
      messageCodec
    )
    this.hostSync = new BasicMessageChannel(
      binaryMessenger,
      `${FusionConstant.FUSION_CHANNEL}/host/sync`,
      messageCodec
    )
    this.hostDispatchEvent = new BasicMessageChannel(
      binaryMessenger,
      `${FusionConstant.FUSION_CHANNEL}/host/dispatchEvent`,
      messageCodec
    )
    this.flutterCreate = new BasicMessageChannel(
      binaryMessenger,
      `${FusionConstant.FUSION_CHANNEL}/flutter/create`,
      messageCodec
    )
    this.flutterSwitchTop = new BasicMessageChannel(
      binaryMessenger,
      `${FusionConstant.FUSION_CHANNEL}/flutter/switchTop`,
      messageCodec
    )
    this.flutterRestore = new BasicMessageChannel(
      binaryMessenger,
      `${FusionConstant.FUSION_CHANNEL}/flutter/restore`,
      messageCodec
    )
    this.flutterDestroy = new BasicMessageChannel(
      binaryMessenger,
      `${FusionConstant.FUSION_CHANNEL}/flutter/destroy`,
      messageCodec
    )
    this.flutterPush = new BasicMessageChannel(
      binaryMessenger,
      `${FusionConstant.FUSION_CHANNEL}/flutter/push`,
      messageCodec
    )
    this.flutterReplace = new BasicMessageChannel(
      binaryMessenger,
      `${FusionConstant.FUSION_CHANNEL}/flutter/replace`,
      messageCodec
    )
    this.flutterPop = new BasicMessageChannel(
      binaryMessenger,
      `${FusionConstant.FUSION_CHANNEL}/flutter/pop`,
      messageCodec
    )
    this.flutterMaybePop = new BasicMessageChannel(
      binaryMessenger,
      `${FusionConstant.FUSION_CHANNEL}/flutter/maybePop`,
      messageCodec
    )
    this.flutterRemove = new BasicMessageChannel(
      binaryMessenger,
      `${FusionConstant.FUSION_CHANNEL}/flutter/remove`,
      messageCodec
    )
    this.flutterNotifyPageVisible = new BasicMessageChannel(
      binaryMessenger,
      `${FusionConstant.FUSION_CHANNEL}/flutter/notifyPageVisible`,
      messageCodec
    )
    this.flutterNotifyPageInvisible = new BasicMessageChannel(
      binaryMessenger,
      `${FusionConstant.FUSION_CHANNEL}/flutter/notifyPageInvisible`,
      messageCodec
    )
    this.flutterNotifyEnterForeground = new BasicMessageChannel(
      binaryMessenger,
      `${FusionConstant.FUSION_CHANNEL}/flutter/notifyEnterForeground`,
      messageCodec
    )
    this.flutterNotifyEnterBackground = new BasicMessageChannel(
      binaryMessenger,
      `${FusionConstant.FUSION_CHANNEL}/flutter/notifyEnterBackground`,
      messageCodec
    )
    this.flutterDispatchEvent = new BasicMessageChannel(
      binaryMessenger,
      `${FusionConstant.FUSION_CHANNEL}/flutter/dispatchEvent`,
      messageCodec
    )
    this.flutterCheckStyle = new BasicMessageChannel(
      binaryMessenger,
      `${FusionConstant.FUSION_CHANNEL}/flutter/checkStyle`,
      messageCodec
    )
  }

  attach(): void {
    this.hostPush?.setMessageHandler({
      onMessage: (message, reply) => {
        if (!(message instanceof Map)) {
          reply.reply(null)
          return
        }
        const name = message.get('name') as string | null
        if (name == null) {
          reply.reply(null)
          return
        }
        const args = message.get('args') as Map<string, Object> | null
        const type = message.get('type') as number
        if (type == FusionRouteType.flutterWithContainer.valueOf()) {
          Fusion.instance.delegate?.pushFlutterRoute(name, args)
        } else if (type == FusionRouteType.native.valueOf()) {
          Fusion.instance.delegate?.pushNativeRoute(name, args)
        }
        reply.reply(null)
      }
    })
    this.hostDestroy?.setMessageHandler({
      onMessage: (message, reply) => {
        if (!(message instanceof Map)) {
          reply.reply(null)
          return
        }
        const uniqueId = message.get('uniqueId') as string | null
        if (uniqueId == null) {
          reply.reply(false)
          return
        }
        const container = FusionStackManager.instance.findContainer(uniqueId)
        if (container != null) {
          FusionStackManager.instance.closeContainer(container)
          reply.reply(true)
        } else {
          reply.reply(false)
        }
      }
    })
    this.hostRestore?.setMessageHandler({
      onMessage: (_, reply) => {
        reply.reply(this.historyList)
      }
    })
    this.hostSync?.setMessageHandler({
      onMessage: (message, reply) => {
        if (!(message instanceof Map)) {
          reply.reply(null)
          return
        }
        const uniqueId = message.get('uniqueId') as string | null
        const history = message.get('history') as List<Map<string, Object | null>> | null
        if (uniqueId == null || history == null) {
          reply.reply(false)
          return
        }
        const list = FusionStackManager.instance.findContainer(uniqueId)?.history()
        list?.clear()
        for (let value of history) {
          list?.add(value)
        }
        reply.reply(true)
      }
    })
    this.hostDispatchEvent?.setMessageHandler({
      onMessage: (message, reply) => {
        if (!(message instanceof Map)) {
          reply.reply(null)
          return
        }
        const name = message.get('name') as string | null
        if (name == null) {
          reply.reply(null)
          return
        }
        const args = message.get('args') as Map<string, Object> | null
        FusionEventManager.instance.send(name, args, FusionEventType.native)
        reply.reply(null)
      }
    })
  }

  // external function
  push(name: string, args: Map<string, Object> | null, type: FusionRouteType): void {
    const map = new Map<string, Object | null>()
    map.set('name', name)
    map.set('args', args)
    map.set('type', type.valueOf())
    this.flutterPush?.send(map)
  }

  replace(name: string, args: Map<string, Object> | null): void {
    const map = new Map<string, Object | null>()
    map.set('name', name)
    map.set('args', args)
    this.flutterReplace?.send(map)
  }

  pop(result: Object | null): void {
    const map = new Map<string, Object | null>()
    map.set('result', result)
    this.flutterPop?.send(map)
  }

  maybePop(result: Object | null = null): void {
    const map = new Map<string, Object | null>()
    map.set('result', result)
    this.flutterMaybePop?.send(map)
  }

  remove(name: string): void {
    const map = new Map<string, Object>()
    map.set('name', name)
    this.flutterRemove?.send(map)
  }

  // internal function
  create(uniqueId: string, name: string, args: Map<string, Object> | null): void {
    const map = new Map<string, Object | null>()
    map.set('uniqueId', uniqueId)
    map.set('name', name)
    map.set('args', args)
    this.flutterCreate?.send(map)
  }

  switchTop(uniqueId: string, callback: () => void): void {
    const map = new Map<string, Object>()
    map.set('uniqueId', uniqueId)
    this.flutterSwitchTop?.send(
      map,
      (_) => {
        callback()
      }
    )
  }

  restore(uniqueId: string, history: List<Map<string, Object | null>>): void {
    const map = new Map<string, Object>()
    map.set('uniqueId', uniqueId)
    map.set('history', history)
    this.flutterRestore?.send(map)
  }

  destroy(uniqueId: string): void {
    const map = new Map<string, Object>()
    map.set('uniqueId', uniqueId)
    this.flutterDestroy?.send(map)
  }

  notifyPageVisible(uniqueId: string): void {
    const map = new Map<string, Object>()
    map.set('uniqueId', uniqueId)
    this.flutterNotifyPageVisible?.send(map)
  }

  notifyPageInvisible(uniqueId: string): void {
    const map = new Map<string, Object>()
    map.set('uniqueId', uniqueId)
    this.flutterNotifyPageInvisible?.send(map)
  }

  notifyEnterForeground(): void {
    this.flutterNotifyEnterForeground?.send(null)
  }

  notifyEnterBackground(): void {
    this.flutterNotifyEnterBackground?.send(null)
  }

  dispatchEvent(name: string, args: Map<string, Object> | null): void {
    const msg = new Map<string, Object | null>()
    msg.set('name', name)
    msg.set('args', args)
    this.flutterDispatchEvent?.send(msg)
  }

  checkStyle(callback: (systemChromeStyle: SystemChromeStyle) => void): void {
    this.flutterCheckStyle?.send(
      null,
      (reply) => {
        let systemChromeStyle = this.decodeSystemChromeStyle(reply as Map<string, object> | null)
        if (systemChromeStyle == null) {
          return
        }
        callback(systemChromeStyle)
      }
    )
  }

  private decodeSystemChromeStyle(styleMap: Map<string, Object> | null): SystemChromeStyle | null {
    if (styleMap == null) {
      return null
    }
    let statusBarColor: number | null = null
    let statusBarIconBrightness: Brightness | null = null
    let systemStatusBarContrastEnforced: boolean | null = null
    let systemNavigationBarColor: number | null = null
    let systemNavigationBarIconBrightness: Brightness | null = null
    let systemNavigationBarDividerColor: number | null = null
    let systemNavigationBarContrastEnforced: boolean | null = null
    if (styleMap.get('statusBarColor') != null) {
      statusBarColor = styleMap.get('statusBarColor') as number
    }
    statusBarIconBrightness = styleMap.get('statusBarIconBrightness') == 'Brightness.light' ? Brightness.LIGHT : Brightness.DARK
    if (styleMap.get('systemStatusBarContrastEnforced') != null) {
      systemStatusBarContrastEnforced = styleMap.get('systemStatusBarContrastEnforced') as boolean
    }
    if (styleMap.get('systemNavigationBarColor') != null) {
      systemNavigationBarColor = styleMap.get('systemNavigationBarColor') as number
    }
    systemNavigationBarIconBrightness = styleMap.get('systemNavigationBarIconBrightness') == 'Brightness.light' ? Brightness.LIGHT : Brightness.DARK
    if (styleMap.get('systemNavigationBarDividerColor') != null) {
      systemNavigationBarDividerColor = styleMap.get('systemNavigationBarDividerColor') as number
    }
    if (styleMap.get('systemNavigationBarContrastEnforced') != null) {
      systemNavigationBarContrastEnforced = styleMap.get('systemNavigationBarContrastEnforced') as boolean
    }
    return new SystemChromeStyle(
      statusBarColor,
      statusBarIconBrightness,
      systemStatusBarContrastEnforced,
      systemNavigationBarColor,
      systemNavigationBarIconBrightness,
      systemNavigationBarDividerColor,
      systemNavigationBarContrastEnforced
    )
  }

  detach(): void {
    this.hostPush?.setMessageHandler(null)
    this.hostPush = null
    this.hostDestroy?.setMessageHandler(null)
    this.hostDestroy = null
    this.hostRestore?.setMessageHandler(null)
    this.hostRestore = null
    this.hostSync?.setMessageHandler(null)
    this.hostSync = null
    this.hostDispatchEvent?.setMessageHandler(null)
    this.hostDispatchEvent = null
    this.flutterCreate = null
    this.flutterSwitchTop = null
    this.flutterRestore = null
    this.flutterDestroy = null
    this.flutterPush = null
    this.flutterReplace = null
    this.flutterPop = null
    this.flutterMaybePop = null
    this.flutterRemove = null
    this.flutterNotifyPageVisible = null
    this.flutterNotifyPageInvisible = null
    this.flutterNotifyEnterForeground = null
    this.flutterNotifyEnterBackground = null
    this.flutterDispatchEvent = null
    this.flutterCheckStyle = null
    this._engine?.destroy()
    this._engine = null
  }
}