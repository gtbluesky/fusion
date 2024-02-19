import { BinaryMessenger } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BinaryMessenger'

export default interface FusionMessengerHandler {
  configureFlutterChannel(binaryMessenger: BinaryMessenger): void
  releaseFlutterChannel(): void
}