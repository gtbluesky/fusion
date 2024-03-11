import FusionStackManager from '../container/FusionStackManager'
import Fusion from '../Fusion'

export default class FusionNavigator {
  private constructor() {
  }

  /**
   * 打开新Flutter容器并将对应路由入栈
   * Native页面跳转Flutter页面使用该API
   */
  static open(name: string, args: Map<string, Object> | null = null): void {
    Fusion.instance.delegate?.pushFlutterRoute(name, args)
  }

  /**
   * 在当前Flutter容器中将对应路由入栈
   */
  static push(name: string, args: Map<string, Object> | null = null): void {
    Fusion.instance.engineBinding?.push(name, args)
  }

  /**
   * 在当前Flutter容器中将栈顶路由替换为对应路由
   */
  static replace(name: string, args: Map<string, Object> | null = null): void {
    Fusion.instance.engineBinding?.replace(name, args)
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
   * @param name: 路由名
   */
  static remove(name: string): void {
    Fusion.instance.engineBinding?.remove(name)
  }

  /**
   * 发送全局消息
   */
  static sendMessage(name: string, body: Map<string, Object> | null = null): void {
    FusionStackManager.instance.sendMessage(name, body)
  }
}