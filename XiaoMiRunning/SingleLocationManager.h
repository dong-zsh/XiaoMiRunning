//
//  SingleLocationManager.h
//  XiaoMiRunning
//
//  Created by 张东东 on 16/4/27.
//  Copyright © 2016年 zhangdongdong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <BaiduMapAPI_Location/BMKLocationService.h>


@interface SingleLocationManager : NSObject

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic,strong) BMKLocationService *bmkLocation;

+ (SingleLocationManager *)shareManager;

@end
