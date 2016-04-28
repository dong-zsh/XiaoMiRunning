//
//  SingleLocationManager.m
//  XiaoMiRunning
//
//  Created by 张东东 on 16/4/27.
//  Copyright © 2016年 zhangdongdong. All rights reserved.
//

#import "SingleLocationManager.h"
#import <CoreLocation/CoreLocation.h>

@implementation SingleLocationManager

+ (SingleLocationManager *)shareManager
{
    static SingleLocationManager *sharedSingletonManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedSingletonManagerInstance = [[self alloc] init];
        sharedSingletonManagerInstance.locationManager = [[CLLocationManager alloc] init];
        sharedSingletonManagerInstance.bmkLocation = [[BMKLocationService alloc] init];
    });
    
    return sharedSingletonManagerInstance;
    
}

@end
