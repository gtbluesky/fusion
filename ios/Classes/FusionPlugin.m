#import "FusionPlugin.h"
#if __has_include(<fusion/fusion-Swift.h>)
#import <fusion/fusion-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "fusion-Swift.h"
#endif

@implementation FusionPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFusionPlugin registerWithRegistrar:registrar];
}
@end
