import { FlutterPage } from '@ohos/flutter_ohos'
import FusionConstant from '../constant/FusionConstant'
import FusionEntry from './FusionEntry'

@Component
export default struct FusionComponent {
  entry: FusionEntry | null = null
  @State private showMask: boolean = false
  private bgColor = BigInt(0xFFFFFFFF)

  override aboutToAppear() {
    // this.showMask = this.entry?.isTransparent() == false
    this.bgColor = (this.entry?.params()[FusionConstant.EXTRA_BACKGROUND_COLOR] ?? BigInt(0xFFFFFFFF)) as bigint
    // getContext(this).eventHub.on(this.entry?.uniqueId(), () => {
    //   this.showMask = false
    // })
  }

  // override aboutToDisappear() {
  //   getContext(this).eventHub.off(this.entry?.uniqueId())
  // }

  override build() {
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
    }
  }
}