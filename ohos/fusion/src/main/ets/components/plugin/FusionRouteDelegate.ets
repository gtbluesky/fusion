export default interface FusionRouteDelegate {
  pushNativeRoute(name: string, args?: Map<string, Object>): void

  pushFlutterRoute(name: string, args?: Map<string, Object>): void
}