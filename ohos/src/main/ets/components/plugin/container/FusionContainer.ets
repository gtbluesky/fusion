import List from '@ohos.util.List'

export default interface FusionContainer {
  uniqueId(): string

  history(): List<Map<string, Object | null>>

  isTransparent(): boolean

  isAttached(): boolean

  detachFromContainer(): void
}