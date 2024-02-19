import FlutterEntry from '@ohos/flutter_ohos/src/main/ets/embedding/ohos/FlutterEntry'
import ArrayList from '@ohos.util.ArrayList'

export interface FusionNotificationListener {
  onReceive(name: string, body?: Map<string, Object>): void
}

export class FusionNotificationBinding {
  private listeners = new ArrayList<FusionNotificationListener>()
  private static _instance = new FusionNotificationBinding()

  static get instance(): FusionNotificationBinding {
    return FusionNotificationBinding._instance
  }

  private constructor() {
  }

  register(listener: FusionNotificationListener): void {
    if (!(listener instanceof FlutterEntry)) {
      return
    }
    this.unregister(listener)
    this.listeners.add(listener)
  }

  unregister(listener: FusionNotificationListener): void {
    if (!(listener instanceof FlutterEntry)) {
      return
    }
    for (let element of this.listeners) {
      if (element == listener || element == null) {
        this.listeners.remove(element)
      }
    }
  }

  dispatchMessage(name: string, body?: Map<string, Object>): void {
    for (let element of this.listeners) {
      element.onReceive(name, body)
    }
  }
}