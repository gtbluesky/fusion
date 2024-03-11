export default interface FusionRouteDelegate {
  pushNativeRoute(name: string, args: Map<string, Object> | null): void

  pushFlutterRoute(name: string, args: Map<string, Object> | null): void
}