import FusionContainer from './FusionContainer'
import { FusionNotificationBinding } from '../notification/FusionNotification'
import Fusion from '../Fusion'
import List from '@ohos.util.List'
import { router } from '@kit.ArkUI'

export default class FusionStackManager {
  private static _instance = new FusionStackManager()

  private constructor() {
  }

  public static get instance(): FusionStackManager {
    return FusionStackManager._instance
  }

  // todo 弱引用
  public containerStack = new List<FusionContainer>()

  public visibleContainerCount = 0

  public isEmpty(): boolean {
    return this.containerStack.isEmpty()
  }

  public isContainerVisible(): boolean {
    return this.visibleContainerCount > 0
  }

  public add(container: FusionContainer): void {
    this.remove(container)
    this.containerStack.add(container)
  }

  public remove(container: FusionContainer): void {
    this.containerStack.remove(container)
  }

  public getTopContainer(): FusionContainer | null {
    if (this.containerStack.isEmpty()) {
      return null
    }
    return this.containerStack.getLast()
  }

  public findContainer(uniqueId: string): FusionContainer | null {
    if (uniqueId == '') {
      return null
    }
    for (let element of this.containerStack) {
      if (element.uniqueId() == uniqueId) {
        return element
      }
    }
    return null
  }

  public closeContainer(container: FusionContainer): void {
    // todo
    router.back()
  }

  public isAttached(): boolean {
    for (let element of this.containerStack) {
      if (element.isAttached()) {
        return true
      }
    }
    return false
  }

  public notifyEnterForeground(): void {
    // todo 待验证
    // if (this.isContainerVisible()) {
    //   Fusion.instance.engineBinding?.engine?.getLifecycleChannel()?.appIsResumed()
    // }
    Fusion.instance.engineBinding?.notifyEnterForeground()
  }

  public notifyEnterBackground(): void {
    // todo 待验证
    // Fusion.instance.engineBinding?.engine?.getLifecycleChannel()?.appIsPaused()
    Fusion.instance.engineBinding?.notifyEnterBackground()
  }

  public sendMessage(name: string, body?: Map<string, Object>): void {
    // Native
    FusionNotificationBinding.instance.dispatchMessage(name, body)
    // Flutter
    const msg = new Map<string, Object | null>()
    msg['name'] = name
    msg['body'] = body
    Fusion.instance.engineBinding?.dispatchMessage(msg)
  }
}