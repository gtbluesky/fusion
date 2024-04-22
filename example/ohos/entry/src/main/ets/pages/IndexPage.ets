import { FusionNavigator, FusionNotificationBinding, FusionNotificationListener, FusionRouteType } from '@ohos/fusion';
import { promptAction, window } from '@kit.ArkUI';

@Entry({routeName: IndexPage.ROUTE_NAME})
@Component
export default struct IndexPage {
  static ROUTE_NAME = 'IndexPage'

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

  override onPageShow(): void {
    window.getLastWindow(getContext(this), (_, win) => {
      win.setWindowSystemBarProperties({isStatusBarLightIcon: false, statusBarContentColor: '#000000'})
    })
  }

  override aboutToDisappear(): void {
    FusionNotificationBinding.instance.unregister(this.notificationListener)
  }

  override build(): void {
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
          FusionNavigator.push('/native_tab_fixed', null, FusionRouteType.native)
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