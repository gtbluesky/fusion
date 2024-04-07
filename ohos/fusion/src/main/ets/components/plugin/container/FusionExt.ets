import FusionConstant from '../constant/FusionConstant'

export default function buildFusionParams(
  routeName: string,
  routeArgs: Map<string, Object> | null = null,
  transparent: boolean = false,
  backgroundColor: bigint = BigInt(0xFFFFFFFF)
): Record<string, Object> {
  const record: Record<string, Object> = {}
  record[FusionConstant.ROUTE_NAME] = routeName
  record[FusionConstant.ROUTE_ARGS] = routeArgs ?? new Map<string, Object>()
  record[FusionConstant.EXTRA_BACKGROUND_MODE] = transparent
  record[FusionConstant.EXTRA_BACKGROUND_COLOR] = backgroundColor
  return record
}