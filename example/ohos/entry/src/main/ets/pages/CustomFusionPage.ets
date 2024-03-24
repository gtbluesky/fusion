import { FlutterPage, FlutterView } from '@ohos/flutter_ohos';
import hilog from '@ohos.hilog';
import { FusionEntry } from '@ohos/fusion';
import { router } from '@kit.ArkUI';
import CustomFusionEntry from './CustomFusionEntry';

@Entry
@Component
struct CustomFusionPage {
  private static TAG = 'CustomFusionPage'
  private flutterEntry: FusionEntry | null = null
  private flutterView: FlutterView | null = null

  override aboutToAppear() {
    this.flutterEntry = new CustomFusionEntry(getContext(this), router.getParams() as Record<string, Object>)
    this.flutterEntry.aboutToAppear()
    this.flutterView = this.flutterEntry.getFlutterView()
    hilog.debug(0xFF00, CustomFusionPage.TAG, 'aboutToAppear')
  }

  override onPageShow() {
    hilog.debug(0xFF00, CustomFusionPage.TAG, 'onPageShow')
    this.flutterEntry?.onPageShow()
  }

  override onPageHide() {
    hilog.debug(0xFF00, CustomFusionPage.TAG, 'onPageHide')
    this.flutterEntry?.onPageHide()
  }

  override aboutToDisappear() {
    hilog.debug(0xFF00, CustomFusionPage.TAG, 'aboutToDisappear')
    this.flutterEntry?.aboutToDisappear()
  }

  override build() {
    Stack() {
      FlutterPage({
        viewId: this.flutterView?.getId(),
        // xComponentType: XComponentType.TEXTURE
      })
    }
  }

  override onBackPress(): boolean {
    this.flutterEntry?.onBackPress()
    return true
  }
}