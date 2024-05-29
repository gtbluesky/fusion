import { BinaryMessenger } from '@ohos/flutter_ohos'

export default interface FusionMessengerHandler {
  configureFlutterChannel(binaryMessenger: BinaryMessenger): void
  releaseFlutterChannel(): void
}