import { FlutterPage, FlutterView } from '@ohos/flutter_ohos';
import hilog from '@ohos.hilog';
import { FusionEntry } from '@ohos/fusion';

@Entry
@Component
struct TransparentFusionPage {
  private static TAG = 'TransparentFusionPage'
  private flutterEntry: FusionEntry | null = null
  private flutterView: FlutterView | null = null

  override aboutToAppear() {
    const storage = LocalStorage.getShared()
    this.flutterEntry = new FusionEntry(getContext(this), storage.get('params') as Record<string, Object>)
    this.flutterEntry.aboutToAppear()
    this.flutterView = this.flutterEntry.getFlutterView()
    hilog.debug(0xFF00, TransparentFusionPage.TAG, 'aboutToAppear')
  }

  override onPageShow() {
    hilog.debug(0xFF00, TransparentFusionPage.TAG, 'onPageShow')
    this.flutterEntry?.onPageShow()
  }

  override onPageHide() {
    hilog.debug(0xFF00, TransparentFusionPage.TAG, 'onPageHide')
    this.flutterEntry?.onPageHide()
  }

  override aboutToDisappear() {
    hilog.debug(0xFF00, TransparentFusionPage.TAG, 'aboutToDisappear')
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