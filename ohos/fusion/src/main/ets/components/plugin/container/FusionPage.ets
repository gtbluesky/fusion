import FusionComponent from './FusionComponent'
import FusionEntry from './FusionEntry'

@Entry({ routeName: FusionPage.ROUTE_NAME })
@Component
export default struct FusionPage {
  static ROUTE_NAME = 'FusionPage'
  private flutterEntry: FusionEntry | null = null

  override aboutToAppear(): void {
    this.flutterEntry = new FusionEntry(
      getContext(this),
      LocalStorage.getShared().get('params') as Record<string, Object>
    )
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