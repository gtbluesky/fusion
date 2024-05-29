import { FusionEntry, FusionComponent } from 'fusion';
import CustomFusionEntry from './CustomFusionEntry';

@Entry({ routeName: CustomFusionPage.ROUTE_NAME })
@Component
export default struct CustomFusionPage {
  static ROUTE_NAME = 'CustomFusionPage'
  private flutterEntry: FusionEntry | null = null

  override aboutToAppear(): void {
    const storage = LocalStorage.getShared()
    this.flutterEntry = new CustomFusionEntry(getContext(this), storage.get('params') as Record<string, Object>)
  }

  override build(): void {
    Stack() {
      FusionComponent({entry: this.flutterEntry})
    }
  }

  override onBackPress(): boolean {
    this.flutterEntry?.onBackPress()
    return true
  }
}