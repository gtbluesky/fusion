import hilog from '@ohos.hilog';
import { FusionEntry, FusionComponent } from '@ohos/fusion';
import CustomFusionEntry from './CustomFusionEntry';

@Entry({ routeName: CustomFusionPage.ROUTE_NAME })
@Component
export default struct CustomFusionPage {
  static ROUTE_NAME = 'CustomFusionPage'
  private flutterEntry: FusionEntry | null = null

  override aboutToAppear() {
    const storage = LocalStorage.getShared()
    this.flutterEntry = new CustomFusionEntry(getContext(this), storage.get('params') as Record<string, Object>)
    this.flutterEntry.aboutToAppear()
    hilog.debug(0xFF00, CustomFusionPage.ROUTE_NAME, 'aboutToAppear')
  }

  override onPageShow() {
    hilog.debug(0xFF00, CustomFusionPage.ROUTE_NAME, 'onPageShow')
    this.flutterEntry?.onPageShow()
  }

  override onPageHide() {
    hilog.debug(0xFF00, CustomFusionPage.ROUTE_NAME, 'onPageHide')
    this.flutterEntry?.onPageHide()
  }

  override aboutToDisappear() {
    hilog.debug(0xFF00, CustomFusionPage.ROUTE_NAME, 'aboutToDisappear')
    this.flutterEntry?.aboutToDisappear()
  }

  override build() {
    Stack() {
      FusionComponent({entry: this.flutterEntry})
    }
  }

  override onBackPress(): boolean {
    this.flutterEntry?.onBackPress()
    return true
  }
}