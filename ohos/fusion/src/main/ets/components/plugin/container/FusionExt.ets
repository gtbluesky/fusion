import FusionConstant from '../constant/FusionConstant'

export default function buildFusionParams(
  routeName: string,
  routeArguments: Map<string, Object> | null = null,
  transparent: boolean = false,
  backgroundColor: number = 0xFFFFFFFF
): Record<string, Object> {
  // 受系统API限制，pushUrl无法传递Map类型，通过Record中转
  const routeArgsRecord: Record<string, Object> = {}
  routeArguments?.forEach((value, key) => {
    routeArgsRecord[key] = value
  })
  const record: Record<string, Object> = {}
  record[FusionConstant.ROUTE_NAME] = routeName
  record[FusionConstant.ROUTE_ARGUMENTS] = routeArgsRecord
  record[FusionConstant.EXTRA_BACKGROUND_MODE] = transparent
  record[FusionConstant.EXTRA_BACKGROUND_COLOR] = backgroundColor
  return record
}