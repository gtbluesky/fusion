import { FlutterPage } from '@ohos/flutter_ohos'
import FusionConstant from '../constant/FusionConstant'
import FusionEntry from './FusionEntry'

@Component
export default struct FusionComponent {
  @Require entry!: FusionEntry
  childMode: boolean = false
  private bgColor = BigInt(0xFFFFFFFF)
  private static TAG = 'FusionComponent'

  override aboutToAppear(): void {
    if (!this.childMode) {
      const navInfo = this.queryNavDestinationInfo()
      const navDestinationId = navInfo?.navDestinationId ?? null
      this.entry.navDestinationId = navDestinationId
    }
    this.entry.aboutToAppear()
    this.bgColor = (this.entry.params[FusionConstant.EXTRA_BACKGROUND_COLOR] ?? BigInt(0xFFFFFFFF)) as bigint
  }

  override build(): void {
    Stack() {
      FlutterPage({
        viewId: this.entry.getFlutterView()?.getId(),
        checkMouseWheel: false,
        xComponentColor: this.entry.isTransparent() == true ? Color.Transparent : Number(this.bgColor)
      })
    }
    .onVisibleAreaChange([0.0, 1.0], (isVisible, _) => {
      if (isVisible) {
        this.entry.onPageShow()
      } else {
        this.entry.onPageHide()
      }
    })
  }

  override aboutToDisappear(): void {
    this.entry.aboutToDisappear()
  }
}