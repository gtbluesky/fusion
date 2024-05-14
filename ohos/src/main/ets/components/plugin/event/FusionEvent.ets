import Fusion from '../Fusion'

export type FusionEventCallback = (args: Map<string, Object> | null) => void

export default class FusionEventManager {
  private callbackMap = new Map<string, Set<FusionEventCallback>>()
  private static _instance = new FusionEventManager()

  static get instance(): FusionEventManager {
    return FusionEventManager._instance
  }

  private constructor() {
  }

  register(event: string, callback: FusionEventCallback): void {
    let callbacks = this.callbackMap.get(event) ?? new Set<FusionEventCallback>()
    callbacks.add(callback)
    this.callbackMap.set(event, callbacks)
  }

  unregister(event: string, callback: FusionEventCallback | null = null): void {
    if (callback == null) {
      this.callbackMap.delete(event)
    } else {
      this.callbackMap.get(event)?.delete(callback)
    }
  }

  send(event: string, args: Map<string, Object> | null = null, type: FusionEventType = FusionEventType.global): void {
    switch (type) {
      case FusionEventType.flutter:
        Fusion.instance.engineBinding?.dispatchEvent(event, args)
        break
      case FusionEventType.native:
        this.dispatchEvent(event, args)
        break
      case FusionEventType.global:
        this.dispatchEvent(event, args)
        Fusion.instance.engineBinding?.dispatchEvent(event, args)
        break
    }
  }

  private dispatchEvent(name: string, args: Map<string, Object> | null): void {
    const callbacks = this.callbackMap.get(name)
    if (callbacks == null) {
      return
    }
    for (let callback of callbacks) {
      callback(args)
    }
  }
}

export enum FusionEventType {
  flutter,
  native,
  global
}
