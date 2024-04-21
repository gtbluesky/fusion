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
    for (const entry of this.flutterEntryList) {
      entry.aboutToAppear()
    }
  }

  override build() {
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
      this.onTabChange(index)
    })
  }

  override onPageShow(): void {
    this.onTabChange(this.currentIndex)
  }

  override onPageHide(): void {
    for (const entry of this.flutterEntryList) {
      entry.onPageHide()
    }
  }

  override aboutToDisappear(): void {
    for (const entry of this.flutterEntryList) {
      entry.aboutToDisappear()
    }
  }

  private onTabChange(index: number): void {
    for (let i = 0; i < this.flutterEntryList.length; i++) {
      const entry = this.flutterEntryList.get(i)
      if (i == index) {
        entry.onPageShow()
      } else {
        entry.onPageHide()
      }
    }
  }
}