import { FusionNavigator, FusionNotificationBinding, FusionNotificationListener, FusionRouteType } from '@ohos/fusion';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct IndexPage {

  private notificationListener: FusionNotificationListener = {
    onReceive(name: string, body: Map<string, Object>| null): void {
      promptAction.showToast({
        message: `onReceive: name=${name}, body=${body}`,
      })
    }
  }

  override aboutToAppear(): void {
    FusionNotificationBinding.instance.register(this.notificationListener)
  }

  override aboutToDisappear(): void {
    FusionNotificationBinding.instance.unregister(this.notificationListener)
  }

  override build() {
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