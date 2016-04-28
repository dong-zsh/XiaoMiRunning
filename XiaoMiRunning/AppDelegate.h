//
//  AppDelegate.h
//  XiaoMiRunning
//
//  Created by 张东东 on 16/4/25.
//  Copyright © 2016年 zhangdongdong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <CoreLocation/CoreLocation.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    BMKMapManager *mapManager;
    CLLocationManager *LocaManager;
    
}
@property (strong, nonatomic) UIWindow *window;


@end

