import 'package:fusion/src/channel/fusion_channel.dart';
import 'package:fusion/src/navigator/fusion_navigator_delegate.dart';

class FusionNavigator {
  FusionNavigator._();

  static final FusionNavigator _instance = FusionNavigator._();

  static FusionNavigator get instance => _instance;


  Future<T?> push<T extends Object?>(
    String routeName, [
    Map<String, dynamic>? routeArguments,
  ]) async {
    return FusionNavigatorDelegate.instance.push(routeName, routeArguments);
  }

  Future<void> replace(String routeName, [Map<String, dynamic>? routeArguments]) async {
    return FusionNavigatorDelegate.instance.replace(routeName, routeArguments);
  }

  Future<void> pop<T extends Object>([T? result]) async {
    return FusionNavigatorDelegate.instance.pop(result);
  }

  Future<void> remove(String routeName) async {
    return FusionNavigatorDelegate.instance.remove(routeName);
  }

  void sendMessage(String msgName, [Map<String, dynamic>? msgBody]) {
    return FusionChannel.instance.sendMessage(msgName, msgBody);
  }
}
