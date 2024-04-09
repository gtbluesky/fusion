import { FlutterPage, FlutterView } from '@ohos/flutter_ohos'
import FusionConstant from '../constant/FusionConstant'
import FusionEntry from './FusionEntry'

@Entry({routeName: FusionConstant.FUSION_ROUTE_NAME})
@Component
export default struct FusionPage {
  private flutterEntry: FusionEntry | null = null
  private flutterView: FlutterView | null = null

  override aboutToAppear() {
    this.flutterEntry = new FusionEntry(
      getContext(this),
      LocalStorage.getShared().get('params') as Record<string, Object>
    )
    this.flutterEntry.aboutToAppear()
    this.flutterView = this.flutterEntry.getFlutterView()
  }

  override onPageShow() {
    this.flutterEntry?.onPageShow()
  }

  override onPageHide() {
    this.flutterEntry?.onPageHide()
  }

  override aboutToDisappear() {
    this.flutterEntry?.aboutToDisappear()
  }

  override build() {
    Stack() {
      FlutterPage({
        viewId: this.flutterView?.getId(),
      })
    }
  }

  override onBackPress(): boolean {
    this.flutterEntry?.onBackPress()
    return true
  }
}