//
//  DataManager.m
//  CommonageNet
//
//  Created by qianfeng on 15-1-8.
//  Copyright (c) 2015年 qianfeng. All rights reserved.
//

#import "DataManager.h"
#import "DeviceModel.h"
#import "DeviceSetModel.h"
#import "ContactModel.h"
#import "AudioModel.h"
#import "MessageModel.h"
#import "ShortMessageModel.h"
#import "LocationModel.h"
#import "PhotoModel.h"
#import "LocationCache.h"
#import "Friendlist.h"

@interface DataManager ()
{
    
    FMDatabaseQueue *dbBase;
    
    FMDatabase *_dataBase;
    BOOL show;
}

@end

@implementation DataManager

-(id)init
{
    if(self = [super init]){
        self.isLogin = true;
    //    [self createDataBaseAndTable];
      //  [self createDeviceSetTable];
      //  [self createContactTable];
    }
    return self;
}

+(id)shareInstance
{
    
    NSLock *thelock = [[NSLock alloc] init];
   
    static DataManager *dm = nil;
    if(dm == nil){
        
        dm = [[DataManager alloc] init];
        
    }
    
    return dm;
}

#pragma mark - 设备列表信息

-(void)createDataBaseAndTable
{
    NSString *path = [NSString stringWithFormat:@"%@/Documents/dayi.data",NSHomeDirectory()];
    dbBase = [FMDatabaseQueue databaseQueueWithPath:path];
}

- (void)createDeviceTable
{
    //        if ([db open]) {
                //数据库建表，插入语句

    [dbBase inDatabase:^(FMDatabase *db) {
        
        NSString * sql1 = @"drop table favourite_info";
        BOOL b1=[db executeUpdate:sql1];
        if(b1)
        {
            NSLog(@"biao delete  !!");
        }else
        {
            NSLog(@"ERRor      ........");
        }
        
        NSString *sql = @"create table if not exists favourite_info(ActiveDate varchar(500),BabyName varchar(500) ,BindNumber varchar(200) ,DeviceType varchar(300),Birthday varchar(300) ,CreateTime varchar(500) , CurrentFirmware varchar(200) ,DeviceID varchar(200) ,DeviceModelID varchar(200) ,Firmware varchar(200) ,Gender varchar(200) ,Grade varchar(200) ,HireExpireDate varchar(200) ,Date varchar(200) ,HomeAddress varchar(200) ,HomeLat varchar(200) ,HomeLng varchar(200) ,IsGuard varchar(200) ,Password varchar(200) ,PhoneCornet varchar(200) ,PhoneNumber varchar(200) ,Photo varchar(200) ,SchoolAddress varchar(200) ,SchoolLat varchar(200) ,SchoolLng varchar(200) , SerialNumber varchar(200) ,UpdateTime varchar(200) ,UserId varchar(200),SetVersionNO varchar(200) , ContactVersionNO varchar(200) ,OperatorType varchar(200) ,SmsNumber varchar(200),SmsBalanceKey varchar(200) , SmsFlowKey varchar(200), LatestTime varchar(200));";
        
        BOOL b = [db executeUpdate:sql];
        
        if(b == NO){
            NSLog(@"数据表创建失败");
            return;
        }
        NSLog(@"数据表创建成功");
    }];

}

- (void)dropTable
{
    [dbBase inDatabase:^(FMDatabase *db) {
        
      
    }];
    
}

#pragma mark - 删除条目
-(void)deleteItemById:(NSString *)BindNumber
{
    [dbBase inDatabase:^(FMDatabase *db) {
        
        NSString *sql = @"delete from favourite_info where BindNumber=?";
        BOOL b = [db executeUpdate:sql,BindNumber];
        if(b){
            NSLog(@"删除条目成功");
        }else{
            
            NSLog(@"删除条目失败");
        }

    }];
}

#pragma mark - 添加内容到数据库
-(void)addFavourite:(NSString *)ActiveDate andBabyName:(NSString *)BabyName andBindNumber:(NSString *)BindNumber andDeviceType:(NSString *)DeviceType andBirthday:(NSString *)Birthday andCreateTime:(NSString *)CreateTime andCurrentFirmware:(NSString *)CurrentFirmware andDeviceID:(NSString *)DeviceID andDeviceModelID:(NSString *)DeviceModelID andFirmware:(NSString *)Firmware andGender:(NSString *)Gender andGrade:(NSString *)Grade andHireExpireDate:(NSString *)HireExpireDate andDate:(NSString *)Date andHomeAddress:(NSString *)HomeAddress andHomeLat:(NSString *)HomeLat andHomeLng:(NSString *)HomeLng andIsGuard:(NSString *)IsGuard andPassword:(NSString *)Password andPhoneCornet:(NSString *)PhoneCornet andPhoneNumber:(NSString *)PhoneNumber andPhoto:(NSString *)Photo andSchoolAddress:(NSString *)SchoolAddress andSchoolLat:(NSString *)SchoolLat andSchoolLng:(NSString *)SchoolLng andSerialNumber:(NSString *)SerialNumber andUpdateTime:(NSString *)UpdateTime andUserId:(NSString *)UserId andSetVersionNO:(NSString *)SetVersionNO andContactVersionNO:(NSString *)ContactVersionNO andOperatorType:(NSString *)OperatorType andSmsNumber:(NSString *)SmsNumber andSmsBalanceKey:(NSString *)SmsBalanceKey andSmsFlowKey:(NSString *)SmsFlowKey andLatestTime:(NSString *)LatestTime
{
    
    [dbBase inDatabase:^(FMDatabase *db) {
        
        NSString *sql = [NSString stringWithFormat:@"insert into favourite_info(ActiveDate,BabyName,BindNumber,DeviceType,Birthday,CreateTime,CurrentFirmware,DeviceID,DeviceModelID,Firmware,Gender,Grade,HireExpireDate,Date,HomeAddress,HomeLat,HomeLng,IsGuard,Password,PhoneCornet,PhoneNumber,Photo,SchoolAddress,SchoolLat,SchoolLng,SerialNumber,UpdateTime,UserId,SetVersionNO,ContactVersionNO,OperatorType,SmsNumber,SmsBalanceKey,SmsFlowKey,LatestTime) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"];
        
        BOOL b = [db executeUpdate:sql,ActiveDate,BabyName,BindNumber,DeviceType,Birthday,CreateTime,CurrentFirmware,DeviceID,DeviceModelID,Firmware,Gender,Grade,HireExpireDate,Date,HomeAddress,HomeLat,HomeLng,IsGuard,Password,PhoneCornet,PhoneNumber,Photo,SchoolAddress,SchoolLat,SchoolLng,SerialNumber,UpdateTime,UserId,SetVersionNO,ContactVersionNO,OperatorType,SmsNumber,SmsBalanceKey,SmsFlowKey,LatestTime];
        
    }];
}



#pragma mark - 查找数据
-(BOOL)isFavourite:(NSString *)BindNumber
{
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = @"select count(*) from favourite_info where BindNumber=?";
        
        FMResultSet *result = [db executeQuery:sql,BindNumber];
        while ([result next]) {
            int count = [[result stringForColumnIndex:0] intValue];
            if(count > 0){
                NSString *baby = [result stringForColumnIndex:1];
                
                show = NO;
            }
            
            show = YES;
        }

    }];
    
    return show;
 }
- (NSMutableArray *)isSelect:(NSString *)BindNumber
{
    
    NSMutableArray *dataArr = [[NSMutableArray alloc] init];

    [dbBase inDatabase:^(FMDatabase *db) {
        
        NSString *sql = @"select * from favourite_info where BindNumber=?";
        FMResultSet *result = [db executeQuery:sql,BindNumber];
        while ([result next]) {
            DeviceModel *model = [[DeviceModel alloc] init];
//            model.CloudPlatform = [result stringForColumnIndex:35];
            model.ActiveDate = [result stringForColumnIndex:0];
            model.BabyName = [result stringForColumnIndex:1];
            model.BindNumber = [result stringForColumnIndex:2];
            model.DeviceType = [result stringForColumnIndex:3];
            model.Birthday = [result stringForColumnIndex:4];
            model.CreateTime = [result stringForColumnIndex:5];
            model.CurrentFirmware = [result stringForColumnIndex:6];
            model.DeviceID = [result stringForColumnIndex:7];
            model.DeviceModelID = [result stringForColumnIndex:8];
            model.Firmware = [result stringForColumnIndex:9];
            model.Gender = [result stringForColumnIndex:10];
            model.Grade = [result stringForColumnIndex:11];
            model.HireExpireDate = [result stringForColumnIndex:12];
            model.Date = [result stringForColumnIndex:13];
            model.HomeAddress = [result stringForColumnIndex:14];
            model.HomeLat = [result stringForColumnIndex:15];
            model.HomeLng = [result stringForColumnIndex:16];
            model.IsGuard = [result stringForColumnIndex:17];
            model.Password = [result stringForColumnIndex:18];
            model.PhoneCornet = [result stringForColumnIndex:19];
            model.PhoneNumber = [result stringForColumnIndex:20];
            model.Photo = [result stringForColumnIndex:21];
            model.SchoolAddress = [result stringForColumnIndex:22];
            model.SchoolLat = [result stringForColumnIndex:23];
            model.SchoolLng = [result stringForColumnIndex:24];
            model.SerialNumber = [result stringForColumnIndex:25];
            model.UpdateTime = [result stringForColumnIndex:26];
            model.UserId = [result stringForColumnIndex:27];
            model.SetVersionNO = [result stringForColumnIndex:28];
            model.ContactVersionNO = [result stringForColumnIndex:29];
            model.OperatorType = [result stringForColumnIndex:30];
            model.SmsNumber = [result stringForColumnIndex:31];
            model.SmsBalanceKey = [result stringForColumnIndex:32];
            model.SmsFlowKey = [result stringForColumnIndex:33];
            model.LatestTime = [result stringForColumnIndex:34];
            [dataArr addObject:model];
            
        }
    }];

    return  dataArr;
}

- (NSMutableArray *)isSelectFaWithDevice:(NSString *)Device
{
    
    NSMutableArray *dataArr = [[NSMutableArray alloc] init];
    
    [dbBase inDatabase:^(FMDatabase *db) {
        
        NSString *sql = @"select * from favourite_info where DeviceID=?";
        FMResultSet *result = [db executeQuery:sql,Device];
        while ([result next]) {
            DeviceModel *model = [[DeviceModel alloc] init];
//            model.CloudPlatform = [result stringForColumnIndex:35];
            model.ActiveDate = [result stringForColumnIndex:0];
            model.BabyName = [result stringForColumnIndex:1];
            model.BindNumber = [result stringForColumnIndex:2];
            model.DeviceType = [result stringForColumnIndex:3];
            model.Birthday = [result stringForColumnIndex:4];
            model.CreateTime = [result stringForColumnIndex:5];
            model.CurrentFirmware = [result stringForColumnIndex:6];
            model.DeviceID = [result stringForColumnIndex:7];
            model.DeviceModelID = [result stringForColumnIndex:8];
            model.Firmware = [result stringForColumnIndex:9];
            model.Gender = [result stringForColumnIndex:10];
            model.Grade = [result stringForColumnIndex:11];
            model.HireExpireDate = [result stringForColumnIndex:12];
            model.Date = [result stringForColumnIndex:13];
            model.HomeAddress = [result stringForColumnIndex:14];
            model.HomeLat = [result stringForColumnIndex:15];
            model.HomeLng = [result stringForColumnIndex:16];
            model.IsGuard = [result stringForColumnIndex:17];
            model.Password = [result stringForColumnIndex:18];
            model.PhoneCornet = [result stringForColumnIndex:19];
            model.PhoneNumber = [result stringForColumnIndex:20];
            model.Photo = [result stringForColumnIndex:21];
            model.SchoolAddress = [result stringForColumnIndex:22];
            model.SchoolLat = [result stringForColumnIndex:23];
            model.SchoolLng = [result stringForColumnIndex:24];
            model.SerialNumber = [result stringForColumnIndex:25];
            model.UpdateTime = [result stringForColumnIndex:26];
            model.UserId = [result stringForColumnIndex:27];
            model.SetVersionNO = [result stringForColumnIndex:28];
            model.ContactVersionNO = [result stringForColumnIndex:29];
            model.OperatorType = [result stringForColumnIndex:30];
            model.SmsNumber = [result stringForColumnIndex:31];
            model.SmsBalanceKey = [result stringForColumnIndex:32];
            model.SmsFlowKey = [result stringForColumnIndex:33];
            model.LatestTime = [result stringForColumnIndex:34];
            [dataArr addObject:model];
            
        }
    }];
    
    return  dataArr;
}

#pragma mark - 删除数据
-(void)removeFavourite:(NSString *)BindNumber
{
    [dbBase inDatabase:^(FMDatabase *db) {
        
        NSString *sql = @"delete from favourite_info where BindNumber=?";
        BOOL b = [db executeUpdate:sql,BindNumber];
    }];

}

#pragma mark - 返回数组到收藏界面
-(NSMutableArray *)getAllFavourie
{
    NSMutableArray *dataArr = [[NSMutableArray alloc] init];
    
    [dbBase inDatabase:^(FMDatabase *db) {
        
        NSString *sql = @"select * from favourite_info";
        FMResultSet *result = [db executeQuery:sql];
        while ([result next]) {
            DeviceModel *model = [[DeviceModel alloc] init];
//            model.CloudPlatform = [result stringForColumnIndex:35];
            model.ActiveDate = [result stringForColumnIndex:0];
            model.BabyName = [result stringForColumnIndex:1];
            model.BindNumber = [result stringForColumnIndex:2];
            model.DeviceType = [result stringForColumnIndex:3];
            model.Birthday = [result stringForColumnIndex:4];
            model.CreateTime = [result stringForColumnIndex:5];
            model.CurrentFirmware = [result stringForColumnIndex:6];
            model.DeviceID = [result stringForColumnIndex:7];
            model.DeviceModelID = [result stringForColumnIndex:8];
            model.Firmware = [result stringForColumnIndex:9];
            model.Gender = [result stringForColumnIndex:10];
            model.Grade = [result stringForColumnIndex:11];
            model.HireExpireDate = [result stringForColumnIndex:12];
            model.Date = [result stringForColumnIndex:13];
            model.HomeAddress = [result stringForColumnIndex:14];
            model.HomeLat = [result stringForColumnIndex:15];
            model.HomeLng = [result stringForColumnIndex:16];
            model.IsGuard = [result stringForColumnIndex:17];
            model.Password = [result stringForColumnIndex:18];
            model.PhoneCornet = [result stringForColumnIndex:19];
            model.PhoneNumber = [result stringForColumnIndex:20];
            model.Photo = [result stringForColumnIndex:21];
            model.SchoolAddress = [result stringForColumnIndex:22];
            model.SchoolLat = [result stringForColumnIndex:23];
            model.SchoolLng = [result stringForColumnIndex:24];
            model.SerialNumber = [result stringForColumnIndex:25];
            model.UpdateTime = [result stringForColumnIndex:26];
            model.UserId = [result stringForColumnIndex:27];
            model.SetVersionNO = [result stringForColumnIndex:28];
            model.ContactVersionNO = [result stringForColumnIndex:29];
            model.OperatorType = [result stringForColumnIndex:30];
            model.SmsNumber = [result stringForColumnIndex:31];
            model.SmsBalanceKey = [result stringForColumnIndex:32];
            model.SmsFlowKey = [result stringForColumnIndex:33];
            model.LatestTime = [result stringForColumnIndex:34];
            
            [dataArr addObject:model];
        }

    }];
    
       return dataArr;
}
//-------------------------------------------设置表----------------------------------------------
//-------------------------------------------设置表----------------------------------------------
#pragma mark - 设置表
- (void)createDeviceSetTable
{
    [dbBase inDatabase:^(FMDatabase *db) {
      //  [self dropDeviceSetTable];
        NSString * sql1 = @"drop table device_set";
        BOOL b1=[db executeUpdate:sql1];
        if(b1)
        {
            NSLog(@"device_set biao delete  !!");
        }else
        {
            NSLog(@"ERRor      ........");
        }
        
        NSString *sql = @"create table if not exists device_set(BindNumber varchar(500) ,VersionNumber varchar(500) ,AutoAnswer varchar(200) ,ReportCallsPosition varchar(300) ,BodyFeelingAnswer varchar(500) , ExtendEmergencyPower varchar(200) ,ClassDisable varchar(200) ,TimeSwitchMachine varchar(200) ,RefusedStrangerCalls varchar(200) ,WatchOffAlarm varchar(200) ,WatchCallVoice varchar(200) ,WatchCallVibrate varchar(200) ,WatchInformationSound varchar(200) ,WatchInformationShock varchar(200) ,ClassDisabled1 varchar(200) ,ClassDisabled2 varchar(200) ,ClassDisabled3 varchar(200) ,ClassDisabled4 varchar(200) ,WeekDisabled varchar(200) ,TimerOpen varchar(200) ,TimerClose varchar(200) ,BrightScreen varchar(200),weekAlarm1 varchar(200),weekAlarm2 varchar(200),weekAlarm3 varchar(200),alarm1 varchar(200),alarm2 varchar(200),alarm3 varchar(200),locationMode varchar(200),locationTime varchar(200),flowerNumber varchar(200),StepCalculate varchar(200),SleepCalculate varchar(200),HrCalculate varchar(200),SosMsgswitch varchar(200),TimeZone varchar(200),Language varchar(200),dialPad varchar(200));";
        
        BOOL b = [db executeUpdate:sql];
        if(b == NO){
            NSLog(@"设备设置数据表创建失败");
            return;
        }
        NSLog(@"设备设置数据表创建成功");

    }];
    
}
- (void)dropDeviceSetTable
{
    
    [dbBase inDatabase:^(FMDatabase *db) {
          }];

 }
#pragma mark - 删除条目
-(void)deleDeviceSetItem:(NSString *)BindNumber
{
    
    [dbBase inDatabase:^(FMDatabase *db) {
        
        NSString *sql = @"delete from device_set where BindNumber=?";
        BOOL b = [db executeUpdate:sql,BindNumber];
        if(b){
            NSLog(@"删除条目成功");
        }else{
            
            NSLog(@"删除条目失败");
        }
    }];
    
 }
#pragma mark - 添加内容到数据库
-(void)addDeviceSetTable:(NSString *)BindNumber andVersionNumber:(NSString *)VersionNumber andAutoAnswer:(NSString *)AutoAnswer andReportCallsPosition:(NSString *)ReportCallsPosition andBodyFeelingAnswer:(NSString *)BodyFeelingAnswer andExtendEmergencyPower:(NSString *)ExtendEmergencyPower andClassDisable:(NSString *)ClassDisable andTimeSwitchMachine:(NSString *)TimeSwitchMachine andRefusedStrangerCalls:(NSString *)RefusedStrangerCalls andWatchOffAlarm:(NSString *)WatchOffAlarm  andWatchCallVoice:(NSString *)WatchCallVoice andWatchCallVibrate:(NSString *)WatchCallVibrate andWatchInformationSound:(NSString *)WatchInformationSound andWatchInformationShock:(NSString *)WatchInformationShock andClassDisabled1:(NSString *)ClassDisabled1 andClassDisabled2:(NSString *)ClassDisabled2 andClassDisabled3:(NSString *)ClassDisabled3 andClassDisabled4:(NSString *)ClassDisabled4 andWeekDisabled:(NSString *)WeekDisabled andTimerOpen:(NSString *)TimerOpen andTimerClose:(NSString *)TimerClose andBrightScreen:(NSString *)BrightScreen andweekAlarm1:(NSString *)weekAlarm1 andweekAlarm2:(NSString *)weekAlarm2 andweekAlarm3:(NSString *)weekAlarm3 andalarm1:(NSString *)alarm1 andalarm2:(NSString *)alarm2 andalarm3:(NSString *)alarm3 andlocationMode:(NSString *)locationMode andlocationTime:(NSString *)locationTime andflowerNumber:(NSString *)flowerNumber andStepCalculate:(NSString *)StepCalculate andSleepCalculate:(NSString *)SleepCalculate andHrCalculate:(NSString *)HrCalculate andSosMsgswitch:(NSString *)SosMsgswitch andTimeZone:(NSString *)TimeZone andLanguage:(NSString *)Language andDialPad:(NSString *)dialPad
{
    
    [dbBase inDatabase:^(FMDatabase *db) {
        
        NSString *sql = [NSString stringWithFormat:@"insert into device_set(BindNumber,VersionNumber,AutoAnswer,ReportCallsPosition,BodyFeelingAnswer,ExtendEmergencyPower,ClassDisable,TimeSwitchMachine,RefusedStrangerCalls,WatchOffAlarm,WatchCallVoice,WatchCallVibrate,WatchInformationSound,WatchInformationShock,ClassDisabled1,ClassDisabled2,ClassDisabled3,ClassDisabled4,WeekDisabled,TimerOpen,TimerClose,BrightScreen,weekAlarm1,weekAlarm2,weekAlarm3,alarm1,alarm2,alarm3,locationMode,locationTime,flowerNumber,StepCalculate,SleepCalculate,HrCalculate,SosMsgswitch,TimeZone,Language,dialPad) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"];
        
        BOOL b = [db executeUpdate:sql,BindNumber,VersionNumber,AutoAnswer,ReportCallsPosition,BodyFeelingAnswer,ExtendEmergencyPower,ClassDisable,TimeSwitchMachine,RefusedStrangerCalls,WatchOffAlarm,WatchCallVoice,WatchCallVibrate,WatchInformationSound,WatchInformationShock,ClassDisabled1,ClassDisabled2,ClassDisabled3,ClassDisabled4,WeekDisabled,TimerOpen,TimerClose,BrightScreen,weekAlarm1,weekAlarm2,weekAlarm3,alarm1,alarm2,alarm3,locationMode,locationTime,flowerNumber,StepCalculate,SleepCalculate,HrCalculate,SosMsgswitch,TimeZone,Language,dialPad];
    }];
}
//
//#pragma mark - 查找数据
//-(void)DeviceSetTable:(NSString *)BindNumber
//{
//    [dbBase inDatabase:^(FMDatabase *db) {
//        
//        NSString *sql = @"select count(*) from device_set where BindNumber=?";
//        FMResultSet *result = [db executeQuery:sql,BindNumber];
//        while ([result next]) {
//            int count = [[result stringForColumnIndex:0] intValue];
//            if(count > 0){
//                NSString *baby = [result stringForColumnIndex:1];
//                
//            }
//            
//        }
//    }];
//
//}
- (NSMutableArray *)isSelectDeviceSetTable:(NSString *)BindNumber
{
    NSMutableArray *dataArr = [[NSMutableArray alloc] init];
    
    [dbBase inDatabase:^(FMDatabase *db) {
        
        NSString *sql = @"select * from device_set where BindNumber=?";
        FMResultSet *result = [db executeQuery:sql,BindNumber];
        while ([result next]) {
            DeviceSetModel *model = [[DeviceSetModel alloc] init];
            
            model.BindNumber = [result stringForColumnIndex:0];
            model.VersionNumber = [result stringForColumnIndex:1];
            model.AutoAnswer = [result stringForColumnIndex:2];
            model.ReportCallsPosition = [result stringForColumnIndex:3];
            model.BodyFeelingAnswer = [result stringForColumnIndex:4];
            model.ExtendEmergencyPower = [result stringForColumnIndex:5];
            model.ClassDisable = [result stringForColumnIndex:6];
            model.TimeSwitchMachine = [result stringForColumnIndex:7];
            model.RefusedStrangerCalls = [result stringForColumnIndex:8];
            model.WatchOffAlarm = [result stringForColumnIndex:9];
            model.WatchCallVoice = [result stringForColumnIndex:10];
            model.WatchCallVibrate = [result stringForColumnIndex:11];
            model.WatchInformationSound = [result stringForColumnIndex:12];
            model.WatchInformationShock = [result stringForColumnIndex:13];
            model.ClassDisabled1 = [result stringForColumnIndex:14];
            model.ClassDisabled2 = [result stringForColumnIndex:15];
            model.ClassDisabled3 = [result stringForColumnIndex:16];
            model.ClassDisabled4 = [result stringForColumnIndex:17];
            model.WeekDisabled = [result stringForColumnIndex:18];
            model.TimerOpen = [result stringForColumnIndex:19];
            model.TimerClose = [result stringForColumnIndex:20];
            model.BrightScreen = [result stringForColumnIndex:21];
            model.weekAlarm1 = [result stringForColumnIndex:22];
            model.weekAlarm2 = [result stringForColumnIndex:23];
            model.weekAlarm3 = [result stringForColumnIndex:24];
            model.alarm1 = [result stringForColumnIndex:25];
            model.alarm2 = [result stringForColumnIndex:26];
            model.alarm3 = [result stringForColumnIndex:27];
            model.locationMode = [result stringForColumnIndex:28];
            model.locationTime = [result stringForColumnIndex:29];
            model.flowerNumber = [result stringForColumnIndex:30];
            model.StepCalculate = [result stringForColumnIndex:31];
            model.SleepCalculate = [result stringForColumnIndex:32];
            model.HrCalculate = [result stringForColumnIndex:33];
            model.SosMsgswitch = [result stringForColumnIndex:34];
            model.TimeZone = [result stringForColumnIndex:35];
            model.Language = [result stringForColumnIndex:36];
            model.dialPad = [result stringForColumnIndex:37];
            [dataArr addObject:model];
            
        }
    }];

      return  dataArr;
}


#pragma mark - 删除数据
-(void)removeDeviceSetTable:(NSString *)BindNumber
{
    
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = @"delete from device_set where BindNumber=?";
        BOOL b = [db executeUpdate:sql,BindNumber];

    }];
    
}

#pragma mark - 返回数组到收藏界面
-(NSMutableArray *)getAllDeviceSetTable
{
    NSMutableArray *dataArr = [[NSMutableArray alloc] init];
    
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = @"select * from device_set";
        FMResultSet *result = [db executeQuery:sql];
        while ([result next]) {
            DeviceSetModel *model = [[DeviceSetModel alloc] init];
            
            model.BindNumber = [result stringForColumnIndex:0];
            model.VersionNumber = [result stringForColumnIndex:1];
            model.AutoAnswer = [result stringForColumnIndex:2];
            model.ReportCallsPosition = [result stringForColumnIndex:3];
            model.BodyFeelingAnswer = [result stringForColumnIndex:4];
            model.ExtendEmergencyPower = [result stringForColumnIndex:5];
            model.ClassDisable = [result stringForColumnIndex:6];
            model.TimeSwitchMachine = [result stringForColumnIndex:7];
            model.RefusedStrangerCalls = [result stringForColumnIndex:8];
            model.WatchOffAlarm = [result stringForColumnIndex:9];
            model.WatchCallVoice = [result stringForColumnIndex:10];
            model.WatchCallVibrate = [result stringForColumnIndex:11];
            model.WatchInformationSound = [result stringForColumnIndex:12];
            model.WatchInformationShock = [result stringForColumnIndex:13];
            model.ClassDisabled1 = [result stringForColumnIndex:14];
            model.ClassDisabled2 = [result stringForColumnIndex:15];
            model.ClassDisabled3 = [result stringForColumnIndex:16];
            model.ClassDisabled4 = [result stringForColumnIndex:17];
            model.WeekDisabled = [result stringForColumnIndex:18];
            model.TimerOpen = [result stringForColumnIndex:19];
            model.TimerClose = [result stringForColumnIndex:20];
            model.BrightScreen = [result stringForColumnIndex:21];
            model.weekAlarm1 = [result stringForColumnIndex:22];
            model.weekAlarm2 = [result stringForColumnIndex:23];
            model.weekAlarm3 = [result stringForColumnIndex:24];
            model.alarm1 = [result stringForColumnIndex:25];
            model.alarm2 = [result stringForColumnIndex:26];
            model.alarm3 = [result stringForColumnIndex:27];
            model.locationMode = [result stringForColumnIndex:28];
            model.locationTime = [result stringForColumnIndex:29];
            model.flowerNumber = [result stringForColumnIndex:30];
            model.StepCalculate = [result stringForColumnIndex:31];
            model.SleepCalculate = [result stringForColumnIndex:32];
            model.HrCalculate = [result stringForColumnIndex:33];
            model.SosMsgswitch = [result stringForColumnIndex:34];
            model.TimeZone = [result stringForColumnIndex:35];
            model.Language = [result stringForColumnIndex:36];
            model.dialPad = [result stringForColumnIndex:37];
            [dataArr addObject:model];
        }
        
    }];
    
        return dataArr;
}

//----------------------------------联系人--------------------------------------------------------
//----------------------------------联系人--------------------------------------------------------
#pragma mark - 联系人
- (void)createContactTable
{
    [dbBase inDatabase:^(FMDatabase *db) {
      //  [self dropContactTable];
        NSString * sql1 = @"drop table contact_tal";
        BOOL b1=[db executeUpdate:sql1];
        if(b1)
        {
            NSLog(@"ContactTable biao delete  !!");
        }else
        {
            NSLog(@"ERRor      ........");
        }

        
        NSString *sql = @"create table if not exists contact_tal(BindNumber varchar(500) ,DeviceContactId varchar(500) ,Relationship varchar(200) ,Photo varchar(300) ,PhoneNumber varchar(500) , PhoneShort varchar(200) ,Type varchar(200) ,ObjectId varchar(200) ,HeadImg varchar(2000));";
        
        BOOL b = [db executeUpdate:sql];
        if(b == NO){
            NSLog(@"联系人数据表创建失败");
            return;
        }
        NSLog(@"联系人数据表创建成功");
    }];
}

- (void)dropContactTable
{
    [dbBase inDatabase:^(FMDatabase *db) {
          }];
    
}

#pragma mark - 删除条目
-(void)deleContactItem:(NSString *)DeviceContactId
{
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = @"delete from contact_tal where DeviceContactId=?";
        BOOL b = [db executeUpdate:sql,DeviceContactId];
        if(b){
            NSLog(@"删除联系人成功");
        }else{
            
            NSLog(@"删除联系人失败");
        }
    }];
    
}

#pragma mark - 添加内容到数据库
-(void)addContactTable:(NSString *)BindNumber andDeviceContactId:(NSString *)DeviceContactId andRelationship:(NSString *)Relationship andPhoto:(NSString *)Photo andPhoneNumber:(NSString *)PhoneNumber andPhoneShort:(NSString *)PhoneShort andType:(NSString *)Type andObjectId:(NSString *)ObjectId andHeadImg:(NSString *)HeadImg
{
    
    [dbBase inDatabase:^(FMDatabase *db) {
        
        NSString *sql = [NSString stringWithFormat:@"insert into contact_tal(BindNumber,DeviceContactId,Relationship,Photo,PhoneNumber,PhoneShort,Type,ObjectId,HeadImg) values(?,?,?,?,?,?,?,?,?)"];
        
        BOOL b = [db executeUpdate:sql,BindNumber,DeviceContactId,Relationship,Photo,PhoneNumber,PhoneShort,Type,ObjectId,HeadImg];
        
        
    }];
   
}

- (NSMutableArray *)isSelectContactTable:(NSString *)BindNumber
{
    NSMutableArray *dataArr = [[NSMutableArray alloc] init];

    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = @"select * from contact_tal where BindNumber=?";
        FMResultSet *result = [db executeQuery:sql,BindNumber];
        while ([result next]) {
            ContactModel *model = [[ContactModel alloc] init];
            model.BindNumber = [result stringForColumnIndex:0];
            model.DeviceContactId = [result stringForColumnIndex:1];
            model.Relationship = [result stringForColumnIndex:2];
            model.Photo = [result stringForColumnIndex:3];
            model.PhoneNumber = [result stringForColumnIndex:4];
            model.PhoneShort = [result stringForColumnIndex:5];
            model.Type = [result stringForColumnIndex:6];
            model.ObjectId = [result stringForColumnIndex:7];
            model.HeadImg = [result stringForColumnIndex:8];
            [dataArr addObject:model];
            
        }
    }];
    
       return  dataArr;
}

- (NSMutableArray *)isSelectContactTable:(NSString *)BindNumber andObject:(NSString *)object
{
    NSMutableArray *dataArr = [[NSMutableArray alloc] init];
    
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = @"select * from contact_tal where BindNumber=? , ObjectId = ?";
        FMResultSet *result = [db executeQuery:sql,BindNumber,object];
        while ([result next]) {
            ContactModel *model = [[ContactModel alloc] init];
            
            model.BindNumber = [result stringForColumnIndex:0];
            model.DeviceContactId = [result stringForColumnIndex:1];
            model.Relationship = [result stringForColumnIndex:2];
            model.Photo = [result stringForColumnIndex:3];
            model.PhoneNumber = [result stringForColumnIndex:4];
            model.PhoneShort = [result stringForColumnIndex:5];
            model.Type = [result stringForColumnIndex:6];
            model.ObjectId = [result stringForColumnIndex:7];
            model.HeadImg = [result stringForColumnIndex:8];

            [dataArr addObject:model];
            
        }
    }];
    
      return  dataArr;
}

- (NSMutableArray *)isSelectContactTableWithObjectId:(NSString *)ObjectId
{
    NSMutableArray *dataArr = [[NSMutableArray alloc] init];
    
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = @"select * from contact_tal where ObjectId=?";
        FMResultSet *result = [db executeQuery:sql,ObjectId];
        while ([result next]) {
            ContactModel *model = [[ContactModel alloc] init];
            
            model.BindNumber = [result stringForColumnIndex:0];
            model.DeviceContactId = [result stringForColumnIndex:1];
            model.Relationship = [result stringForColumnIndex:2];
            model.Photo = [result stringForColumnIndex:3];
            model.PhoneNumber = [result stringForColumnIndex:4];
            model.PhoneShort = [result stringForColumnIndex:5];
            model.Type = [result stringForColumnIndex:6];
            model.ObjectId = [result stringForColumnIndex:7];
            model.HeadImg = [result stringForColumnIndex:8];

            [dataArr addObject:model];
            
        }

    }];
       return  dataArr;
}


#pragma mark - 删除数据
-(void)removeContactTable:(NSString *)BindNumber
{
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = @"delete from contact_tal where BindNumber=?";
        BOOL b = [db executeUpdate:sql,BindNumber];

    }];
}

#pragma mark - 返回数组到收藏界面
-(NSMutableArray *)getAllContactTable
{
    NSMutableArray *dataArr = [[NSMutableArray alloc] init];
    
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = @"select * from contact_tal";
        FMResultSet *result = [db executeQuery:sql];
        while ([result next]) {
            ContactModel *model = [[ContactModel alloc] init];
            
            model.BindNumber = [result stringForColumnIndex:0];
            model.DeviceContactId = [result stringForColumnIndex:1];
            model.Relationship = [result stringForColumnIndex:2];
            model.Photo = [result stringForColumnIndex:3];
            model.PhoneNumber = [result stringForColumnIndex:4];
            model.PhoneShort = [result stringForColumnIndex:5];
            model.Type = [result stringForColumnIndex:6];
            model.ObjectId = [result stringForColumnIndex:7];
            model.HeadImg = [result stringForColumnIndex:8];

            [dataArr addObject:model];
        }
    }];
    
       return dataArr;
}

- (void)updataSQL:(NSString *)tabl andType:(NSString *)type andValue:(NSString *)value andBindle:(NSString *)bindle
{
    
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"update %@ set %@ = '%@' where BindNumber=?",tabl,type,value];
     [db executeUpdate:sql,bindle];

    
    }];
    
      return ;

}

- (void)updataSQL:(NSString *)tabl andType:(NSString *)type andValue:(NSString *)value andDeviceContanID:(NSString *)DeviceContanID
{
    
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"update %@ set %@ = '%@' where DeviceContactId=?",tabl,type,value];
        [db executeUpdate:sql,DeviceContanID];
        
        
    }];
    
    return ;
    
}


- (void)updataSQL:(NSString *)tabl andType:(NSString *)type andValue:(NSString *)value andDevice:(NSString *)Device
{
    
    [dbBase inDatabase:^(FMDatabase *db) {
        
        NSString *sql = [NSString stringWithFormat:@"update %@ set %@ = '%@' where DeviceID=?",tabl,type,value];
        [db executeUpdate:sql,Device];
        
        
    }];
    
 
    return;
    
}


- (void)updataCONTACTSQL:(NSString *)tabl andType:(NSString *)type andValue:(NSString *)value andDeviceConID:(NSString *)deviceConID
{
    
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"update %@ set %@ = '%@' where DeviceContactId=?",tabl,type,value];
        [db executeUpdate:sql,deviceConID];
    }];
    return;
}

//----------------------------------好友列表--------------------------------------------------------
//----------------------------------好友列表--------------------------------------------------------
#pragma mark - 联系人
- (void)createFriendListTable
{
    [dbBase inDatabase:^(FMDatabase *db) {
        //  [self dropContactTable];
        NSString * sql1 = @"drop table friendlist_tal";
        BOOL b1=[db executeUpdate:sql1];
        if(b1)
        {
            NSLog(@"FriendListTable biao delete  !!");
        }else
        {
            NSLog(@"ERRor      ........");
        }
        
        
        NSString *sql = @"create table if not exists friendlist_tal(BindNumber varchar(500) ,DeviceFriendId varchar(500) ,Relationship varchar(500) ,FriendDevicedId varchar(200) ,Name varchar(200) ,Phone varchar(200));";
        
        BOOL b = [db executeUpdate:sql];
        if(b == NO){
            NSLog(@"好友数据表创建失败");
            return;
        }
        NSLog(@"好友数据表创建成功");
    }];
}

- (void)dropFriendListTable
{
    [dbBase inDatabase:^(FMDatabase *db) {
    }];
    
}

#pragma mark - 删除条目
-(void)deleFriendListItem:(NSString *)DeviceFriendId
{
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = @"delete from friendlist_tal where DeviceFriendId=?";
        BOOL b = [db executeUpdate:sql,DeviceFriendId];
        if(b){
            NSLog(@"删除好友成功");
        }else{
            
            NSLog(@"删除好友失败");
        }
    }];
    
}

#pragma mark - 添加内容到数据库
-(void)addFriendListTable:(NSString *)BindNumber andDeviceFriendId:(NSString *)DeviceFriendId andPhone:(NSString *)Phone andFriendDevicedId:(NSString *)FriendDevicedId andRelationship:(NSString *)Relationship andName:(NSString *)Name
{
    
    [dbBase inDatabase:^(FMDatabase *db) {
        
        NSString *sql = [NSString stringWithFormat:@"insert into friendlist_tal(BindNumber,DeviceFriendId,Phone,FriendDevicedId,Relationship,Name) values(?,?,?,?,?,?)"];
        
        BOOL b = [db executeUpdate:sql,BindNumber,DeviceFriendId,Phone,FriendDevicedId,Relationship,Name];
        if(b)
        {
            NSLog(@"adsdadasd");
        }
        
    }];
    
}

- (NSMutableArray *)isSelectFriendListTable:(NSString *)BindNumber
{
    NSMutableArray *dataArr = [[NSMutableArray alloc] init];
    
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = @"select * from friendlist_tal where BindNumber=?";
        FMResultSet *result = [db executeQuery:sql,BindNumber];
        while ([result next]) {
            Friendlist *model = [[Friendlist alloc] init];
            
            model.BindNumber = [result stringForColumnIndex:0];
            model.DeviceFriendId = [result stringForColumnIndex:1];
            model.Relationship = [result stringForColumnIndex:2];
            model.FriendDevicedId = [result stringForColumnIndex:3];
            model.Name = [result stringForColumnIndex:4];
            model.Phone = [result stringForColumnIndex:5];

            [dataArr addObject:model];
            
        }
    }];
    
    return  dataArr;
}

#pragma mark - 返回数组到收藏界面
-(NSMutableArray *)getAllFriendListTable
{
    NSMutableArray *dataArr = [[NSMutableArray alloc] init];
    
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = @"select * from friendlist_tal";
        FMResultSet *result = [db executeQuery:sql];
        while ([result next]) {
            Friendlist *model = [[Friendlist alloc] init];
            
            model.BindNumber = [result stringForColumnIndex:0];
            model.DeviceFriendId = [result stringForColumnIndex:1];
            model.Relationship = [result stringForColumnIndex:2];
            model.FriendDevicedId = [result stringForColumnIndex:3];
            model.Name = [result stringForColumnIndex:4];
            model.Phone = [result stringForColumnIndex:5];
            
            [dataArr addObject:model];
        }
    }];
    
    return dataArr;
}

#pragma mark - 删除数据
-(void)removeFriendListTable:(NSString *)DeviceFriendId
{
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = @"delete from friendlist_tal where DeviceFriendId=?";
        BOOL b = [db executeUpdate:sql,DeviceFriendId];
        
    }];
}

/*
- (NSMutableArray *)isSelectFriendListTable:(NSString *)BindNumber andObject:(NSString *)object
{
    NSMutableArray *dataArr = [[NSMutableArray alloc] init];
    
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = @"select * from friendlist_tal where BindNumber=? , ObjectId = ?";
        FMResultSet *result = [db executeQuery:sql,BindNumber,object];
        while ([result next]) {
            Friendlist *model = [[Friendlist alloc] init];
            
            model.BindNumber = [result stringForColumnIndex:0];
            model.DeviceFriendId = [result stringForColumnIndex:1];
            model.Relationship = [result stringForColumnIndex:2];
            model.Photo = [result stringForColumnIndex:3];
            model.PhoneNumber = [result stringForColumnIndex:4];
            model.PhoneShort = [result stringForColumnIndex:5];
            
            [dataArr addObject:model];
            
        }
    }];
    
    return  dataArr;
}

- (NSMutableArray *)isSelectFriendListTableWithObjectId:(NSString *)ObjectId
{
    NSMutableArray *dataArr = [[NSMutableArray alloc] init];
    
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = @"select * from friendlist_tal where ObjectId=?";
        FMResultSet *result = [db executeQuery:sql,ObjectId];
        while ([result next]) {
            Friendlist *model = [[Friendlist alloc] init];
            
            model.BindNumber = [result stringForColumnIndex:0];
            model.DeviceFriendId = [result stringForColumnIndex:1];
            model.Relationship = [result stringForColumnIndex:2];
            model.Photo = [result stringForColumnIndex:3];
            model.PhoneNumber = [result stringForColumnIndex:4];
            
            [dataArr addObject:model];
            
        }
        
    }];
    return  dataArr;
}
*/

/*
- (void)updataSQL:(NSString *)tabl andType:(NSString *)type andValue:(NSString *)value andDeviceFriendID:(NSString *)DeviceFriendID
{
    
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"update %@ set %@ = '%@' where DeviceFriendID=?",tabl,type,value];
        [db executeUpdate:sql,DeviceFriendID];
        
        
    }];
    
    return ;
    
}


- (void)updataSQL:(NSString *)tabl andType:(NSString *)type andValue:(NSString *)value andFriend:(NSString *)Device
{
    
    [dbBase inDatabase:^(FMDatabase *db) {
        
        NSString *sql = [NSString stringWithFormat:@"update %@ set %@ = '%@' where DeviceID=?",tabl,type,value];
        [db executeUpdate:sql,Device];
        
        
    }];
    
    
    return;
    
}


- (void)updataFRIENDSQL:(NSString *)tabl andType:(NSString *)type andValue:(NSString *)value andDeviceFriID:(NSString *)deviceFriID
{
    
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"update %@ set %@ = '%@' where DeviceFriendId=?",tabl,type,value];
        [db executeUpdate:sql,deviceFriID];
    }];
    return;
}
*/


//----------------------------------语音--------------------------------------------------------
//----------------------------------语音--------------------------------------------------------
#pragma mark - 语音
- (void)createAudioTable
{
    //[self dropAudioTable];
    
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = @"create table if not exists audio_table(DeviceVoiceId varchar(500) ,DeviceID varchar(500) ,State varchar(200) , Type varchar(200) ,ObjectId varchar(200) , Mark varchar(200),Path varchar(1000) ,Length varchar(500) , MsgType varchar(200) ,CreateTime varchar(1000) ,UpdateTime varchar(1000));";
        
        BOOL b = [db executeUpdate:sql];
        if(b == NO){
            NSLog(@"语音数据表创建失败");
            return;
        }
        NSLog(@"语音数据表创建成功");

    }];
    
    
}
- (void)dropAudioTable
{
    
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString * sql = @"drop table audio_table";
        BOOL b=[db executeUpdate:sql];
        if(b)
        {
            NSLog(@"audio_table biao delete  !!");
        }else
        {
            NSLog(@"ERRor      ........");
        }

    }];
    
  }
#pragma mark - 删除条目
-(void)deleAudioItem:(NSString *)DeviceVoiceId
{
    
    [dbBase inDatabase:^(FMDatabase *db) {
        
        NSString *sql = @"delete from audio_table where DeviceVoiceId=?";
        BOOL b = [db executeUpdate:sql,DeviceVoiceId];
        if(b){
            NSLog(@"删除语音成功");
        }else{
            
            NSLog(@"删除语音失败");
        }
    }];
}

#pragma mark - 添加条目
- (void)addAudioWithDeviceVoiceId:(NSString *)DeviceVoiceId andDeviceID:(NSString *)DeviceID andState:(NSString *)State andType:(NSString *)Type andObjectId:(NSString *)ObjectId andMark:(NSString *)Mark andPath:(NSString *)Path andLength:(NSString *)Length andMsgType:(NSString *)MsgType andCreateTime:(NSString *)CreateTime andUpdateTime:(NSString *)UpdateTime
{
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"insert into audio_table(DeviceVoiceId,DeviceID,State,Type,ObjectId,Mark,Path,Length,MsgType,CreateTime,UpdateTime) values(?,?,?,?,?,?,?,?,?,?,?)"];
        
        BOOL b = [db executeUpdate:sql,DeviceVoiceId,DeviceID,State,Type,ObjectId,Mark,Path,Length,MsgType,CreateTime,UpdateTime];
        if(b)
        {
            NSLog(@"adsdadasd");
        }
        
    }];
    

}

#pragma mark - 返回数组到收藏界面
-(NSMutableArray *)getAllAudioTable
{
    NSMutableArray *dataArr = [[NSMutableArray alloc] init];
    
    
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = @"select * from audio_table";
        FMResultSet *result = [db executeQuery:sql];
        while ([result next]) {
            AudioModel *model = [[AudioModel alloc] init];
            
            model.DeviceVoiceId = [result stringForColumnIndex:0];
            model.DeviceID = [result stringForColumnIndex:1];
            model.State = [result stringForColumnIndex:2];
            
            model.Type = [result stringForColumnIndex:3];
            model.ObjectId = [result stringForColumnIndex:4];
            model.Mark = [result stringForColumnIndex:5];
            model.Path = [result stringForColumnIndex:6];
            model.Length = [result stringForColumnIndex:7];
            model.MsgType = [result stringForColumnIndex:8];
            model.CreateTime = [result stringForColumnIndex:9];
            model.UpdateTime = [result stringForColumnIndex:10];
            
            [dataArr addObject:model];
        }

    }];
    
       return dataArr;
}


- (NSMutableArray *)isSelectAudioTable:(NSString *)DeviceId
{
    NSMutableArray *dataArr = [[NSMutableArray alloc] init];
    
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = @"select * from audio_table where DeviceID=?";
        FMResultSet *result = [db executeQuery:sql,DeviceId];
        while ([result next]) {
            AudioModel *model = [[AudioModel alloc] init];
            
            model.DeviceVoiceId = [result stringForColumnIndex:0];
            model.DeviceID = [result stringForColumnIndex:1];
            model.State = [result stringForColumnIndex:2];
            
            model.Type = [result stringForColumnIndex:3];
            model.ObjectId = [result stringForColumnIndex:4];
            model.Mark = [result stringForColumnIndex:5];
            model.Path = [result stringForColumnIndex:6];
            model.Length = [result stringForColumnIndex:7];
            model.MsgType = [result stringForColumnIndex:8];
            model.CreateTime = [result stringForColumnIndex:9];
            model.UpdateTime = [result stringForColumnIndex:10];
            [dataArr addObject:model];
        }
    }];
    
    
      return  dataArr;
}
//----------------------------------消息记录--------------------------------------------------------
//----------------------------------消息记录--------------------------------------------------------
#pragma mark - 消息记录
- (void)createMessageRecord
{
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = @"create table if not exists message_tab(DeviceID varchar(500) ,Type varchar(200) ,AddDevice varchar(300) ,Content varchar(500) ,Message varchar(200) , CreateTime varchar(200),id varchar(200));";
        
        BOOL b = [db executeUpdate:sql];
        if(b == NO){
            NSLog(@"消息记录数据表创建失败");
            return;
        }
        NSLog(@"消息记录创建成功");

    }];
    
    
    
}
- (void)dropMessage
{
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString * sql = @"drop table message_tab";
        BOOL b=[db executeUpdate:sql];
        if(b)
        {
            NSLog(@"message_tab biao delete  !!");
        }else
        {
            NSLog(@"ERRor      ........");
        }
    }];
    
    
  }
#pragma mark - 添加条目
- (void)addMessageDeviceID:(NSString *)DeviceID andType:(NSString *)Type andAddDevice:(NSString *)AddDevice andContent:(NSString *)Content andMessage:(NSString *)Message andCreateTime:(NSString *)CreateTime andId:(NSString *)mId
{
    [self deleteMessageWithId:mId];
    [dbBase inDatabase:^(FMDatabase *db) {
        
        NSString *sql = [NSString stringWithFormat:@"insert into message_tab(DeviceID,Type,AddDevice,Content,Message,CreateTime,id) values(?,?,?,?,?,?,?)"];
        BOOL b = [db executeUpdate:sql,DeviceID,Type,AddDevice,Content,Message,CreateTime,mId];
        
    }];
    
   
    
}

#pragma mark - 返回数组到收藏界面
-(NSMutableArray *)getAllMessageTable
{
    NSMutableArray *dataArr = [[NSMutableArray alloc] init];
    
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = @"select * from message_tab";
        FMResultSet *result = [db executeQuery:sql];
        while ([result next]) {
            MessageModel *model = [[MessageModel alloc] init];
            
            model.DeviceID = [result stringForColumnIndex:0];
            model.Type = [result stringForColumnIndex:1];
            model.AddDevice = [result stringForColumnIndex:2];
            model.Content = [result stringForColumnIndex:3];
            model.Message = [result stringForColumnIndex:4];
            model.CreateTime = [result stringForColumnIndex:5];
            model.mId = [result stringForColumnIndex:6];
            [dataArr addObject:model];
        }
    }];
    
       return dataArr;
}

- (NSMutableArray *)isSelectWithDeviceID:(NSString *)DeviceID
{
    NSMutableArray *dataArr = [[NSMutableArray alloc] init];
    
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = @"select * from message_tab where AddDevice=?";
        FMResultSet *result = [db executeQuery:sql,DeviceID];
        while ([result next]) {
            MessageModel *model = [[MessageModel alloc] init];
            
            model.DeviceID = [result stringForColumnIndex:0];
            model.Type = [result stringForColumnIndex:1];
            model.AddDevice = [result stringForColumnIndex:2];
            model.Content = [result stringForColumnIndex:3];
            model.Message = [result stringForColumnIndex:4];
            model.CreateTime = [result stringForColumnIndex:5];
            model.mId = [result stringForColumnIndex:6];
            [dataArr addObject:model];
            
        }

    }];
        return  dataArr;
}

#pragma mark - 删除条目
-(void)deleteMessageWithCreatTime:(NSString *)CreatTime
{
    
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = @"delete from message_tab where CreateTime=?";
        BOOL b = [db executeUpdate:sql,CreatTime];
        if(b){
            NSLog(@"删除条目成功");
        }else{
            
            NSLog(@"删除条目失败");
        }

    }];
    
   }

#pragma mark - 删除条目
-(void)deleteMessageWithId:(NSString *)mId{
    
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = @"delete from message_tab where id=?";
        BOOL b = [db executeUpdate:sql,mId];
        if(b){
            NSLog(@"删除条目成功");
        }else{
            
            NSLog(@"删除条目失败");
        }
        
    }];
    
}

//----------------------------------短信--------------------------------------------------------
//----------------------------------短信-------------------------------------------------------
#pragma mark - 短信
- (void)createShortMessage
{
    //  [self dropMessage];
    
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = @"create table if not exists short_message(Device varchar(500) ,DeviceSMSID varchar(200) ,deviceID varchar(300) ,Type varchar(500) ,Phone  varchar(200) , SMS varchar(200), CreateTime  varchar(200));";
        
        BOOL b = [db executeUpdate:sql];
        if(b == NO){
            NSLog(@"短信数据表创建失败");
            return;
        }
        NSLog(@"短信创建成功");
    }];
    
   
    
}
- (void)dropShortMessage
{
    
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString * sql = @"drop table short_message";
        BOOL b=[db executeUpdate:sql];
        if(b)
        {
            NSLog(@"short_message biao delete  !!");
        }else
        {
            NSLog(@"ERRor      ........");
        }

    }];
    
}
#pragma mark - 删除条目
-(void)deleteShortMessageWithDeviceSMSID:(NSString *)DeviceSMSID
{
    
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = @"delete from short_message where DeviceSMSID=?";
        BOOL b = [db executeUpdate:sql,DeviceSMSID];
        if(b){
            NSLog(@"删除条目成功");
        }else{
            
            NSLog(@"删除条目失败");
        }
        
    }];
    
}

#pragma mark - 删除条目
-(void)deleteShortMessageWithCreateTime:(NSString *)CreateTime
{
    
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = @"delete from short_message where CreateTime=?";
        BOOL b = [db executeUpdate:sql,CreateTime];
        if(b){
            NSLog(@"删除条目成功");
        }else{
            
            NSLog(@"删除条目失败");
        }
        
    }];
    
}

#pragma mark - 添加条目
- (void)addShortMessageDeviceID:(NSString *)DeviceID andDeviceSMSID:(NSString *)DeviceSMSID anddeviceID:(NSString *)deviceID andType:(NSString *)Type andPhone:(NSString *)Phone andSMS:(NSString *)SMS andCreateTime:(NSString *)CreateTime
{
    
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"insert into short_message(Device,DeviceSMSID,deviceID,Type,Phone,SMS,CreateTime) values(?,?,?,?,?,?,?)"];
        
        BOOL b = [db executeUpdate:sql,DeviceID,DeviceSMSID,deviceID,Type,Phone, SMS,CreateTime];
        
    }];
}



#pragma mark - 返回数组到收藏界面
-(NSMutableArray *)getAllShortMessage
{
    NSMutableArray *dataArr = [[NSMutableArray alloc] init];
    
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = @"select * from short_message";
        FMResultSet *result = [db executeQuery:sql];
        while ([result next]) {
            ShortMessageModel *model = [[ShortMessageModel alloc] init];
            
            model.Device = [result stringForColumnIndex:0];
            model.DeviceSMSID = [result stringForColumnIndex:1];
            model.deviceID = [result stringForColumnIndex:2];
            model.Type = [result stringForColumnIndex:3];
            model.Phone = [result stringForColumnIndex:4];
            model.SMS = [result stringForColumnIndex:5];
            model.CreateTime = [result stringForColumnIndex:6];
            
            [dataArr addObject:model];
        }
    }];
    
       return dataArr;
}

- (NSMutableArray *)isSelectShortMessageWithDeviceID:(NSString *)DeviceID
{
    NSMutableArray *dataArr = [[NSMutableArray alloc] init];
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = @"select * from short_message where Device=?";
        FMResultSet *result = [db executeQuery:sql,DeviceID];
        while ([result next]) {
            ShortMessageModel *model = [[ShortMessageModel alloc] init];
            
            model.Device = [result stringForColumnIndex:0];
            model.DeviceSMSID = [result stringForColumnIndex:1];
            model.deviceID = [result stringForColumnIndex:2];
            model.Type = [result stringForColumnIndex:3];
            model.Phone = [result stringForColumnIndex:4];
            model.SMS = [result stringForColumnIndex:5];
            model.CreateTime = [result stringForColumnIndex:6];
            
            [dataArr addObject:model];
        }
    }];
    
        return  dataArr;
}

//----------------------------------本地位置缓存------------------------------------------------------
//----------------------------------本地位置缓存-------------------------------------------------------
#pragma mark - 本地位置缓存
- (void)createLocationCache
{
    //  [self dropLocationCache];
    
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = @"create table if not exists location_cache(LatitudeCache varchar(300) ,LongitudeCache varchar(300) ,LocationAddress varchar(500),LocationCacheType varchar(200),ServerTimeCache varchar(200));";
        
        BOOL b = [db executeUpdate:sql];
        if(b == NO){
            NSLog(@"本地位置缓存数据表创建失败");
            return;
        }
        NSLog(@"本地位置缓存创建成功");
    }];
    
}

- (void)dropLocationCache
{
    
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString * sql = @"drop table location_cache";
        BOOL b=[db executeUpdate:sql];
        if(b)
        {
            NSLog(@"location_cache biao delete  !!");
        }else
        {
            NSLog(@"ERRor      ........");
        }
        
    }];
    
}

#pragma mark - 删除条目
-(void)deleteLocationCacheWithDeviceCacheID:(NSString *)ServerTimeCache
{
    
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = @"delete from location_cache where ServerTimeCache=?";
        BOOL b = [db executeUpdate:sql,ServerTimeCache];
        if(b){
            NSLog(@"删除条目成功");
        }else{
            
            NSLog(@"删除条目失败");
        }
        
    }];
}

#pragma mark - 删除条目
-(void)deleteLocationCacheWithCreateTime:(NSString *)CreateTime
{
    
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = @"delete from location_cache where CreateTime=?";
        BOOL b = [db executeUpdate:sql,CreateTime];
        if(b){
            NSLog(@"删除条目成功");
        }else{
            
            NSLog(@"删除条目失败");
        }
        
    }];
}

#pragma mark - 添加条目
- (void)addLocationCacheID:(NSString *)DeviceID andLatitudeCache:(NSString *)LatitudeCache andLongitudeCache:(NSString *)LongitudeCache andLocationAddress:(NSString *)LocationAddress andLocationCacheType:(NSString *)LocationCacheType andServerTimeCache:(NSString *)ServerTimeCache
{
    
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"insert into location_cache(LatitudeCache,LongitudeCache,LocationAddress,LocationCacheType,ServerTimeCache) values(?,?,?,?,?)"];
        
        BOOL b = [db executeUpdate:sql,LatitudeCache,LongitudeCache,LocationAddress,LocationCacheType,ServerTimeCache];
        
    }];
}

#pragma mark - 返回数组到收藏界面
-(NSMutableArray *)getAllLocationCache
{
    NSMutableArray *dataArr = [[NSMutableArray alloc] init];
    
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = @"select * from location_cache";
        FMResultSet *result = [db executeQuery:sql];
        while ([result next]) {
            LocationCache *model = [[LocationCache alloc] init];
            
            model.LatitudeCache = [result stringForColumnIndex:0];
            model.LongitudeCache = [result stringForColumnIndex:1];
            model.LocationAddress = [result stringForColumnIndex:2];
            model.LocationCacheType = [result stringForColumnIndex:3];
            model.ServerTimeCache = [result stringForColumnIndex:4];
            
            [dataArr addObject:model];
        }
    }];
    
    return dataArr;
}

- (NSMutableArray *)isSelectLocationCacheWithDeviceID:(NSString *)DeviceID
{
    NSMutableArray *dataArr = [[NSMutableArray alloc] init];
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = @"select * from location_cache";
        FMResultSet *result = [db executeQuery:sql,DeviceID];
        while ([result next]) {
            LocationCache *model = [[LocationCache alloc] init];
            
            model.LatitudeCache = [result stringForColumnIndex:0];
            model.LongitudeCache = [result stringForColumnIndex:1];
            model.LocationAddress = [result stringForColumnIndex:2];
            model.LocationCacheType = [result stringForColumnIndex:3];
            model.ServerTimeCache = [result stringForColumnIndex:4];
            
            [dataArr addObject:model];
        }
    }];
    
    return  dataArr;
}


//----------------------------------位置--------------------------------------------------------
//----------------------------------位置-------------------------------------------------------
#pragma mark - 位置
- (void)createLocation
{
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = @"create table if not exists locaion_table(Device varchar(500) ,Altitude varchar(200) ,Course varchar(300) ,LocationType varchar(500) ,CreateTime  varchar(200) , Electricity varchar(200), GSM  varchar(200),Step varchar(200),Health varchar(200), Latitude varchar(300) ,Longitude varchar(500) ,Online  varchar(200) , SatelliteNumber varchar(200), ServerTime varchar(200),Speed  varchar(200) , UpdateTime varchar(200), DeviceTime  varchar(200));";
        
        BOOL b = [db executeUpdate:sql];
        if(b == NO){
            NSLog(@"位置数据表创建失败");
            return;
        }
        NSLog(@"位置创建成功");
    }];
}

- (void)dropLocation
{
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString * sql = @"drop table locaion_table";
        BOOL b=[db executeUpdate:sql];
        if(b)
        {
            NSLog(@"locaion_table biao delete  !!");
        }else
        {
            NSLog(@"ERRor      ........");
        }
    }];
    
 }
#pragma mark - 添加条目
- (void)addLocationDeviceID:(NSString *)DeviceID andAltitude:(NSString *)Altitude andCourse:(NSString *)Course andLocationType:(NSString *)LocationType andCreateTime:(NSString *)CreateTime andElectricity:(NSString *)Electricity andGSM:(NSString *)GSM andStep:(NSString *)Step andHealth:(NSString *)Health andLatitude:(NSString *)Latitude andLongitude:(NSString *)Longitude andOnline:(NSString *)Online andSatelliteNumber:(NSString *)SatelliteNumber andServerTime:(NSString *)ServerTime andSpeed:(NSString *)Speed andUpdateTime:(NSString *)UpdateTime andDeviceTime:(NSString *)DeviceTime
{
    
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"insert into locaion_table(Device,Altitude,Course,LocationType,CreateTime,Electricity,GSM,Step,Health,Latitude,Longitude,Online,SatelliteNumber,ServerTime,Speed,UpdateTime,DeviceTime) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"];
        
        BOOL b = [db executeUpdate:sql,DeviceID,Altitude,Course,LocationType,CreateTime,Electricity,GSM,Step,Health,Latitude,Longitude,Online,SatelliteNumber,ServerTime,Speed,UpdateTime,DeviceTime];
        
    }];

}

- (NSMutableArray *)isSelectLocationTable:(NSString *)DeviceID
{
    NSMutableArray *dataArr = [[NSMutableArray alloc] init];
    
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = @"select * from locaion_table where Device=?";
        FMResultSet *result = [db executeQuery:sql,DeviceID];
        while ([result next]) {
            LocationModel *model = [[LocationModel alloc] init];
            
            model.Device = [result stringForColumnIndex:0];
            model.Altitude = [result stringForColumnIndex:1];
            model.Course = [result stringForColumnIndex:2];
            model.LocationType = [result stringForColumnIndex:3];
            model.CreateTime = [result stringForColumnIndex:4];
            model.Electricity = [result stringForColumnIndex:5];
            model.GSM = [result stringForColumnIndex:6];
            model.Step = [result stringForColumnIndex:7];
            model.Health = [result stringForColumnIndex:8];
            model.Latitude = [result stringForColumnIndex:9];
            model.Longitude = [result stringForColumnIndex:10];
            model.Online = [result stringForColumnIndex:11];
            model.SatelliteNumber = [result stringForColumnIndex:12];
            model.ServerTime = [result stringForColumnIndex:13];
            model.Speed = [result stringForColumnIndex:14];
            model.UpdateTime = [result stringForColumnIndex:15];
            model.DeviceTime = [result stringForColumnIndex:16];
            [dataArr addObject:model];
            
        }

    }];
    
       return  dataArr;
}

#pragma mark - 删除条目
-(void)deleteLocationWithDeviceID:(NSString *)DeviceID
{
    [dbBase inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql = @"delete from locaion_table where Device=?";
        BOOL b = [db executeUpdate:sql,DeviceID];
        if(b){
            NSLog(@"删除条目成功");
        }else{
            
            NSLog(@"删除条目失败");
        }
    }];
    
    
}


//----------------------------------位置--------------------------------------------------------
//----------------------------------位置-------------------------------------------------------
#pragma mark - 位置
- (void)createPhoto
{
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = @"create table if not exists photo_table(DevicePhotoId varchar(500) ,DeviceID varchar(200) ,Source varchar(300) ,DeviceTime varchar(500) ,Latitude  varchar(200) , Longitude varchar(200), Mark  varchar(200), Path varchar(300) ,Length varchar(500) ,CreateTime  varchar(200) , UpdateTime varchar(200) , Address varchar(1000));";
        
        BOOL b = [db executeUpdate:sql];
        if(b == NO){
            NSLog(@"相册数据表创建失败");
            return;
        }
        NSLog(@"相册创建成功");
    }];
}

#pragma mark - 添加条目
- (void)addPhotoPhotoId:(NSString *)DevicePhotoId andDeviceID:(NSString *)DeviceID andSource:(NSString *)Source andDeviceTime:(NSString *)DeviceTime andLatitude:(NSString *)Latitude andLongitude:(NSString *)Longitude andMark:(NSString *)Mark  andPath:(NSString *)Path andLength:(NSString *)Length andCreateTime:(NSString *)CreateTime andUpdateTime:(NSString *)UpdateTime andAddress:(NSString *)Address
{
    
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"insert into photo_table(DevicePhotoId,DeviceID,Source,DeviceTime,Latitude,Longitude,Mark,Path,Length,CreateTime,UpdateTime,Address) values(?,?,?,?,?,?,?,?,?,?,?,?)"];
        
        BOOL b = [db executeUpdate:sql,DevicePhotoId,DeviceID,Source,DeviceTime,Latitude,Longitude,Mark,Path,Length,CreateTime,UpdateTime,Address];
        if(b)
        {
            
        }
        else
        {
            
        }
        
    }];
    
}

- (NSMutableArray *)isSelectPhotoTable:(NSString *)DeviceID
{
    NSMutableArray *dataArr = [[NSMutableArray alloc] init];
    
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = @"select * from photo_table where DeviceID=?";
        FMResultSet *result = [db executeQuery:sql,DeviceID];
        while ([result next]) {
            PhotoModel *model = [[PhotoModel alloc] init];
            
            model.DevicePhotoId = [result stringForColumnIndex:0];
            model.DeviceID = [result stringForColumnIndex:1];
            model.Source = [result stringForColumnIndex:2];
            model.DeviceTime = [result stringForColumnIndex:3];
            model.Latitude = [result stringForColumnIndex:4];
            model.Longitude = [result stringForColumnIndex:5];
            model.Mark = [result stringForColumnIndex:6];
            model.Path = [result stringForColumnIndex:7];
            model.Length = [result stringForColumnIndex:8];
            model.CreateTime = [result stringForColumnIndex:9];
            model.UpdateTime = [result stringForColumnIndex:10];
            model.Address = [result stringForColumnIndex:11];

            [dataArr addObject:model];
        }
    }];
    
    return  dataArr;
}

-(void)deletePhotoWithPhotoID:(NSString *)DevicePhotoId
{
    [dbBase inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql = @"delete from photo_table where DevicePhotoId=?";
        BOOL b = [db executeUpdate:sql,DevicePhotoId];
        if(b){
            NSLog(@"删除条目成功");
        }else{
            
            NSLog(@"删除条目失败");
        }
    }];
}

- (void)updataSQL:(NSString *)tabl andType:(NSString *)type andValue:(NSString *)value andDevicePhotoId:(NSString *)DevicePhotoId
{
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"update %@ set %@ = '%@' where DevicePhotoId=?",tabl,type,value];
        [db executeUpdate:sql,DevicePhotoId];
        
    }];
    
    return ;
    

}

- (void)dropPhotoTable
{
    
    [dbBase inDatabase:^(FMDatabase *db) {
        NSString * sql = @"drop table photo_table";
        BOOL b=[db executeUpdate:sql];
        if(b)
        {
            NSLog(@"audio_table biao delete  !!");
        }else
        {
            NSLog(@"ERRor      ........");
        }
        
    }];
    
}

@end
