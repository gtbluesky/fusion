export default function buildFusionParams(
  routeName: string,
  routeArguments: Map<string, Object> = new Map(),
  transparent: boolean = false,
  backgroundColor: number = 0xFFFFFFFF
): Record<string, Object> {
  return {
    'ROUTE_NAME': routeName,
    'ROUTE_ARGUMENTS': routeArguments,
    'background_mode': transparent,
    'background_color': backgroundColor
  }
}