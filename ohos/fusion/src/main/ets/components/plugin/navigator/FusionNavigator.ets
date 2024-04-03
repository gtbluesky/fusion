import Fusion from '../Fusion'
import FusionNotificationBinding, { FusionNotificationType } from '../notification/FusionNotification'

export default class FusionNavigator {
  private constructor() {
  }

  /**
   * 将对应路由入栈
   */
  static push(routeName: string, routeArgs: Map<string, Object> | null = null, routeType: FusionRouteType = FusionRouteType.adaption): void {
    switch (routeType) {
      case FusionRouteType.flutterWithContainer:
        Fusion.instance.delegate?.pushFlutterRoute(routeName, routeArgs)
        break
      case FusionRouteType.native:
        Fusion.instance.delegate?.pushNativeRoute(routeName, routeArgs)
        break
      default:
        Fusion.instance.engineBinding?.push(routeName, routeArgs, routeType)
        break
    }
  }

  /**
   * 在当前Flutter容器中将栈顶路由替换为对应路由
   */
  static replace(routeName: string, routeArgs: Map<string, Object> | null = null): void {
    Fusion.instance.engineBinding?.replace(routeName, routeArgs)
  }

  /**
   * 在当前Flutter容器中将栈顶路由出栈
   */
  static pop<T extends Object>(result: T | null = null): void {
    Fusion.instance.engineBinding?.pop(result)
  }

  /**
   * 在当前Flutter容器中将栈顶路由出栈，可被WillPopScope拦截
   */
  static maybePop<T extends Object>(result: T | null = null): void {
    Fusion.instance.engineBinding?.maybePop(result)
  }

  /**
   * 在当前Flutter容器中移除对应路由
   * @param routeName: 路由名
   */
  static remove(routeName: string): void {
    Fusion.instance.engineBinding?.remove(routeName)
  }

  /**
   * 发送消息
   */
  static sendMessage(name: string, body: Map<string, Object> | null = null, type: FusionNotificationType = FusionNotificationType.global): void {
    switch (type) {
      case FusionNotificationType.flutter:
        Fusion.instance.engineBinding?.dispatchMessage(name, body)
        break
      case FusionNotificationType.native:
        FusionNotificationBinding.instance.dispatchMessage(name, body)
        break
      case FusionNotificationType.global:
        FusionNotificationBinding.instance.dispatchMessage(name, body)
        Fusion.instance.engineBinding?.dispatchMessage(name, body)
        break
    }
  }
}

export interface FusionRouteDelegate {
  pushNativeRoute(name: string, args: Map<string, Object> | null): void

  pushFlutterRoute(name: string, args: Map<string, Object> | null): void
}

export enum FusionRouteType {
  flutter,
  flutterWithContainer,
  native,
  adaption
}