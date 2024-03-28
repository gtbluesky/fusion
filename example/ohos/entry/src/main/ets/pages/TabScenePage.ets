import { buildFusionParams, FusionEntry } from '@ohos/fusion'
import List from '@ohos.util.List'
import { FlutterPage } from '@ohos/flutter_ohos'
import CustomFusionEntry from './CustomFusionEntry'

@Entry
@Component
struct TabScenePage {
  @State currentIndex: number = 0
  private flutterEntryList = new List<FusionEntry>()

  aboutToAppear(): void {
    const context = getContext(this)
    const flutterEntry0 = new CustomFusionEntry(
      context,
      buildFusionParams(
        '/background',
        new Map<string, Object>([
          ['title', 'Flutter Tab0'],
          ['backgroundColor', 0xFF546E7A]]),
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

  build() {
    Tabs({
      index: this.currentIndex,
      barPosition: BarPosition.End
    }) {
      TabContent() {
        FlutterPage({ viewId: this.flutterEntryList.get(0).getFlutterView()?.getId() })
      }
      .tabBar('Tab0')

      TabContent() {
        FlutterPage({ viewId: this.flutterEntryList.get(1).getFlutterView()?.getId() })
      }
      .tabBar('Tab1')

      TabContent() {
        FlutterPage({ viewId: this.flutterEntryList.get(2).getFlutterView()?.getId() })
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

  onPageShow(): void {
    this.onTabChange(this.currentIndex)
  }

  onPageHide(): void {
    for (const entry of this.flutterEntryList) {
      entry.onPageHide()
    }
  }

  aboutToDisappear(): void {
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