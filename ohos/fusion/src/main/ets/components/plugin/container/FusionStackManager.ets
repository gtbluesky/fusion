import FusionContainer from './FusionContainer'
import Fusion from '../Fusion'
import List from '@ohos.util.List'
import { router, window } from '@kit.ArkUI'
import FusionConstant from '../constant/FusionConstant'

export default class FusionStackManager {
  private static _instance = new FusionStackManager()

  private constructor() {
  }

  public static get instance(): FusionStackManager {
    return FusionStackManager._instance
  }

  // todo 弱引用
  public containerStack = new List<FusionContainer>()

  public isEmpty(): boolean {
    return this.containerStack.isEmpty()
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
    if (container.isTransparent()) {
      window.findWindow(FusionConstant.TRANSPARENT_WINDOW).destroyWindow()
    } else {
      router.back()
    }
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
    if (!this.isEmpty()) {
      Fusion.instance.engineBinding?.engine?.getLifecycleChannel()?.appIsResumed()
    }
    Fusion.instance.engineBinding?.notifyEnterForeground()
  }

  public notifyEnterBackground(): void {
    if (!this.isEmpty()) {
      Fusion.instance.engineBinding?.engine?.getLifecycleChannel()?.appIsPaused()
    }
    Fusion.instance.engineBinding?.notifyEnterBackground()
  }
}