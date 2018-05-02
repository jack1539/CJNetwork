//
//  AppDelegate.m
//  CJNetworkDemo
//
//  Created by ciyouzen on 6/25/15.
//  Copyright (c) 2015 dvlproad. All rights reserved.
//

#import "AppDelegate.h"
#import "CJNetworkMonitor.h"
#import "DingdangNetworkClient.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[CJNetworkMonitor sharedInstance] startNetworkMonitoring]; //开启网络监听
    
    [self performSelector:@selector(tryAutoLogin) withObject:nil afterDelay:0.35f];
    /*
     如果启动就去检测 建议延时调用
     eg:[self performSelector:@selector(login:) withObject:nil afterDelay:0.35f];
     
     由于检测网络有一定的延迟，所以如果启动app立即去检测调用[AFNetworkReachabilityManager sharedManager].networkReachabilityStatus 有可能得到的是status == AFNetworkReachabilityStatusUnknown;但是此时明明是有网的，建议在收到监听网络状态回调以后再取[AFNetworkReachabilityManager sharedManager].networkReachabilityStatus。
     */
    
    return YES;
}

- (void)tryAutoLogin{
    //自动登录的功能
    NSString *name = [LoginHelper loginName];
    NSString *pasd = [LoginHelper loginPasd];
    if (name == nil) {
        //[self goLogin];
    }else{
        [[DingdangNetworkClient sharedInstance] requestDDLogin_name:name pasd:pasd completeBlock:^(CJResponseModel *responseModel) {
            if (responseModel.status == 0) {
                NSLog(@"获取acces_token成功，代表登录成功");
            } else {
                NSLog(@"登录不了哦，再试试看！");
            }
        }];
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
