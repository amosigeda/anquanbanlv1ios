//
//  DataManager.h
//  CommonageNet
//
//  Created by qianfeng on 15-1-8.
//  Copyright (c) 2015年 qianfeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
@interface DataManager : NSObject
@property(nonatomic,copy)NSString* homeText;
@property (assign,nonatomic) BOOL isLogin;
+(id)shareInstance;
-(void)createDataBaseAndTable;
-(void)createDeviceSetTable;
-(void)createContactTable;
-(id)init;
#pragma mark - 设备列表信息
-(BOOL)isFavourite:(NSString *)bindNumber;
-(void)addFavourite:(NSString *)ActiveDate andBabyName:(NSString *)BabyName andBindNumber:(NSString *)BindNumber andDeviceType:(NSString *)DeviceType andBirthday:(NSString *)Birthday andCreateTime:(NSString *)CreateTime andCurrentFirmware:(NSString *)CurrentFirmware andDeviceID:(NSString *)DeviceID andDeviceModelID:(NSString *)DeviceModelID andFirmware:(NSString *)Firmware andGender:(NSString *)Gender andGrade:(NSString *)Grade andHireExpireDate:(NSString *)HireExpireDate andDate:(NSString *)Date andHomeAddress:(NSString *)HomeAddress andHomeLat:(NSString *)HomeLat andHomeLng:(NSString *)HomeLng andIsGuard:(NSString *)IsGuard andPassword:(NSString *)Password andPhoneCornet:(NSString *)PhoneCornet andPhoneNumber:(NSString *)PhoneNumber andPhoto:(NSString *)Photo andSchoolAddress:(NSString *)SchoolAddress andSchoolLat:(NSString *)SchoolLat andSchoolLng:(NSString *)SchoolLng andSerialNumber:(NSString *)SerialNumber andUpdateTime:(NSString *)UpdateTime andUserId:(NSString *)UserId andSetVersionNO:(NSString *)SetVersionNO andContactVersionNO:(NSString *)ContactVersionNO andOperatorType:(NSString *)OperatorType andSmsNumber:(NSString *)SmsNumber andSmsBalanceKey:(NSString *)SmsBalanceKey andSmsFlowKey:(NSString *)SmsFlowKey andLatestTime:(NSString *)LatestTime;
- (void)addFAvourite:(NSString *)activedate;
-(void)removeFavourite:(NSString *)bindNumber;
-(NSMutableArray *)getAllFavourie;
-(void)deleTable;
- (void)createDeviceTable;
-(void)deleteItemById:(NSString *)bindNumber;
- (NSMutableArray *)isSelect:(NSString *)bindNumber;
- (NSMutableArray *)isSelectWithDeviceID:(NSString *)DeviceID;//搜索短信表

- (NSMutableArray *)isSelectFaWithDevice:(NSString *)Device;//搜索设备表

//-------------------------------------------设置表----------------------------------------------
//-------------------------------------------设置表----------------------------------------------
#pragma mark - 设置表

- (void)createDeviceSetTable;
-(void)deleDeviceSetItem:(NSString *)BindNumber;
-(void)addDeviceSetTable:(NSString *)BindNumber andVersionNumber:(NSString *)VersionNumber andAutoAnswer:(NSString *)AutoAnswer andReportCallsPosition:(NSString *)ReportCallsPosition andBodyFeelingAnswer:(NSString *)BodyFeelingAnswer andExtendEmergencyPower:(NSString *)ExtendEmergencyPower andClassDisable:(NSString *)ClassDisable andTimeSwitchMachine:(NSString *)TimeSwitchMachine andRefusedStrangerCalls:(NSString *)RefusedStrangerCalls andWatchOffAlarm:(NSString *)WatchOffAlarm  andWatchCallVoice:(NSString *)WatchCallVoice andWatchCallVibrate:(NSString *)WatchCallVibrate andWatchInformationSound:(NSString *)WatchInformationSound andWatchInformationShock:(NSString *)WatchInformationShock andClassDisabled1:(NSString *)ClassDisabled1 andClassDisabled2:(NSString *)ClassDisabled2 andClassDisabled3:(NSString *)ClassDisabled3 andClassDisabled4:(NSString *)ClassDisabled4 andWeekDisabled:(NSString *)WeekDisabled andTimerOpen:(NSString *)TimerOpen andTimerClose:(NSString *)TimerClose andBrightScreen:(NSString *)BrightScreen andweekAlarm1:(NSString *)weekAlarm1 andweekAlarm2:(NSString *)weekAlarm2 andweekAlarm3:(NSString *)weekAlarm3 andalarm1:(NSString *)alarm1 andalarm2:(NSString *)alarm2 andalarm3:(NSString *)alarm3 andlocationMode:(NSString *)locationMode andlocationTime:(NSString *)locationTime andflowerNumber:(NSString *)flowerNumber andStepCalculate:(NSString *)StepCalculate andSleepCalculate:(NSString *)SleepCalculate andHrCalculate:(NSString *)HrCalculate andSosMsgswitch:(NSString *)SosMsgswitch andTimeZone:(NSString *)TimeZone andLanguage:(NSString *)Language andDialPad:(NSString *)dialPad;
-(void)DeviceSetTable:(NSString *)BindNumber;
- (NSMutableArray *)isSelectDeviceSetTable:(NSString *)BindNumber;
-(void)removeDeviceSetTable:(NSString *)BindNumber;
-(NSMutableArray *)getAllDeviceSetTable;
- (NSMutableArray *)isSelectContactTable:(NSString *)BindNumber andObject:(NSString *)object;
//----------------------------------联系人--------------------------------------------------------
//----------------------------------联系人--------------------------------------------------------
#pragma mark - 联系人
-(void)addContactTable:(NSString *)BindNumber andDeviceContactId:(NSString *)DeviceContactId andRelationship:(NSString *)Relationship andPhoto:(NSString *)Photo andPhoneNumber:(NSString *)PhoneNumber andPhoneShort:(NSString *)PhoneShort andType:(NSString *)Type andObjectId:(NSString *)ObjectId andHeadImg:(NSString *)HeadImg;
-(void)ContactTable:(NSString *)BindNumber;
- (NSMutableArray *)isSelectContactTable:(NSString *)BindNumber;
-(NSMutableArray *)getAllContactTable;
-(void)removeContactTable:(NSString *)BindNumber;

- (void)updataSQL:(NSString *)tabl andType:(NSString *)type andValue:(NSString *)value andBindle:(NSString *)bindle;
-(void)deleContactItem:(NSString *)DeviceContactId;
- (void)updataCONTACTSQL:(NSString *)tabl andType:(NSString *)type andValue:(NSString *)value andDeviceConID:(NSString *)deviceConID;
- (NSMutableArray *)isSelectContactTableWithObjectId:(NSString *)ObjectId;
- (void)updataSQL:(NSString *)tabl andType:(NSString *)type andValue:(NSString *)value andDevice:(NSString *)Device;
//----------------------------------好友列表--------------------------------------------------------
//----------------------------------好友列表--------------------------------------------------------
#pragma mark - 好友列表
- (void)createFriendListTable;
-(void)addFriendListTable:(NSString *)BindNumber andDeviceFriendId:(NSString *)DeviceFriendId andPhone:(NSString *)Phone andFriendDevicedId:(NSString *)FriendDevicedId andRelationship:(NSString *)Relationship andName:(NSString *)Name;
-(void)FriendListTable:(NSString *)DeviceFriendId;
- (NSMutableArray *)isSelectFriendListTable:(NSString *)DeviceFriendId;
-(NSMutableArray *)getAllFriendListTable;
-(void)removeFriendListTable:(NSString *)DeviceFriendId;

-(void)deleFriendListItem:(NSString *)DeviceFriendId;
- (void)updataFRIENDSQL:(NSString *)tabl andType:(NSString *)type andValue:(NSString *)value andDeviceFriID:(NSString *)deviceFriID;
- (NSMutableArray *)isSelectFriendListTableWithObjectId:(NSString *)ObjectId;
- (void)updataSQL:(NSString *)tabl andType:(NSString *)type andValue:(NSString *)value andDeviceFriendID:(NSString *)DeviceFriendID;
//----------------------------------语音--------------------------------------------------------
//----------------------------------语音--------------------------------------------------------
- (void)createAudioTable;
-(void)deleAudioItem:(NSString *)DeviceVoiceId;
- (void)addAudioWithDeviceVoiceId:(NSString *)DeviceVoiceId andDeviceID:(NSString *)DeviceID andState:(NSString *)State andType:(NSString *)Type andObjectId:(NSString *)ObjectId andMark:(NSString *)Mark andPath:(NSString *)Path andLength:(NSString *)Length andMsgType:(NSString *)MsgType andCreateTime:(NSString *)CreateTime andUpdateTime:(NSString *)UpdateTime;
-(NSMutableArray *)getAllAudioTable;
- (NSMutableArray *)isSelectAudioTable:(NSString *)DeviceId;
- (void)dropAudioTable;
//----------------------------------消息记录--------------------------------------------------------
//----------------------------------消息记录--------------------------------------------------------
#pragma mark - 消息记录
- (void)createMessageRecord;
- (void)dropMessage;
- (void)addMessageDeviceID:(NSString *)DeviceID andType:(NSString *)Type andAddDevice:(NSString *)AddDevice andContent:(NSString *)Content andMessage:(NSString *)Message andCreateTime:(NSString *)CreateTime andId:(NSString *)mId;
-(NSMutableArray *)getAllMessageTable;
-(void)deleteMessageWithCreatTime:(NSString *)CreatTime;
-(void)deleteMessageWithId:(NSString *)mId;
//----------------------------------短信--------------------------------------------------------
//----------------------------------短信--------------------------------------------------------
- (void)createShortMessage;
- (void)dropShortMessage;
- (void)addShortMessageDeviceID:(NSString *)DeviceID andDeviceSMSID:(NSString *)DeviceSMSID anddeviceID:(NSString *)deviceID andType:(NSString *)Type andPhone:(NSString *)Phone andSMS:(NSString *)SMS andCreateTime:(NSString *)CreateTime;
-(NSMutableArray *)getAllShortMessage;
- (NSMutableArray *)isSelectShortMessageWithDeviceID:(NSString *)DeviceID;
-(void)deleteShortMessageWithDeviceSMSID:(NSString *)DeviceSMSID;
-(void)deleteShortMessageWithCreateTime:(NSString *)CreateTime;
//----------------------------------本地位置缓存--------------------------------------------------------
//----------------------------------本地位置缓存--------------------------------------------------------
- (void)createLocationCache;
- (void)dropLocationCache;
- (void)addLocationCacheID:(NSString *)DeviceID andLatitudeCache:(NSString *)LatitudeCache andLongitudeCache:(NSString *)LongitudeCache andLocationAddress:(NSString *)LocationAddress andLocationCacheType:(NSString *)LocationCacheType andServerTimeCache:(NSString *)ServerTimeCache;
-(NSMutableArray *)getAllLocationCache;
- (NSMutableArray *)isSelectLocationCacheWithDeviceID:(NSString *)DeviceID;
-(void)deleteLocationCacheWithDeviceCacheID:(NSString *)LocationCacheID;
-(void)deleteLocationCacheWithCreateTime:(NSString *)CreateTime;
//----------------------------------位置--------------------------------------------------------
//----------------------------------位置--------------------------------------------------------
- (NSMutableArray *)isSelectLocationTable:(NSString *)DeviceID;
- (void)addLocationDeviceID:(NSString *)DeviceID andAltitude:(NSString *)Altitude andCourse:(NSString *)Course andLocationType:(NSString *)LocationType andCreateTime:(NSString *)CreateTime andElectricity:(NSString *)Electricity andGSM:(NSString *)GSM andStep:(NSString *)Step andHealth:(NSString *)Health andLatitude:(NSString *)Latitude andLongitude:(NSString *)Longitude andOnline:(NSString *)Online andSatelliteNumber:(NSString *)SatelliteNumber andServerTime:(NSString *)ServerTime andSpeed:(NSString *)Speed andUpdateTime:(NSString *)UpdateTime andDeviceTime:(NSString *)DeviceTime;
- (void)dropLocation;
- (void)createLocation;
-(void)deleteLocationWithDeviceID:(NSString *)DeviceID;

//更新通讯录
- (void)updataSQL:(NSString *)tabl andType:(NSString *)type andValue:(NSString *)value andDeviceContanID:(NSString *)DeviceContanID;
//----------------------------------相册--------------------------------------------------------
//----------------------------------相册--------------------------------------------------------
- (void)createPhoto;
- (NSMutableArray *)isSelectPhotoTable:(NSString *)DeviceID;
- (void)addPhotoPhotoId:(NSString *)DevicePhotoId andDeviceID:(NSString *)DeviceID andSource:(NSString *)Source andDeviceTime:(NSString *)DeviceTime andLatitude:(NSString *)Latitude andLongitude:(NSString *)Longitude andMark:(NSString *)Mark  andPath:(NSString *)Path andLength:(NSString *)Length andCreateTime:(NSString *)CreateTime andUpdateTime:(NSString *)UpdateTime andAddress:(NSString *)Address;
-(void)deletePhotoWithPhotoID:(NSString *)DevicePhotoId;
- (void)updataSQL:(NSString *)tabl andType:(NSString *)type andValue:(NSString *)value andDevicePhotoId:(NSString *)DevicePhotoId;
- (void)dropPhotoTable;

@end
