//
//  DeviceSetModel.h
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceSetModel : NSObject
@property (nonatomic,strong)NSString *BindNumber;
@property (nonatomic,strong)NSString *VersionNumber;
@property (nonatomic,strong)NSString *AutoAnswer;
@property (nonatomic,strong)NSString *ReportCallsPosition;
@property (nonatomic,strong)NSString *BodyFeelingAnswer;
@property (nonatomic,strong)NSString *ExtendEmergencyPower;
@property (nonatomic,strong)NSString *ClassDisable;
@property (nonatomic,strong)NSString *TimeSwitchMachine;
@property (nonatomic,strong)NSString *RefusedStrangerCalls;
@property (nonatomic,strong)NSString *WatchOffAlarm;
@property (nonatomic,strong)NSString *WatchCallVoice;
@property (nonatomic,strong)NSString *WatchCallVibrate;
@property (nonatomic,strong)NSString *WatchInformationSound;
@property (nonatomic,strong)NSString *WatchInformationShock;
@property (nonatomic,strong)NSString *ClassDisabled1;
@property (nonatomic,strong)NSString *ClassDisabled2;
@property (nonatomic,strong)NSString *ClassDisabled3;
@property (nonatomic,strong)NSString *ClassDisabled4;
@property (nonatomic,strong)NSString *WeekDisabled;
@property (nonatomic,strong)NSString *TimerOpen;
@property (nonatomic,strong)NSString *TimerClose;
@property (nonatomic,strong)NSString *BrightScreen;
@property (nonatomic,strong)NSString *weekAlarm1;
@property (nonatomic,strong)NSString *weekAlarm2;
@property (nonatomic,strong)NSString *weekAlarm3;
@property (nonatomic,strong)NSString *alarm1;
@property (nonatomic,strong)NSString *alarm2;
@property (nonatomic,strong)NSString *alarm3;
@property (nonatomic,strong)NSString *locationMode;
@property (nonatomic,strong)NSString *locationTime;
@property (nonatomic,strong)NSString *flowerNumber;
@property (nonatomic,strong)NSString *StepCalculate;
@property (nonatomic,strong)NSString *SleepCalculate;
@property (nonatomic,strong)NSString *HrCalculate;
@property (nonatomic,strong)NSString *SosMsgswitch;
@property (nonatomic,strong)NSString *TimeZone;
@property (nonatomic,strong)NSString *Language;
@property (nonatomic,strong)NSString *dialPad;
@property (nonatomic,assign)BOOL isOneShow;
@end
