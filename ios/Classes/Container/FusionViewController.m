//
//  FusionViewController.m
//  fusion
//
//  Created by gtbluesky on 2022/3/10.
//

#import "FusionViewController.h"

@interface FusionViewController (SwiftSupport)
+ (FlutterEngine *)fusionSharedEngine;
+ (void)fusionDetachSharedEngine;
- (void)fusion_completeInitWithRouteName:(NSString *)routeName
                               routeArgs:(NSDictionary<NSString *, id> *)routeArgs
                             transparent:(BOOL)transparent
                         backgroundColor:(UIColor *)backgroundColor;
- (void)fusion_decodeRestorableState:(NSCoder *)coder;
- (void)fusion_encodeRestorableState:(NSCoder *)coder;
- (void)onContainerCreate;
- (void)onContainerVisible;
- (void)onContainerInvisible;
- (void)onContainerDestroy;
@end

@implementation FusionViewController

- (instancetype)initWithRouteName:(NSString *)routeName
                        routeArgs:(NSDictionary<NSString *, id> *)routeArgs {
    return [self initWithRouteName:routeName
                         routeArgs:routeArgs
                       transparent:NO
                   backgroundColor:nil];
}

- (instancetype)initWithRouteName:(NSString *)routeName
                        routeArgs:(NSDictionary<NSString *, id> *)routeArgs
                      transparent:(BOOL)transparent
                  backgroundColor:(UIColor *)backgroundColor {
    FlutterEngine *engine = [FusionViewController fusionSharedEngine];
    if (engine != nil) {
        [FusionViewController fusionDetachSharedEngine];
        self = [super initWithEngine:engine nibName:nil bundle:nil];
    } else {
        self = [super initWithProject:nil nibName:nil bundle:nil];
    }
    if (self) {
        [self fusion_completeInitWithRouteName:routeName
                                     routeArgs:routeArgs
                                   transparent:transparent
                               backgroundColor:backgroundColor];
    }
    return self;
}

- (instancetype)initWithRouteName:(NSString *)routeName
                        routeArgs:(NSDictionary<NSString *, id> *)routeArgs
                      transparent:(BOOL)transparent
             backgroundColorValue:(NSInteger)backgroundColorValue {
    uint32_t value = (uint32_t)backgroundColorValue;
    UIColor *color = [UIColor colorWithRed:((value >> 16) & 0xFF) / 255.0
                                     green:((value >> 8) & 0xFF) / 255.0
                                      blue:(value & 0xFF) / 255.0
                                     alpha:((value >> 24) & 0xFF) / 255.0];
    return [self initWithRouteName:routeName
                         routeArgs:routeArgs
                       transparent:transparent
                   backgroundColor:color];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    FlutterEngine *engine = [FusionViewController fusionSharedEngine];
    if (engine != nil) {
        [FusionViewController fusionDetachSharedEngine];
        self = [super initWithEngine:engine nibName:nil bundle:nil];
    } else {
        self = [super initWithProject:nil nibName:nil bundle:nil];
    }
    if (self && engine != nil) {
        [self fusion_decodeRestorableState:coder];
        [self onContainerCreate];
    }
    return self;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [self fusion_encodeRestorableState:coder];
    [super encodeRestorableStateWithCoder:coder];
}

- (void)viewWillAppear:(BOOL)animated {
    [self onContainerVisible];
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self viewDidLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
    [self viewDidLayoutSubviews];
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [UIApplication.sharedApplication.keyWindow endEditing:YES];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self onContainerInvisible];
}

- (void)dealloc {
    [self onContainerDestroy];
}

@end
