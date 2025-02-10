import FusionContainer from './FusionContainer'
import FusionEntry from './FusionEntry'
import Fusion from '../Fusion'
import List from '@ohos.util.List'

export default class FusionStackManager {
  private static _instance = new FusionStackManager()

  private constructor() {
  }

  public static get instance(): FusionStackManager {
    return FusionStackManager._instance
  }

  public containerStack = new List<WeakRef<FusionContainer>>()

  public isEmpty(): boolean {
    return this.containerStack.isEmpty()
  }

  public add(container: FusionContainer): void {
    this.remove(container)
    this.containerStack.add(new WeakRef(container))
  }

  public remove(container: FusionContainer): void {
    for (let i: number = this.containerStack.length - 1; i >= 0; --i) {
      let containerRef: WeakRef<FusionContainer> = this.containerStack.get(i)
      if (containerRef.deref() == container || containerRef.deref() == null) {
        this.containerStack.removeByIndex(i)
      }
    }
  }

  public getTopContainer(): FusionContainer | null {
    if (this.containerStack.isEmpty()) {
      return null
    }
    return this.containerStack.getLast().deref() ?? null
  }

  public findContainer(uniqueId: string): FusionContainer | null {
    if (uniqueId == '') {
      return null
    }
    for (let containerRef of this.containerStack) {
      if (containerRef.deref()?.uniqueId() == uniqueId) {
        return containerRef.deref() ?? null
      }
    }
    return null
  }

  public closeContainer(container: FusionContainer): void {
    const entry = container as FusionEntry
    if (entry.navDestinationId != null && entry.isTransparent()) {
      const size = Fusion.instance.navPathStack?.size() ?? 0
      for (let i = 0; i < size; ++i) {
        const param = Fusion.instance.navPathStack?.getParamByIndex(i) as Record<string, Object> | null
        if (param == null) {
          continue
        }
        if (param['navDestinationId'] == entry.navDestinationId) {
          if (i > 0) {
            param['previousIndex'] = --i
          }
          break
        }
      }
    }
    if (entry.navDestinationId != null) {
      Fusion.instance.navPathStack?.disableAnimation(entry.isTransparent())
      Fusion.instance.navPathStack?.removeByNavDestinationId(entry.navDestinationId)
    }
  }

  public isAttached(): boolean {
    for (let containerRef of this.containerStack) {
      if (containerRef.deref()?.isAttached() == true) {
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