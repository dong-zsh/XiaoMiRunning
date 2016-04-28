//
//  DataBaseHelper.h
//  XiaoMiRunning
//
//  Created by 张东东 on 16/4/28.
//  Copyright © 2016年 zhangdongdong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface DataBaseHelper : NSObject

+ (FMDatabase *)creatdb;
//出入一次运动轨迹记录
+ (void)insertRunDataWithdic:(NSDictionary *)dic;
//根据时间查询运动轨迹记录
+ (NSData *)selectRunDataWithTime:(NSString *)time;
//查询所有的时间
+ (NSMutableArray *)queryAlltime;
@end
