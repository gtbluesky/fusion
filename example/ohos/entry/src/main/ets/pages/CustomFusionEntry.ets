import { BinaryMessenger, MethodCall, MethodChannel } from '@ohos/flutter_ohos';
import { MethodCallHandler, MethodResult } from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import { FusionEntry, FusionMessengerHandler } from '@ohos/fusion';

export default class CustomFusionEntry extends FusionEntry implements FusionMessengerHandler, MethodCallHandler {
  private channel: MethodChannel | null = null

  configureFlutterChannel(binaryMessenger: BinaryMessenger): void {
    this.channel = new MethodChannel(binaryMessenger, 'custom_channel')
    this.channel.setMethodCallHandler(this)
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    result.success(`Custom Channel：${this}_${call.method}`)
  }

  releaseFlutterChannel(): void {
    this.channel?.setMethodCallHandler(null)
    this.channel = null
  }
}