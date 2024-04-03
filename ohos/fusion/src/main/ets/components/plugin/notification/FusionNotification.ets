import ArrayList from '@ohos.util.ArrayList'

export interface FusionNotificationListener {
  onReceive(name: string, body: Map<string, Object>| null): void
}

export default class FusionNotificationBinding {
  private listeners = new ArrayList<FusionNotificationListener>()
  private static _instance = new FusionNotificationBinding()

  static get instance(): FusionNotificationBinding {
    return FusionNotificationBinding._instance
  }

  private constructor() {
  }

  register(listener: FusionNotificationListener): void {
    this.unregister(listener)
    this.listeners.add(listener)
  }

  unregister(listener: FusionNotificationListener): void {
    for (let it of this.listeners) {
      if (it == listener || it == null) {
        this.listeners.remove(it)
      }
    }
  }

  dispatchMessage(name: string, body: Map<string, Object> | null): void {
    for (let it of this.listeners) {
      it.onReceive(name, body)
    }
  }
}

export enum FusionNotificationType {
  flutter,
  native,
  global
}