//
//  AppDelegate.m
//  tx-test
//
//  Created by 候文福 on 2022/1/29.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "TRTCMeeting.h"
#import "IQKeyboardManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [IQKeyboardManager sharedManager].enable = YES;
//    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    [IQKeyboardManager sharedManager].keyboardDistanceFromTextField = 1.0f;
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = UIColor.whiteColor;
    
    ViewController *ctr = [[ViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ctr];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    NSInteger sdkId = [[ProfileManager shared] getAPPID];
    NSString *userId = [[ProfileManager shared] curUserID];
    NSString *userSig = [[ProfileManager shared] curUserSig];
    [[TRTCMeeting sharedInstance] login:(int)sdkId userId:userId userSig:userSig callback:^(NSInteger code, NSString * _Nullable message) {
        NSLog(@"code == %d, message=%@", code, message);
    }];
    
    
    return YES;
}




@end
