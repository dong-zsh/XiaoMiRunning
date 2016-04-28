//
//  AppDelegate.m
//  XiaoMiRunning
//
//  Created by 张东东 on 16/4/25.
//  Copyright © 2016年 zhangdongdong. All rights reserved.
//

#import "AppDelegate.h"
#import "MainMapViewController.h"
#import "SingleLocationManager.h"
#import <BaiduMapAPI_Location/BMKLocationService.h>
@interface AppDelegate ()<BMKLocationServiceDelegate>
@property (nonatomic, strong) SingleLocationManager *Manager;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //百度地图
    mapManager = [[BMKMapManager alloc] init];
    BOOL ret = [mapManager start:@"7n1WWOfQQ9Bu6IfuODIQStgoWkv660mA"  generalDelegate:nil];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    //系统定位 (始终允许定位)
    _Manager = [SingleLocationManager shareManager];
    [_Manager.locationManager requestAlwaysAuthorization];
    _Manager.bmkLocation.delegate = self;
    
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    MainMapViewController *mainVc = [[MainMapViewController alloc] init];
    UINavigationController *naVC = [[UINavigationController alloc] initWithRootViewController:mainVc];
    self.window.rootViewController = naVC;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//    [_Manager.bmkLocation startUserLocationService];
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
