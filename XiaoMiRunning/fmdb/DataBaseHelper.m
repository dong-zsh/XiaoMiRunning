//
//  DataBaseHelper.m
//  XiaoMiRunning
//
//  Created by 张东东 on 16/4/28.
//  Copyright © 2016年 zhangdongdong. All rights reserved.
//

#define DBname @"sqlite.db"
#import "DataBaseHelper.h"

//消息表
static  NSString *createTB_Run = @"CREATE TABLE IF NOT EXISTS RUN_HISTORY (ID INTEGER PRIMARY KEY AUTOINCREMENT, TIME TEXT, RUNDATA BLOB);";

@implementation DataBaseHelper

//数据库路径
+ (NSString *)dbpath
{
    //路径
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dbPath = [docPath stringByAppendingPathComponent:DBname];
    return dbPath;
}
+ (FMDatabase *)creatdb
{
    NSString *path = [DataBaseHelper dbpath];
    //创建数据库
    FMDatabase *db = [FMDatabase databaseWithPath:path];
    NSLog(@"%@",path);
    if ([db open]) {
        //建表
        BOOL result = [db executeUpdate:createTB_Run];
        NSLog(@"建表结果%d",result);
        }
    [db close];
    return db;
}

+ (void)insertRunDataWithdic:(NSDictionary *)dic
{
    FMDatabase *db = [DataBaseHelper creatdb];
    if ([db open]) {
        BOOL rs = [db executeUpdateWithFormat:@"insert into RUN_HISTORY (TIME ,RUNDATA) values (%@, %@);",dic[@"time"],dic[@"runData"]];
        if (rs) {
            NSLog(@"插入成功");
        }else{
            NSLog(@"插入失败");
        }
    }
    [db close];
}
+ (NSData *)selectRunDataWithTime:(NSString *)time
{
    NSData *data = [NSData data];
    FMDatabase *db = [DataBaseHelper creatdb];
    if ([db open]) {
        FMResultSet *result = [db executeQueryWithFormat:@"select *from RUN_HISTORY where TIME = %@",time];
        while ([result next]) {
            data = [result dataForColumn:@"RUNDATA"];
        }
    }
    [db close];
    return data;
}
+ (NSMutableArray *)queryAlltime
{
    NSMutableArray *array = [NSMutableArray array];
    FMDatabase *db = [DataBaseHelper creatdb];
    if ([db open]) {
        FMResultSet *result = [db executeQueryWithFormat:@"select *from RUN_HISTORY"];
        while ([result next]) {
            NSString *time = [result stringForColumn:@"TIME"];
            [array addObject:time];
        }
    }
    [db close];
    return array;
}
@end
