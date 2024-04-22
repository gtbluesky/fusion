import { buildFusionParams, FusionEntry, FusionComponent } from '@ohos/fusion'
import List from '@ohos.util.List'
import CustomFusionEntry from './CustomFusionEntry'

@Entry({ routeName: TabScenePage.ROUTE_NAME })
@Component
export default struct TabScenePage {
  static ROUTE_NAME = 'TabScenePage'
  @State currentIndex: number = 0
  private flutterEntryList = new List<FusionEntry>()

  override aboutToAppear(): void {
    const context = getContext(this)
    const flutterEntry0 = new CustomFusionEntry(
      context,
      buildFusionParams(
        '/background',
        new Map<string, Object>([
          ['title', 'Flutter Tab0'],
          ['backgroundColor', 0xFF546E7A]
        ]),
        false,
        BigInt(0xFF546E7A)
      )
    )
    const flutterEntry1 = new FusionEntry(
      context,
      buildFusionParams(
        '/lifecycle',
        new Map<string, Object>([
          ['title', 'Flutter Tab1']
        ])
      )
    )
    const flutterEntry2 = new FusionEntry(
      context,
      buildFusionParams(
        '/web',
        new Map<string, Object>([
          ['title', 'Flutter Tab2']
        ])
      )
    )
    this.flutterEntryList.add(flutterEntry0)
    this.flutterEntryList.add(flutterEntry1)
    this.flutterEntryList.add(flutterEntry2)
  }

  override build(): void {
    Tabs({
      index: this.currentIndex,
      barPosition: BarPosition.End
    }) {
      TabContent() {
        FusionComponent({ entry: this.flutterEntryList.get(0)})
      }
      .tabBar('Tab0')

      TabContent() {
        FusionComponent({ entry: this.flutterEntryList.get(1)})
      }
      .tabBar('Tab1')

      TabContent() {
        FusionComponent({ entry: this.flutterEntryList.get(2)})
      }
      .tabBar('Tab2')
    }
    .scrollable(false)
    .animationDuration(0)
    .onChange((index) => {
      this.currentIndex = index
    })
  }
}