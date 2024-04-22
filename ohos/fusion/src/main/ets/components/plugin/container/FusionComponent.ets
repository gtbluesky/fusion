import { FlutterPage } from '@ohos/flutter_ohos'
import FusionConstant from '../constant/FusionConstant'
import FusionEntry from './FusionEntry'

@Component
export default struct FusionComponent {
  entry: FusionEntry | null = null
  @State private showMask: boolean = false
  private bgColor = BigInt(0xFFFFFFFF)

  override async aboutToAppear(): Promise<void> {
    await this.entry?.aboutToAppear()
    this.showMask = this.entry?.isTransparent() == false
    this.bgColor = (this.entry?.params[FusionConstant.EXTRA_BACKGROUND_COLOR] ?? BigInt(0xFFFFFFFF)) as bigint
    getContext(this).eventHub.on(this.entry?.uniqueId(), () => {
      this.showMask = false
    })
  }

  onComponentShow(): void {
    this.entry?.onPageShow()
  }

  onComponentHide(): void {
    this.entry?.onPageHide()
  }

  override aboutToDisappear(): void {
    getContext(this).eventHub.off(this.entry?.uniqueId())
    this.entry?.aboutToDisappear()
    this.entry = null
  }

  override build(): void {
    Stack() {
      FlutterPage({
        viewId: this.entry?.getFlutterView()?.getId(),
      })
      if (this.showMask) {
        Stack()
          .backgroundColor(Number(this.bgColor))
          .width('100%')
          .height('100%')
      }
    }.onVisibleAreaChange([0.0, 1.0], (isVisible, _) => {
      if (isVisible) {
        this.onComponentShow()
      } else {
        this.onComponentHide()
      }
    })
  }
}