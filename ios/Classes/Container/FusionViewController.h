//
//  FusionViewController.h
//  fusion
//
//  Created by gtbluesky on 2022/3/10.
//

#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

/// Flutter container. Subclassable from Swift and Objective-C:
/// `@interface CustomFusionViewController : FusionViewController`.
@interface FusionViewController : FlutterViewController

- (instancetype)initWithRouteName:(NSString *)routeName
                        routeArgs:(nullable NSDictionary<NSString *, id> *)routeArgs;

- (instancetype)initWithRouteName:(NSString *)routeName
                        routeArgs:(nullable NSDictionary<NSString *, id> *)routeArgs
                      transparent:(BOOL)transparent
                  backgroundColor:(nullable UIColor *)backgroundColor;

- (instancetype)initWithRouteName:(NSString *)routeName
                        routeArgs:(nullable NSDictionary<NSString *, id> *)routeArgs
                      transparent:(BOOL)transparent
             backgroundColorValue:(NSInteger)backgroundColorValue;

@end

NS_ASSUME_NONNULL_END
