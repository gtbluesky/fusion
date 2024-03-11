import { FlutterManager, FlutterPage, FlutterView } from '@ohos/flutter_ohos';

@Component
export struct FusionPage {
  @Prop viewId: string = ""

  aboutToAppear() {
    let list: Map<String, FlutterView> = FlutterManager.getInstance().getFlutterViewList();
    const keys = Array.from(list.keys());
    for (let i = 0; i < keys.length; i++) {
      const viewId = keys[i];
      if (viewId !== this.viewId) {
        const flutterView: FlutterView = list.get(viewId) as FlutterView;
        if (flutterView.isAttachedToFlutterEngine()) {
          flutterView.detachFromFlutterEngine();
        }
      }
    }
  }

  build() {
    Stack() {
      FlutterPage({ viewId: this.viewId })
    }
  }
}