import FusionConstant from '../constant/FusionConstant'
import Fusion from '../Fusion'
import FusionComponent from './FusionComponent'
import FusionEntry from './FusionEntry'

@Component
export default struct FusionPage {
  @Require param?: Record<string, Object>
  private entry?: FusionEntry

  override aboutToAppear(): void {
    this.entry = new FusionEntry(
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