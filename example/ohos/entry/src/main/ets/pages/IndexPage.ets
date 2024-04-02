import { FusionNavigator, FusionRouteType } from '@ohos/fusion';

@Entry
@Component
struct IndexPage {
  build() {
    Row() {
      Column() {
        Text('Flutter普通页面场景')
          .fontSize(18).onClick(() => {
          const map = new Map<string, Object>()
          map.set('title', 'HarmonyOS Flutter Page')
          FusionNavigator.push('/index', map, FusionRouteType.adaption)
        }).margin({ top: 20 })
        Text('Flutter透明页面场景')
          .fontSize(18).onClick(() => {
          const map = new Map<string, Object>()
          map.set('title', 'Transparent Flutter Page')
          map.set('transparent', true)
          FusionNavigator.push('/transparent', map, FusionRouteType.flutterWithContainer)
        }).margin({ top: 20 })
        Text('Flutter子页面场景')
          .fontSize(18).onClick(() => {
          FusionNavigator.push('/native_tab_scene', null, FusionRouteType.native)
        }).margin({ top: 20 })
        // Text('Native侧边栏嵌入Flutter场景')
        //   .fontSize(18).onClick(() => {
        // }).margin({ top: 20 })
      }
      .width('100%')
    }
    .height('100%')
  }
}