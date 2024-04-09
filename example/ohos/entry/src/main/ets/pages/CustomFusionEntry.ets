import { BinaryMessenger, MethodChannel } from '@ohos/flutter_ohos';
import { FusionEntry, FusionMessengerHandler } from '@ohos/fusion';

export default class CustomFusionEntry extends FusionEntry implements FusionMessengerHandler {
  private channel: MethodChannel | null = null

  configureFlutterChannel(binaryMessenger: BinaryMessenger): void {
    this.channel = new MethodChannel(binaryMessenger, 'container_related_channel')
    this.channel.setMethodCallHandler({
      onMethodCall(call, result) {
        result.success(`container_related_channel：${this}_${call.method}`)
      }
    })
  }

  releaseFlutterChannel(): void {
    this.channel?.setMethodCallHandler(null)
    this.channel = null
  }
}