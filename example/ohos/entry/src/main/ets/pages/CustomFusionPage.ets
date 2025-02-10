import { FusionConstant, FusionComponent, Fusion, FusionEntry } from 'fusion';
import CustomFusionEntry from './CustomFusionEntry';

@Component
export default struct CustomFusionPage {
  @Require param?: Record<string, Object>
  private entry?: FusionEntry

  override aboutToAppear(): void {
    this.entry = new CustomFusionEntry(
      getContext(this),
      this.param
    )
  }

  override build(): void {
    NavDestination() {
      FusionComponent({ entry: this.entry })
    }
    .mode(this.isTransparent() ? NavDestinationMode.DIALOG : NavDestinationMode.STANDARD)
    .hideTitleBar(true)
    .onBackPressed(() => {
      Fusion.instance.engineBinding?.maybePop()
      return true
    })
  }

  private isTransparent(): boolean {
    return (this.param![FusionConstant.EXTRA_BACKGROUND_MODE] ?? false) as boolean
  }
}