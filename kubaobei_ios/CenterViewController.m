//
//  CenterViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//
#import "DialingNumberController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <UserNotifications/UserNotifications.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreLocation/CoreLocation.h>
#import "KKSequenceImageView.h"
#import "CenterViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AudioViewController.h"
#import "DXAlertView.h"
#import "DataManager.h"
#import "AudioModel.h"
#import "DeviceModel.h"
#import "LocationModel.h"
#import "WatchAnnotationView.h"
#import "JSBadgeView.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "UIImageView+WebCache.h"
#import "OMGToast.h"
#import "ZFCDoubleBounceActivityIndicatorView.h"
#import "LXActionSheet.h"
#import "EditHeadAndNameViewController.h"
#import "MylocationAnnotationView.h"
#import "LocationCache.h"
#import "UserModel.h"
#import "CommUtil.h"
#import "Constants.h"
//extern NSString *deviceTokenStr_test;
BOOL is_D8_show;

@interface CenterViewController () <UIAlertViewDelegate, LXActionSheetDelegate> {
    int Voice;
    CLLocationManager *locationManager;
    CLLocationCoordinate2D locationPerson;
    MKCoordinateSpan theSpan;
    BOOL isShow;
    DataManager *manage;
    DeviceModel *deviceModel;
    AudioModel *audioModel;
    NSMutableArray *deviceArray;
    NSUserDefaults *defaults;
    NSMutableArray *locationArray;
    LocationModel *locationModel;
    CLLocationCoordinate2D locationCar;
    CLGeocoder *_geocoder;
    JSBadgeView *bageView;
    dispatch_source_t TIMER;
    NSString *severTimer;
    NSArray *notification;
    NSArray *location;
    NSString *app_Version;
    int mapType;
    int ver;
    NSTimer *timer;
    NSTimer *refreshTimer;
    int second;
    NSTimer *secondTimer;
    BOOL isMyLocation;
    CLLocationCoordinate2D myLocation;
    CLLocationCoordinate2D myLocation_old;
    BOOL isOnce;
    BOOL isMyLocation_show;
    BOOL isGPS;
    BOOL isMyLocation_refresh;
    LocationCache *locationcache;
    LocationCache *locationcache_lately;
    LocationCache *locationcache_dic;
    NSMutableArray *locationcacheArray;
    NSMutableArray *address_str;
    //NSMutableArray *locationcache_address;
    CLLocationCoordinate2D locationCar_old;
    NSString *severTimer_dic;
    NSLock* lock;
    BOOL isdoubleBounceTimer;
    NSTimer *doubleBounceTimer;
    UserModel *model;
}
@property (strong, nonatomic) IBOutlet UIView *centerView;

@end

@implementation CenterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    Voice = 0;
    lock = [[NSLock alloc]init];
    //    [self.window makeKeyAndVisible];
    __weak typeof(self) weakSelf = self;
    DataManager* data = [DataManager shareInstance];
    [self otherOperations];
    //    data.isLogin = false;
    //    if (data.isLogin)
    //    {
    //        [lock lock];
    //        [self animationImageTwo];
    //        [lock unlock];
    //        //        [self otherOperations];
    //
    //    }else
    //    {
    //
    //    }
    
    
    
}
//开启Runloop
- (void)checkNotificationThread {
    @autoreleasepool {
        timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(ChangeNotifitication) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] run];
    }
}

- (void)ChangeNotifitication {
    if (locationCar.latitude != 0 && locationCar.longitude != 0) {
        //LocationCacheME = [manage isSelectLocationCacheWithDeviceID:deviceModel.DeviceID];
        if (locationcacheArray.count < 200) {
            if ((locationCar_old.latitude != locationCar.latitude) || (locationCar_old.longitude != locationCar.longitude)) {
                locationCar_old = locationCar;
                //locationcache_address = [NSString stringWithFormat:@"%@  %@",severTimer,address_str];
                //[manage deleteLocationCacheWithDeviceCacheID:locationcache.ServerTimeCache];
                [manage addLocationCacheID:deviceModel.DeviceID andLatitudeCache:locationModel.Latitude andLongitudeCache:locationModel.Longitude andLocationAddress:address_str andLocationCacheType:locationModel.LocationType andServerTimeCache:locationModel.ServerTime];
            }
        } else {
            [manage deleteLocationCacheWithDeviceCacheID:locationcache.ServerTimeCache];
        }
    }
    
    if (locationCar.latitude == 0 && locationCar.longitude == 0) {
        
        if (([locationcache.LatitudeCache isEqualToString:@"0"]) && ([locationcache.LongitudeCache isEqualToString:@"0"])) {
            locationCar.latitude = 39.908692;
            locationCar.longitude = 116.397477;
        } else if ((locationcache.LatitudeCache.length == 0) || (locationcache.LongitudeCache.length == 0)) {
            locationCar.latitude = 39.908692;
            locationCar.longitude = 116.397477;
            //            if(myLocation.latitude != 0 && myLocation.longitude != 0)
            //            {
            //                locationCar.latitude = myLocation.latitude;
            //                locationCar.longitude = myLocation.longitude;
            //            }
            //            else
            //            {
            //                locationCar.latitude=39.908692;;
            //                locationCar.longitude=116.397477;
            //            }
            //self.addressLabel.text=[NSString stringWithFormat:@"%@  %@",@"00:00",NSLocalizedString(@"location_address", nil)];
        } else {
            //多设备时，当其中一个设备尚未激活，可能会导致未激活的设备显示上一个已激活设备的定位
            if ([locationcache_lately.LatitudeCache doubleValue] != 0 && [locationcache_lately.LongitudeCache doubleValue] != 0) {
                locationCar.latitude = [locationcache_lately.LatitudeCache doubleValue];
                locationCar.longitude = [locationcache_lately.LongitudeCache doubleValue];
                locationModel.LocationType = locationcache_lately.LocationCacheType;
                locationModel.ServerTime = locationcache_lately.ServerTimeCache;
            } else {
                locationCar.latitude = 39.908692;
                locationCar.longitude = 116.397477;
            }
            
            self.addressLabel.text = [NSString stringWithFormat:@"%@  %@", locationcache_lately.ServerTimeCache, locationcache_lately.LocationAddress];
            
            if (locationModel.LocationType.intValue == 2) {
                if ([deviceModel.DeviceType isEqualToString:@"1"] && isGPS == NO) {
                    self.typeImage.image = [UIImage imageNamed:@"gps_icon"];
                } else {
                    self.typeImage.image = [UIImage imageNamed:@"lbs_icon"];
                }
            }
        }
    }
    
    WebService *webService = [WebService newWithWebServiceAction:@"GetNotification" andDelegate:self];
    webService.tag = 0;
    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
    
    NSArray *parameter = @[loginParameter1];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"GetNotificationResult"];
}

- (void)WebServiceGetCompleted:(id)theWebService {
    WebService *ws = theWebService;
    
    if ([[theWebService soapResults] length] > 0) {
        
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        // 解析成json数据
        id object = [parser objectWithString:[theWebService soapResults] error:&error];
        NSLog(@"messageID - %@",[object objectForKey:@"messageID"]);
        
        if (!error && object) {
            // 获得状态
            int code = [[object objectForKey:@"Code"] intValue];
            
            if (code == 1) {
                if (ws.tag == 0) {
                    [UIApplication sharedApplication].applicationIconBadgeNumber = [[object objectForKey:@"New"] intValue];
                    //语音----------------------------------------------------------------------
                    NSArray *NewList = [object objectForKey:@"NewList"];
                    
                    for (int i = 0; i < NewList.count; i++) {
                        if ([[[NewList objectAtIndex:i] objectForKey:@"DeviceID"] isEqualToString:deviceModel.DeviceID]) {
                            int Voice1 = [[[NewList objectAtIndex:i] objectForKey:@"Voice"] intValue];
                            if (Voice1 > 0) {
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshIIIIII" object:self];
                                
                                if (bageView) {
                                    [bageView removeFromSuperview];
                                }
                                
                                bageView = [[JSBadgeView alloc] initWithParentView:self.audioBtn alignment:JSBadgeViewAlignmentTopRight];
                                bageView.tag = [[[NewList objectAtIndex:i] objectForKey:@"DeviceID"] intValue];
                                if ([deviceModel.DeviceType isEqualToString:@"1"]) {
                                    bageView.badgeText = [NSString stringWithFormat:@"%d", Voice1];
                                    if (Voice1 != Voice) {
                                        [self requestLocationNotification];
                                        Voice = Voice1;
                                    }
                                    
                                }
                                [self.audioBtn addSubview:bageView];
                            } else {
                                [bageView removeFromSuperview];
                            }
                            
                            //小红点
                            if ([[[NewList objectAtIndex:i] objectForKey:@"Message"] intValue] > 0
                                || [[[NewList objectAtIndex:i] objectForKey:@"SMS"] intValue] > 0) {
                                if ([[[NewList objectAtIndex:i] objectForKey:@"Message"] intValue] > 0) {
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage" object:[[NewList objectAtIndex:i] objectForKey:@"Message"]];
                                    
                                    self.cirCleImage.hidden = NO;
                                }
                                if ([[[NewList objectAtIndex:i] objectForKey:@"SMS"] intValue] > 0) {
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshSMS" object:[[NewList objectAtIndex:i] objectForKey:@"SMS"]];
                                }
                            } else {
                                self.cirCleImage.hidden = YES;
                            }
                            
                            if ([[[NewList objectAtIndex:i] objectForKey:@"Photo"] intValue] > 0) {
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPhoto" object:self];
                            }
                        }
                    }
                    //位置----------------------------------------------------------------------
                    location = [object objectForKey:@"DeviceState"];
                    
                    if (location.count > 0) {
                        for (int i = 0; i < location.count; i++) {
                            if ([[[location objectAtIndex:i] objectForKey:@"DeviceID"] isEqualToString:deviceModel.DeviceID]) {
                                dispatch_queue_t queue = dispatch_queue_create("name", NULL);
                                //创建一个子线程
                                dispatch_async(queue, ^{
                                    // 子线程code... ..
                                    [manage deleteLocationWithDeviceID:deviceModel.DeviceID];
                                    
                                    if (location.count != 0) {
                                        
                                        [manage addLocationDeviceID:deviceModel.DeviceID andAltitude:[[location objectAtIndex:i] objectForKey:@"Altitude"] andCourse:[[location objectAtIndex:i] objectForKey:@"Course"] andLocationType:[[location objectAtIndex:i] objectForKey:@"LocationType"] andCreateTime:[[location objectAtIndex:i] objectForKey:@"DeviceTime"] andElectricity:[[location objectAtIndex:i] objectForKey:@"Electricity"] andGSM:[[location objectAtIndex:i] objectForKey:@"GSM"] andStep:[[location objectAtIndex:i] objectForKey:@"Step"] andHealth:[[location objectAtIndex:i] objectForKey:@"Health"] andLatitude:[[location objectAtIndex:i] objectForKey:@"Latitude"] andLongitude:[[location objectAtIndex:i] objectForKey:@"Longitude"] andOnline:[[location objectAtIndex:i] objectForKey:@"Online"] andSatelliteNumber:[[location objectAtIndex:i] objectForKey:@"SatelliteNumber"] andServerTime:[[location objectAtIndex:i] objectForKey:@"ServerTime"] andSpeed:[[location objectAtIndex:i] objectForKey:@"Speed"] andUpdateTime:nil andDeviceTime:[[location objectAtIndex:i] objectForKey:@"DeviceTime"]];
                                    }
                                    
                                    //回到主线程
                                    dispatch_sync(dispatch_get_main_queue(), ^{//其实这个也是在子线程中执行的，只是把它放到了主线程的队列中
                                        Boolean isMain = [NSThread isMainThread];
                                        if (isMain) {
                                            if (location.count != 0) {
                                                [defaults setObject:[[location objectAtIndex:i] objectForKey:@"Latitude"] forKey:@"Latitude"];
                                                [defaults setObject:[[location objectAtIndex:i] objectForKey:@"Longitude"] forKey:@"Longitude"];
                                                [defaults setObject:[[location objectAtIndex:i] objectForKey:@"LocationType"] forKey:@"LocationType"];
                                                
                                                [defaults setObject:[[location objectAtIndex:i] objectForKey:@"ServerTime"] forKey:@"ServerTime"];
                                                //    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshLocation" object:self];
                                                isOnce = YES;
                                                [self getLocation];
                                                
                                            }
                                        }
                                    });
                                });
                            }
                        }
                    }
                    
                    
                    notification = [object objectForKey:@"Notification"];
                    if (notification.count > 0) {
                        for (int i = 0; i < notification.count; i++) {
                            if ([[[notification objectAtIndex:i] objectForKey:@"Type"] intValue] == 230) {
                                [defaults setObject:[[notification objectAtIndex:i] objectForKey:@"DeviceID"] forKey:@"NODeviceID"];
                                
                                [self getBabyList];
                                
                            } else if ([[[notification objectAtIndex:i] objectForKey:@"Type"] intValue] == 231) {
                                [defaults setObject:[[notification objectAtIndex:i] objectForKey:@"DeviceID"] forKey:@"NODeviceID"];
                                
                                [self getDevieSet];
                            } else if ([[[notification objectAtIndex:i] objectForKey:@"Type"] intValue] == 232) {
                                [defaults setObject:[[notification objectAtIndex:i] objectForKey:@"DeviceID"] forKey:@"NODeviceID"];
                                if ([[defaults objectForKey:@"addSuccess"] intValue] == 1) {
                                    [defaults setObject:@"0" forKey:@"addSuccess"];
                                } else {
                                    [self getContant];
                                }
                                
                            } else if ([[[notification objectAtIndex:i] objectForKey:@"Type"] intValue] == 2) {
                                if ([[defaults objectForKey:@"Type2"] intValue] == 1) {
                                    NSArray *arr = [[[notification objectAtIndex:i] objectForKey:@"Content"] componentsSeparatedByString:@","];
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:[[notification objectAtIndex:i] objectForKey:@"Message"] delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
                                    
                                    alert.tag = 102;
                                    [alert show];
                                    
                                    [defaults setObject:[[notification objectAtIndex:i] objectForKey:@"DeviceID"] forKey:@"NODeviceID"];
                                    [defaults setObject:[arr objectAtIndex:0] forKey:@"NOUseID"];
                                    
                                    [manage addContactTable:[defaults objectForKey:@"binnumber"] andDeviceContactId:@"100000000" andRelationship:[arr objectAtIndex:1] andPhoto:@"8" andPhoneNumber:NSLocalizedString(@"to_agree_with_associated_equipment", nil) andPhoneShort:nil andType:nil andObjectId:nil andHeadImg:nil];
                                    [defaults setObject:@"1" forKey:@"addSuccess"];
                                }
                            } else if ([[[notification objectAtIndex:i] objectForKey:@"Type"] intValue] == 9) {
                                if ([[defaults objectForKey:@"Type9"] intValue] == 1) {
                                    [OMGToast showWithText:NSLocalizedString(@"administrator_lift_device", nil) bottomOffset:50 duration:2];
                                    [defaults setObject:@"" forKey:@"binnumber"];
                                    
                                    [defaults setObject:@"0" forKey:@"DMloginScaleKey"];
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"poptoroot" object:self];
                                }
                            } else if ([[notification[i] objectForKey:@"Type"] intValue] == 3) {
                                if ([[defaults objectForKey:@"Type3"] intValue] == 1) {
                                    [defaults setObject:[notification[i] objectForKey:@"DeviceID"] forKey:@"selectDeviceID"];
                                    WebService *webService = [WebService newWithWebServiceAction:@"GetDeviceList" andDelegate:self];
                                    webService.tag = 102;
                                    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
                                    
                                    NSArray *parameter = @[loginParameter1];
                                    // webservice请求并获得结果
                                    webService.webServiceParameter = parameter;
                                    [webService getWebServiceResult:@"GetDeviceListResult"];
                                }
                            }
                        }
                    }
                } else if (ws.tag == 1) {
                    //更新宝贝资料数据库
                    [manage updataSQL:@"favourite_info" andType:@"BabyName" andValue:[object objectForKey:@"BabyName"] andDevice:[defaults objectForKey:@"NODeviceID"]];
                    [manage updataSQL:@"favourite_info" andType:@"BindNumber" andValue:[object objectForKey:@"BindNumber"] andDevice:[defaults objectForKey:@"NODeviceID"]];
                    [manage updataSQL:@"favourite_info" andType:@"DeviceType" andValue:[object objectForKey:@"DeviceType"] andDevice:[defaults objectForKey:@"NODeviceID"]];
                    [manage updataSQL:@"favourite_info" andType:@"Birthday" andValue:[object objectForKey:@"Birthday"] andDevice:[defaults objectForKey:@"NODeviceID"]];
                    [manage updataSQL:@"favourite_info" andType:@"CreateTime" andValue:[object objectForKey:@"CreateTime"] andDevice:[defaults objectForKey:@"NODeviceID"]];
                    [manage updataSQL:@"favourite_info" andType:@"CurrentFirmware" andValue:[object objectForKey:@"CurrentFirmware"] andDevice:[defaults objectForKey:@"NODeviceID"]];
                    [manage updataSQL:@"favourite_info" andType:@"SetVersionNO" andValue:[object objectForKey:@"SetVersionNO"] andDevice:[defaults objectForKey:@"NODeviceID"]];
                    [manage updataSQL:@"favourite_info" andType:@"ContactVersionNO" andValue:[object objectForKey:@"ContactVersionNO"] andDevice:[defaults objectForKey:@"NODeviceID"]];
                    [manage updataSQL:@"favourite_info" andType:@"OperatorType" andValue:[object objectForKey:@"OperatorType"] andDevice:[defaults objectForKey:@"NODeviceID"]];
                    [manage updataSQL:@"favourite_info" andType:@"SmsNumber" andValue:[object objectForKey:@"SmsNumber"] andDevice:[defaults objectForKey:@"NODeviceID"]];
                    [manage updataSQL:@"favourite_info" andType:@"SmsBalanceKey" andValue:[object objectForKey:@"SmsBalanceKey"] andDevice:[defaults objectForKey:@"NODeviceID"]];
                    [manage updataSQL:@"favourite_info" andType:@"SmsFlowKey" andValue:[object objectForKey:@"SmsFlowKey"] andDevice:[defaults objectForKey:@"NODeviceID"]];
                    [manage updataSQL:@"favourite_info" andType:@"DeviceID" andValue:[object objectForKey:@"DeviceID"] andDevice:[defaults objectForKey:@"NODeviceID"]];
                    [manage updataSQL:@"favourite_info" andType:@"UserId" andValue:[object objectForKey:@"UserId"] andDevice:[defaults objectForKey:@"NODeviceID"]];
                    [manage updataSQL:@"favourite_info" andType:@"DeviceModelID" andValue:[object objectForKey:@"DeviceModelID"] andDevice:[defaults objectForKey:@"NODeviceID"]];
                    [manage updataSQL:@"favourite_info" andType:@"Firmware" andValue:[object objectForKey:@"Firmware"] andDevice:[defaults objectForKey:@"NODeviceID"]];
                    [manage updataSQL:@"favourite_info" andType:@"Gender" andValue:[object objectForKey:@"Gender"] andDevice:[defaults objectForKey:@"NODeviceID"]];
                    [manage updataSQL:@"favourite_info" andType:@"Grade" andValue:[object objectForKey:@"Grade"] andDevice:[defaults objectForKey:@"NODeviceID"]];
                    [manage updataSQL:@"favourite_info" andType:@"HireExpireDate" andValue:[object objectForKey:@"HireExpireDate"] andDevice:[defaults objectForKey:@"NODeviceID"]];
                    [manage updataSQL:@"favourite_info" andType:@"HomeAddress" andValue:[object objectForKey:@"HomeAddress"] andDevice:[defaults objectForKey:@"NODeviceID"]];
                    [manage updataSQL:@"favourite_info" andType:@"HomeLat" andValue:[object objectForKey:@"HomeLat"] andDevice:[defaults objectForKey:@"NODeviceID"]];
                    
                    [manage updataSQL:@"favourite_info" andType:@"HomeLng" andValue:[object objectForKey:@"HomeLng"] andDevice:[defaults objectForKey:@"NODeviceID"]];
                    [manage updataSQL:@"favourite_info" andType:@"IsGuard" andValue:[object objectForKey:@"IsGuard"] andDevice:[defaults objectForKey:@"NODeviceID"]];
                    [manage updataSQL:@"favourite_info" andType:@"Password" andValue:[object objectForKey:@"Password"] andDevice:[defaults objectForKey:@"NODeviceID"]];
                    [manage updataSQL:@"favourite_info" andType:@"PhoneCornet" andValue:[object objectForKey:@"PhoneCornet"] andDevice:[defaults objectForKey:@"NODeviceID"]];
                    [manage updataSQL:@"favourite_info" andType:@"PhoneNumber" andValue:[object objectForKey:@"PhoneNumber"] andDevice:[defaults objectForKey:@"NODeviceID"]];
                    [manage updataSQL:@"favourite_info" andType:@"Photo" andValue:[object objectForKey:@"Photo"] andDevice:[defaults objectForKey:@"NODeviceID"]];
                    [manage updataSQL:@"favourite_info" andType:@"SchoolAddress" andValue:[object objectForKey:@"SchoolAddress"] andDevice:[defaults objectForKey:@"NODeviceID"]];
                    
                    [manage updataSQL:@"favourite_info" andType:@"SchoolLat" andValue:[object objectForKey:@"SchoolLat"] andDevice:[defaults objectForKey:@"NODeviceID"]];
                    [manage updataSQL:@"favourite_info" andType:@"SchoolLng" andValue:[object objectForKey:@"SchoolLng"] andDevice:[defaults objectForKey:@"NODeviceID"]];
                    [manage updataSQL:@"favourite_info" andType:@"SerialNumber" andValue:[object objectForKey:@"SerialNumber"] andDevice:[defaults objectForKey:@"NODeviceID"]];
                    [manage updataSQL:@"favourite_info" andType:@"UpdateTime" andValue:[object objectForKey:@"UpdateTime"] andDevice:[defaults objectForKey:@"NODeviceID"]];
                    [manage updataSQL:@"favourite_info" andType:@"LatestTime" andValue:[object objectForKey:@"LatestTime"] andDevice:[defaults objectForKey:@"NODeviceID"]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeHeadImage" object:self];
                    
                    [self ChangeHead];
                } else if (ws.tag == 2) {
                    NSMutableArray *arra = [manage isSelectFaWithDevice:[defaults objectForKey:@"NODeviceID"]];
                    if (arra.count != 0) {
                        DeviceModel *de = arra[0];
                        if (de != nil) {
                            NSArray *setinfo = [[object objectForKey:@"SetInfo"] componentsSeparatedByString:@"-"];
                            [manage updataSQL:@"device_set" andType:@"AutoAnswer" andValue:setinfo[11] andBindle:de.BindNumber];
                            [manage updataSQL:@"device_set" andType:@"ReportCallsPosition" andValue:setinfo[10] andBindle:de.BindNumber];
                            [manage updataSQL:@"device_set" andType:@"BodyFeelingAnswer" andValue:setinfo[9] andBindle:de.BindNumber];
                            [manage updataSQL:@"device_set" andType:@"ExtendEmergencyPower" andValue:setinfo[8] andBindle:de.BindNumber];
                            [manage updataSQL:@"device_set" andType:@"ClassDisable" andValue:setinfo[7] andBindle:de.BindNumber];
                            [manage updataSQL:@"device_set" andType:@"TimeSwitchMachine" andValue:setinfo[6] andBindle:de.BindNumber];
                            [manage updataSQL:@"device_set" andType:@"RefusedStrangerCalls" andValue:setinfo[5] andBindle:de.BindNumber];
                            [manage updataSQL:@"device_set" andType:@"WatchOffAlarm" andValue:[setinfo objectAtIndex:4] andBindle:de.BindNumber];
                            [manage updataSQL:@"device_set" andType:@"WatchCallVoice" andValue:[setinfo objectAtIndex:3] andBindle:de.BindNumber];
                            [manage updataSQL:@"device_set" andType:@"WatchCallVibrate" andValue:[setinfo objectAtIndex:2] andBindle:de.BindNumber];
                            [manage updataSQL:@"device_set" andType:@"WatchInformationSound" andValue:setinfo[1] andBindle:de.BindNumber];
                            [manage updataSQL:@"device_set" andType:@"WatchInformationShock" andValue:setinfo[0] andBindle:de.BindNumber];
                            
                            NSArray *class1 = [[object objectForKey:@"ClassDisabled1"] componentsSeparatedByString:@"-"];
                            
                            NSArray *class2 = [[object objectForKey:@"ClassDisabled2"] componentsSeparatedByString:@"-"];
                            
                            [manage updataSQL:@"device_set" andType:@"ClassDisabled1" andValue:class1[0] andBindle:de.BindNumber];
                            [manage updataSQL:@"device_set" andType:@"ClassDisabled2" andValue:class1[1] andBindle:de.BindNumber];
                            [manage updataSQL:@"device_set" andType:@"ClassDisabled3" andValue:class2[0] andBindle:de.BindNumber];
                            [manage updataSQL:@"device_set" andType:@"ClassDisabled4" andValue:class2[1] andBindle:de.BindNumber];
                            [manage updataSQL:@"device_set" andType:@"WeekDisabled" andValue:[object objectForKey:@"WeekDisabled"] andBindle:de.BindNumber];
                            [manage updataSQL:@"device_set" andType:@"TimerOpen" andValue:[object objectForKey:@"TimerOpen"] andBindle:de.BindNumber];
                            [manage updataSQL:@"device_set" andType:@"TimerClose" andValue:[object objectForKey:@"TimerClose"] andBindle:de.BindNumber];
                            [manage updataSQL:@"device_set" andType:@"BrightScreen" andValue:[object objectForKey:@"BrightScreen"] andBindle:de.BindNumber];
                            [manage updataSQL:@"device_set" andType:@"WeekAlarm1" andValue:[object objectForKey:@"WeekAlarm1"] andBindle:de.BindNumber];
                            [manage updataSQL:@"device_set" andType:@"WeekAlarm2" andValue:[object objectForKey:@"WeekAlarm2"] andBindle:de.BindNumber];
                            [manage updataSQL:@"device_set" andType:@"WeekAlarm3" andValue:[object objectForKey:@"WeekAlarm3"] andBindle:de.BindNumber];
                            [manage updataSQL:@"device_set" andType:@"Alarm1" andValue:[object objectForKey:@"Alarm1"] andBindle:de.BindNumber];
                            [manage updataSQL:@"device_set" andType:@"Alarm2" andValue:[object objectForKey:@"Alarm2"] andBindle:de.BindNumber];
                            [manage updataSQL:@"device_set" andType:@"Alarm3" andValue:[object objectForKey:@"Alarm3"] andBindle:de.BindNumber];
                            [manage updataSQL:@"device_set" andType:@"LocationMode" andValue:[object objectForKey:@"LocationMode"] andBindle:de.BindNumber];
                            [manage updataSQL:@"device_set" andType:@"LocationTime" andValue:[object objectForKey:@"LocationTime"] andBindle:de.BindNumber];
                            [manage updataSQL:@"device_set" andType:@"FlowerNumber" andValue:[object objectForKey:@"FlowerNumber"] andBindle:de.BindNumber];
                            [manage updataSQL:@"device_set" andType:@"StepCalculate" andValue:[object objectForKey:@"StepCalculate"] andBindle:de.BindNumber];
                            [manage updataSQL:@"device_set" andType:@"SleepCalculate" andValue:[object objectForKey:@"SleepCalculate"] andBindle:de.BindNumber];
                            [manage updataSQL:@"device_set" andType:@"HrCalculate" andValue:[object objectForKey:@"HrCalculate"] andBindle:de.BindNumber];
                            NSString* sosMagswitch;
                            if ([[object objectForKey:@"SosMsgswitch"] isEqualToString:@"0"]) {
                                sosMagswitch = @"1";
                            }else
                            {
                                sosMagswitch = @"0";
                                
                            }
                            [manage updataSQL:@"device_set" andType:@"SosMsgswitch" andValue:sosMagswitch andBindle:de.BindNumber];
                            
                            DLog(@"%@",sosMagswitch);
                            [manage updataSQL:@"device_set" andType:@"TimeZone" andValue:@"" andBindle:de.BindNumber];
                            [manage updataSQL:@"device_set" andType:@"Language" andValue:@"" andBindle:de.BindNumber];
                        }
                    }
                } else if (ws.tag == 3) {
                    //更新通讯录
                    NSMutableArray *arra = [manage isSelectFaWithDevice:[defaults objectForKey:@"NODeviceID"]];
                    if (arra.count != 0) {
                        DeviceModel *des = arra[0];
                        if (des != nil) {
                            [manage removeContactTable:des.BindNumber];
                            NSArray *conArr = [object objectForKey:@"ContactArr"];
                            for (int i = 0; i < conArr.count; i++) {
                                [manage addContactTable:des.BindNumber andDeviceContactId:[[conArr objectAtIndex:i] objectForKey:@"DeviceContactId"] andRelationship:[[conArr objectAtIndex:i] objectForKey:@"Relationship"] andPhoto:[[conArr objectAtIndex:i] objectForKey:@"Photo"] andPhoneNumber:[[conArr objectAtIndex:i] objectForKey:@"PhoneNumber"] andPhoneShort:[[conArr objectAtIndex:i] objectForKey:@"PhoneShort"] andType:[[conArr objectAtIndex:i] objectForKey:@"Type"] andObjectId:[[conArr objectAtIndex:i] objectForKey:@"ObjectId"] andHeadImg:[[conArr objectAtIndex:i] objectForKey:@"HeadImg"]];
                            }
                            
                        }
                    }
                } else if (ws.tag == 100) {
                    [defaults setObject:[object objectForKey:@"AppleUrl"] forKey:@"AppleUrl"];
                    
                    if (ver < [[object objectForKey:@"AppleVersion"] intValue]) {
                        UIAlertView *view = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"have_new_versions", nil) message:[NSString stringWithFormat:NSLocalizedString(@"have_new_versions", nil)] delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"update_latter", nil), NSLocalizedString(@"update_now", nil), nil];
                        [view show];
                    }
                } else if (ws.tag == 102) {
                    NSArray *ar = [object objectForKey:@"deviceList"];
                    for (int i = 0; i < ar.count; i++) {
                        if ([[[ar objectAtIndex:i] objectForKey:@"DeviceID"] intValue] == [[defaults objectForKey:@"selectDeviceID"] intValue]) {
                            NSDictionary *dic = [ar objectAtIndex:i];
#pragma mark - 写入设备信息表
                            [manage addFavourite:[dic objectForKey:@"ActiveDate"]
                                     andBabyName:[dic objectForKey:@"BabyName"] andBindNumber:[dic objectForKey:@"BindNumber"] andDeviceType:[dic objectForKey:@"DeviceType"] andBirthday:[dic objectForKey:@"Birthday"] andCreateTime:[dic objectForKey:@"CreateTime"] andCurrentFirmware:[dic objectForKey:@"CurrentFirmware"] andDeviceID:[dic objectForKey:@"DeviceID"] andDeviceModelID:[dic objectForKey:@"DeviceModelID"] andFirmware:[dic objectForKey:@"Firmware"] andGender:[dic objectForKey:@"Gender"] andGrade:[dic objectForKey:@"Grade"] andHireExpireDate:[dic objectForKey:@"HireExpireDate"] andDate:[dic objectForKey:@"Date"] andHomeAddress:[dic objectForKey:@"HomeAddress"] andHomeLat:[dic objectForKey:@"HomeLat"] andHomeLng:[dic objectForKey:@"HomeLng"] andIsGuard:[dic objectForKey:@"IsGuard"] andPassword:[dic objectForKey:@"Password"] andPhoneCornet:[dic objectForKey:@"PhoneCornet"] andPhoneNumber:[dic objectForKey:@"PhoneNumber"] andPhoto:[dic objectForKey:@"Photo"] andSchoolAddress:[dic objectForKey:@"SchoolAddress"] andSchoolLat:[dic objectForKey:@"SchoolLat"] andSchoolLng:[dic objectForKey:@"SchoolLng"] andSerialNumber:[dic objectForKey:@"SerialNumber"] andUpdateTime:[dic objectForKey:@"UpdateTime"] andUserId:[dic objectForKey:@"UserId"] andSetVersionNO:[dic objectForKey:@"SetVersionNO"] andContactVersionNO:[dic objectForKey:@"ContactVersionNO"] andOperatorType:[dic objectForKey:@"OperatorType"] andSmsNumber:[dic objectForKey:@"SmsNumber"] andSmsBalanceKey:[dic objectForKey:@"SmsBalanceKey"] andSmsFlowKey:[dic objectForKey:@"SmsFlowKey"] andLatestTime:[dic objectForKey:@"LatestTime"]];
                            
#pragma mark - 写入设备设置表
                            NSDictionary *set = [dic objectForKey:@"DeviceSet"];
                            NSLog(set);
                            NSArray *setInfo = [[set objectForKey:@"SetInfo"] componentsSeparatedByString:@"-"];
                            
                            NSArray *classStar = [[set objectForKey:@"ClassDisabled1"] componentsSeparatedByString:@"-"];
                            
                            NSArray *classStop = [[set objectForKey:@"ClassDisabled2"] componentsSeparatedByString:@"-"];
                            
                            [manage addDeviceSetTable:[dic objectForKey:@"BindNumber"] andVersionNumber:nil andAutoAnswer:[setInfo objectAtIndex:11] andReportCallsPosition:[setInfo objectAtIndex:10] andBodyFeelingAnswer:[setInfo objectAtIndex:9] andExtendEmergencyPower:[setInfo objectAtIndex:8] andClassDisable:[setInfo objectAtIndex:7] andTimeSwitchMachine:[setInfo objectAtIndex:6] andRefusedStrangerCalls:[setInfo objectAtIndex:5] andWatchOffAlarm:[setInfo objectAtIndex:4] andWatchCallVoice:[setInfo objectAtIndex:3] andWatchCallVibrate:[setInfo objectAtIndex:2] andWatchInformationSound:[setInfo objectAtIndex:1] andWatchInformationShock:[setInfo objectAtIndex:0] andClassDisabled1:[classStar objectAtIndex:0] andClassDisabled2:[classStar objectAtIndex:1] andClassDisabled3:[classStop objectAtIndex:0] andClassDisabled4:[classStop objectAtIndex:1] andWeekDisabled:[set objectForKey:@"WeekDisabled"] andTimerOpen:[set objectForKey:@"TimerOpen"] andTimerClose:[set objectForKey:@"TimerClose"] andBrightScreen:[set objectForKey:@"BrightScreen"] andweekAlarm1:[set objectForKey:@"WeekAlarm1"] andweekAlarm2:[set objectForKey:@"WeekAlarm2"] andweekAlarm3:[set objectForKey:@"WeekAlarm3"] andalarm1:[set objectForKey:@"Alarm1"] andalarm2:[set objectForKey:@"Alarm2"] andalarm3:[set objectForKey:@"Alarm3"] andlocationMode:[set objectForKey:@"LocationMode"] andlocationTime:[set objectForKey:@"LocationTime"] andflowerNumber:[set objectForKey:@"FlowerNumber"] andStepCalculate:[set objectForKey:@"StepCalculate"] andSleepCalculate:[set objectForKey:@"SleepCalculate"] andHrCalculate:[set objectForKey:@"HrCalculate"] andSosMsgswitch:[set objectForKey:@"SosMsgswitch"] andTimeZone:@"" andLanguage:@"" andDialPad:@"0"];
                            
#pragma mark - 写入联系人表
                            NSArray *contact = [dic objectForKey:@"ContactArr"];
                            for (int i = 0; i < contact.count; i++) {
                                NSDictionary *con = [contact objectAtIndex:i];
                                
                                [manage addContactTable:[dic objectForKey:@"BindNumber"] andDeviceContactId:[con objectForKey:@"DeviceContactId"] andRelationship:[con objectForKey:@"Relationship"] andPhoto:[con objectForKey:@"Photo"] andPhoneNumber:[con objectForKey:@"PhoneNumber"] andPhoneShort:[con objectForKey:@"PhoneShort"] andType:[con objectForKey:@"Type"] andObjectId:[con objectForKey:@"ObjectId"] andHeadImg:[con objectForKey:@"HeadImg"]];
                            }
                            
#pragma mark - 写入位置表
                            NSDictionary *locations = [dic objectForKey:@"DeviceState"];
                            [manage addLocationDeviceID:[dic objectForKey:@"DeviceID"] andAltitude:[locations objectForKey:@"Altitude"] andCourse:[locations objectForKey:@"Course"] andLocationType:[locations objectForKey:@"LocationType"] andCreateTime:[locations objectForKey:@"CreateTime"] andElectricity:[locations objectForKey:@"Electricity"] andGSM:[locations objectForKey:@"GSM"] andStep:[locations objectForKey:@"Step"] andHealth:[locations objectForKey:@"Health"] andLatitude:[locations objectForKey:@"Latitude"] andLongitude:[locations objectForKey:@"Longitude"] andOnline:[locations objectForKey:@"Online"] andSatelliteNumber:[locations objectForKey:@"SatelliteNumber"] andServerTime:[locations objectForKey:@"ServerTime"] andSpeed:[locations objectForKey:@"Speed"] andUpdateTime:[locations objectForKey:@"UpdateTime"] andDeviceTime:[locations objectForKey:@"DeviceTime"]];
                        }
                        
                    }
                    deviceModel = [[manage isSelectFaWithDevice:[defaults objectForKey:@"selectDeviceID"]] objectAtIndex:0];
                    
                    [defaults setObject:deviceModel.BindNumber forKey:@"binnumber"];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeHeadImage" object:self];
                    
                } else if (ws.tag == 1111) {
                    ZFCDoubleBounceActivityIndicatorView *doubleBounce = [[ZFCDoubleBounceActivityIndicatorView alloc] init];
                    doubleBounce.center = self.locationBtn.center;
                    
                    [doubleBounce startAnimating];
                    
                    if (isdoubleBounceTimer) {
                        //[doubleBounceTimer invalidate];
                        //isdoubleBounceTimer=NO;
                        //[doubleBounce removeFromSuperview];
                        //[doubleBounce stopAnimating];
                        
                        //return;
                    }
                    
                    if (doubleBounce) {
                        [doubleBounce removeFromSuperview];
                    }
                    [self.view addSubview:doubleBounce];
                    
                    doubleBounceTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:doubleBounce selector:@selector(stopAnimating) userInfo:nil repeats:NO];
                    
                } else if (ws.tag == 1112) {
                    NSArray *address = [object objectForKey:@"Nearby"];
                    if (address.count != 0 && address.count > 1) {
                        //self.addressLabel.text = [NSString stringWithFormat:@"%@",deviceTokenStr_test];
                        self.addressLabel.text = [NSString stringWithFormat:@"%@  %@%@%@%@,%@,%@", severTimer, [object objectForKey:@"Province"], [object objectForKey:@"City"], [object objectForKey:@"District"], [object objectForKey:@"Road"], [[address objectAtIndex:0] objectForKey:@"POI"], [[address objectAtIndex:1] objectForKey:@"POI"]];
                        
                        address_str = [NSString stringWithFormat:@"%@%@%@%@,%@,%@", [object objectForKey:@"Province"], [object objectForKey:@"City"], [object objectForKey:@"District"], [object objectForKey:@"Road"], [[address objectAtIndex:0] objectForKey:@"POI"], [[address objectAtIndex:1] objectForKey:@"POI"]];
                    } else {
                        //self.addressLabel.text = [NSString stringWithFormat:@"%@",deviceTokenStr_test];
                        self.addressLabel.text = [NSString stringWithFormat:@"%@  %@%@%@%@", severTimer, [object objectForKey:@"Province"], [object objectForKey:@"City"], [object objectForKey:@"District"], [object objectForKey:@"Road"]];
                        
                        address_str = [NSString stringWithFormat:@"%@%@%@%@", [object objectForKey:@"Province"], [object objectForKey:@"City"], [object objectForKey:@"District"], [object objectForKey:@"Road"]];
                    }
                }
            }////////////////////////////////////
            else if (code == 0) {
                if (ws.tag != 1112) {
                    //                    [OMGToast showWithText:[object objectForKey:@"Message"] bottomOffset:50 duration:3];
                    [timer invalidate];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"poptoroot" object:self];
                    
                } else {
                    self.addressLabel.text = [NSString stringWithFormat:@"%@", severTimer];
                    address_str = self.addressLabel.text;
                    //self.addressLabel.text = [NSString stringWithFormat:@"%@  %@",severTimer,NSLocalizedString(@"parse_failure_location_information", nil)];
                }
            } else {
                if (ws.tag != 1112) {
                    int resCode = [[object objectForKey:@"Code"] intValue];
                    if (resCode != 2) {
                        [OMGToast showWithText:[object objectForKey:@"Message"] bottomOffset:50 duration:3];
                    }
                }
            }
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if (alertView.tag == 12) {
            WebService *webService = [WebService newWithWebServiceAction:@"SendDeviceCommand" andDelegate:self];
            webService.tag = 1200;
            WebServiceParameter *loginParameter0 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
            
            WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"deviceId" andValue:deviceModel.DeviceID];
            WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"commandType" andValue:@"Find"];
            WebServiceParameter *loginParameter4 = [WebServiceParameter newWithKey:@"Paramter" andValue:@""];
            NSArray *parameter = @[loginParameter0, loginParameter1, loginParameter3, loginParameter4];
            // webservice请求并获得结
            
            webService.webServiceParameter = parameter;
            [webService getWebServiceResult:@"SendDeviceCommandResult"];
        } else if (alertView.tag == 10000) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showTelPhone" object:self];
            
        } else if (alertView.tag == 102) {
            [defaults setInteger:4 forKey:@"editWatch"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showEditHeadAndName" object:self];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[defaults objectForKey:@"AppleUrl"]]];
        }
    }
}

- (void)getContant {
    WebService *webService = [WebService newWithWebServiceAction:@"GetDeviceContact" andDelegate:self];
    webService.tag = 3;
    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
    WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"deviceId" andValue:[defaults objectForKey:@"NODeviceID"]];
    NSArray *parameter = @[loginParameter1, loginParameter2];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"GetDeviceContactResult"];
}

- (void)getDevieSet {
    WebService *webService = [WebService newWithWebServiceAction:@"GetDeviceSet" andDelegate:self];
    webService.tag = 2;
    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
    WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"deviceId" andValue:[defaults objectForKey:@"NODeviceID"]];
    NSArray *parameter = @[loginParameter1, loginParameter2];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"GetDeviceSetResult"];
}

- (void)getBabyList {
    WebService *webService = [WebService newWithWebServiceAction:@"GetDeviceDetail" andDelegate:self];
    webService.tag = 1;
    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
    WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"deviceId" andValue:[defaults objectForKey:@"NODeviceID"]];
    NSArray *parameter = @[loginParameter1, loginParameter2];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"GetDeviceDetailResult"];
}

- (void)ChangeHead {
    NSMutableArray *array = [manage isSelect:[defaults objectForKey:@"binnumber"]];
    deviceModel = [array objectAtIndex:0];
    
    if (([deviceModel.CurrentFirmware rangeOfString:@"D10_CHUANGMT"].location != NSNotFound) || ([deviceModel.CurrentFirmware rangeOfString:@"D9_CHUANGMT"].location != NSNotFound) || ([deviceModel.CurrentFirmware rangeOfString:@"D9_TP_CHUANGMT"].location != NSNotFound) || ([deviceModel.CurrentFirmware rangeOfString:@"D12_CHUANGMT"].location != NSNotFound)) {
        isGPS = NO;
    } else {
        isGPS = YES;
    }
    
    if (([deviceModel.DeviceType isEqualToString:@"2"]) || ([deviceModel.CurrentFirmware rangeOfString:@"D8_CH"].location != NSNotFound)) {
        is_D8_show = YES;
        self.weilliao_Label.hidden = YES;
        self.shouhu_label.hidden = YES;
        self.shouhuBtn.hidden = YES;
        self.audioBtn.hidden = YES;
        self.cirbgImage.hidden = YES;
        [defaults setInteger:1 forKey:@"deviceModelType"];
    } else {
        is_D8_show = NO;
        self.weilliao_Label.hidden = NO;
        self.shouhu_label.hidden = NO;
        self.shouhuBtn.hidden = NO;
        self.audioBtn.hidden = NO;
        self.cirbgImage.hidden = NO;
        [defaults setInteger:0 forKey:@"deviceModelType"];
    }
    
    if ([deviceModel.Photo isEqualToString:@""]) {
        self.headView.image = [UIImage imageNamed:@"user_head_normal"];
    } else {
        [self.headView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:HTTPS, PHOTO, deviceModel.Photo]]];
    }
    
    if ([deviceModel.BabyName isEqualToString:@""]) {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        self.nameLabel.text = NSLocalizedString(@"app_name", nil);
    } else {
        self.nameLabel.text = deviceModel.BabyName;
    }
    [self getLocation];
    //[self FirstLocation];
}

- (IBAction)showRecord:(id)sender {
    
    self.cirCleImage.hidden = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showMessageRecord" object:self];
}

- (void)getLocation {
    [refreshTimer invalidate];
    [secondTimer invalidate];
    self.second_label.text = @"";
    self.locationBtn.userInteractionEnabled = YES;
    self.locationBtn.enabled = YES;
    second = 60;
    
    isMyLocation = NO;
    [_mapView removeAnnotations:_mapView.annotations];
    
    locationArray = [manage isSelectLocationTable:deviceModel.DeviceID];
    if (locationArray.count > 0) {
        locationModel = [locationArray objectAtIndex:0];
    }
    if(myLocation.latitude == 0 && myLocation.longitude == 0){
    locationCar.latitude = [locationModel.Latitude doubleValue];
    locationCar.longitude = [locationModel.Longitude doubleValue];
    }else{
        float distance = [MapTool getDistance:[locationModel.Latitude floatValue] lng1:[locationModel.Longitude floatValue] lat2:myLocation.latitude lng2:myLocation.longitude];
        if(distance > 100 && distance < 550){
            double present = 100 / distance;
            double lat = myLocation.latitude * present;
            double lon = myLocation.longitude * present;
            locationCar.latitude =  myLocation.latitude + lat;
            locationCar.longitude = myLocation.longitude + lon;
        }else{
            locationCar.latitude = [locationModel.Latitude doubleValue];
            locationCar.longitude = [locationModel.Longitude doubleValue];
        }
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    
    NSDateFormatter *dateFormatters = [[NSDateFormatter alloc] init];
    [dateFormatters setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    
    if (locationModel.ServerTime.length != 0) {
        severTimer = [locationModel.ServerTime substringWithRange:NSMakeRange(0, 10)];
    } else {
        severTimer = @"";
    }
    
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    NSString *dateTime = [dateFormatter stringFromDate:[NSDate date]];
    if (severTimer.length > 0) {
        
        if ([[defaults objectForKey:@"currentLanguage_phone"] intValue] != 1) {
            [dateFormatter setDateFormat:@"y年M月d日 HH:mm"];
            
        } else {
            [dateFormatter setDateFormat:@"d MMMM,y HH:mm"];
            
        }
        
        if ([severTimer isEqualToString:dateTime]) {
            [dateFormatter setDateFormat:@"HH:mm"];
            
            severTimer = [dateFormatter stringFromDate:[dateFormatters dateFromString:locationModel.DeviceTime]];
            severTimer_dic = severTimer;
            
        } else {
            severTimer = [dateFormatter stringFromDate:[dateFormatters dateFromString:locationModel.DeviceTime]];
            severTimer_dic = severTimer;
            //  severTimer = [severTimer substringWithRange:NSMakeRange(5,11)];
        }
    }
    
    theSpan.latitudeDelta = self.mapView.region.span.latitudeDelta;
    
    theSpan.longitudeDelta = self.mapView.region.span.longitudeDelta;
    
    MKCoordinateRegion theRegion;
    
    if (locationCar.latitude > 90.0) {
        locationCar_old.latitude = 39.908692;
        locationCar_old.longitude = 116.397477;
    }
    
    if (locationCar.latitude != 0 && locationCar.longitude != 0) {
        //if(!isOnce)å
        {
            theRegion.center = locationCar;
            theSpan.latitudeDelta = 0.006;
            //
            theSpan.longitudeDelta = 0.006;
            theRegion.span = theSpan;
            
            [self.mapView setRegion:theRegion];
            
        }
        
        isMyLocation = NO;
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        [_mapView removeAnnotations:_mapView.annotations];
        
        annotation.coordinate = locationCar;
        [self.mapView addAnnotation:annotation];
    }
    
    if (locationModel.Electricity.intValue >= 0 && locationModel.Electricity.intValue <= 25) {
        self.batImage.image = [UIImage imageNamed:@"bat_0"];
    } else if (locationModel.Electricity.intValue >= 26 && locationModel.Electricity.intValue <= 50) {
        self.batImage.image = [UIImage imageNamed:@"bat_1"];
    } else if (locationModel.Electricity.intValue >= 51 && locationModel.Electricity.intValue <= 75) {
        self.batImage.image = [UIImage imageNamed:@"bat_2"];
    } else if (locationModel.Electricity.intValue >= 76 && locationModel.Electricity.intValue <= 100) {
        self.batImage.image = [UIImage imageNamed:@"bat_3"];
    } else {
        self.batImage.image = [UIImage imageNamed:@"bat_255"];
    }
    
    if (locationModel.LocationType.intValue == 1) {
        self.typeImage.image = [UIImage imageNamed:@"gps_icon"];
    } else if (locationModel.LocationType.intValue == 2) {
        if ([deviceModel.DeviceType isEqualToString:@"1"] && isGPS == NO) {
            self.typeImage.image = [UIImage imageNamed:@"gps_icon"];
        } else {
            self.typeImage.image = [UIImage imageNamed:@"lbs_icon"];
        }
    } else if (locationModel.LocationType.intValue == 3) {
        self.typeImage.image = [UIImage imageNamed:@"WIFI_icon"];
    } else {
        self.addressLabel.text = [NSString stringWithFormat:@"%@ %@...", severTimer, NSLocalizedString(@"Temporarily_no_data", nil)];
        
        address_str = [NSString stringWithFormat:@"%@...", NSLocalizedString(@"Temporarily_no_data", nil)];
    }
    
    if ([deviceModel.BabyName isEqualToString:@""]) {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        self.nameLabel.text = NSLocalizedString(@"app_name", nil);
    } else {
        self.nameLabel.text = deviceModel.BabyName;
    }
    
    for (int i = 0; i < locationcacheArray.count; i++) {
        locationcache_dic = [locationcacheArray objectAtIndex:i];
        
        if (([[NSString stringWithFormat:@"%f",locationCar.latitude] isEqualToString:locationcache_dic.LatitudeCache]) && ([[NSString stringWithFormat:@"%f",locationCar.longitude] isEqualToString:locationcache_dic.LongitudeCache])) {
            locationCar.latitude = [locationcache_dic.LatitudeCache doubleValue];
            locationCar.longitude = [locationcache_dic.LongitudeCache doubleValue];
            self.addressLabel.text = [NSString stringWithFormat:@"%@  %@", severTimer_dic, locationcache_dic.LocationAddress];
            return;
        }
    }
    
    if (locationModel.Latitude.length != 0 && locationModel.Longitude.length != 0) {
        WebService *webService = [WebService newWithWebServiceAction:@"GetAddress" andDelegate:self];
        webService.tag = 1112;
        WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
        WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"mapType" andValue:@"1"];
        WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"lat" andValue:[NSString stringWithFormat:@"%f",locationCar.latitude]];
        WebServiceParameter *loginParameter4 = [WebServiceParameter newWithKey:@"lng" andValue:[NSString stringWithFormat:@"%f",locationCar.longitude]];
        
        NSArray *parameter = @[loginParameter1, loginParameter2, loginParameter3, loginParameter4];
        // webservice请求并获得结果
        webService.webServiceParameter = parameter;
        [webService getWebServiceResult:@"GetAddressResult"];
        
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    //if(isMyLocation)
    if (annotation == mapView.userLocation) {
        isMyLocation = NO;
        static NSString *annotationId = @"4rrrnwwwwwww";
        MylocationAnnotationView *pin = (MylocationAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:annotationId];
        if (pin == nil) {
            
            pin = [[MylocationAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationId];
        }
        pin.image = [UIImage imageNamed:@"myLocation_icon"];
        //设置中心点偏移，使得标注底部中间点成为经纬度对应点
        //pin.centerOffset = CGPointMake(0, -18);
        return pin;
    } else {
        isMyLocation = YES;
        //大头针视图
        //注意：为了提高显示效率。显示大头针加入复用机制
        static NSString *annotationId = @"4rrrn";
        WatchAnnotationView *pin = (WatchAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:annotationId];
        if (pin == nil) {
            
            pin = [[WatchAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationId];
        }
        pin.image = [UIImage imageNamed:@"location_watch"];
        //设置中心点偏移，使得标注底部中间点成为经纬度对应点
        //pin.centerOffset = CGPointMake(0, -18);
        return pin;
    }
}

//判断是不是在中国
+ (BOOL)isLocationOutOfChina:(CLLocationCoordinate2D)location {
    if (location.longitude < 72.004 || location.longitude > 137.8347 || location.latitude < 0.8293 || location.latitude > 55.8271)
        return YES;
    return NO;
}

//判断手机分辨率
+ (UIDeviceResolution)currentResolution {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            result = CGSizeMake(result.width * [UIScreen mainScreen].scale, result.height * [UIScreen mainScreen].scale);
            
            if (result.height <= 480.0f)
                return UIDevice_iPhone3;
            else if (result.height > 480.0f && result.height <= 960.0f)
                return UIDevice_iPhone4s;
            else if (result.height > 960.0f && result.height <= 1136.0f)
                return UIDevice_iPhone5;
            else if (result.height > 1136.0f && result.height <= 1334.0f)
                return UIDevice_iPhone6;
            else if (result.height > 1334.0f && result.height <= 2208.0f)
                return UIDevice_iPhone6_plus;
            else
                return UIDevice_iPhone5;
        } else
            return UIDevice_iPhone5;
    } else
        return (([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) ? UIDevice_iPadHiRes : UIDevice_iPadStandardRes);
}

//漂移处理
const double x_pi = M_PI * 3000.0 / 300.0;

void transform_mars_2_bear_paw(double gg_lat, double gg_lon, double *bd_lat, double *bd_lon) {
    double x = gg_lon, y = gg_lat;
    double z = sqrt(x * x + y * y) + 0.00002 * sin(y * x_pi);
    double theta = atan2(y, x) + 0.000003 * cos(x * x_pi);
    
    /*
     if ([CenterViewController currentResolution] == UIDevice_iPhone4s) {
     *bd_lon = z * cos(theta) + 0.0045;
     *bd_lat = z * sin(theta) - 0.0030;
     }
     else if ([CenterViewController currentResolution] == UIDevice_iPhone5) {
     *bd_lon = z * cos(theta) + 0.0045;
     *bd_lat = z * sin(theta) - 0.0030;
     }
     else if ([CenterViewController currentResolution] == UIDevice_iPhone6)
     {
     *bd_lon = z * cos(theta) + 0.0045;
     *bd_lat = z * sin(theta) - 0.0030;
     }
     else if ([CenterViewController currentResolution] == UIDevice_iPhone6_plus)
     {
     *bd_lon = z * cos(theta) + 0.0045;
     *bd_lat = z * sin(theta) - 0.0030;
     }
     else
     */
    {
        *bd_lon = z * cos(theta) + 0.0045;
        *bd_lat = z * sin(theta) - 0.0030;
    }
    
}

void transform_bear_paw_2_mars(double bd_lat, double bd_lon, double *gg_lat, double *gg_lon) {
    double x = bd_lon - 0.0065, y = bd_lat - 0.006;
    double z = sqrt(x * x + y * y) - 0.00002 * sin(y * x_pi);
    double theta = atan2(y, x) - 0.000003 * cos(x * x_pi);
    *gg_lon = z * cos(theta);
    *gg_lat = z * sin(theta);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(nonnull CLLocation *)newLocation fromLocation:(nonnull CLLocation *)oldLocation {
    double lat = 0.0;
    double lng = 0.0;
    
    NSLog(@"纬度:%f", newLocation.coordinate.latitude);
    NSLog(@"经度:%f", newLocation.coordinate.longitude);
    if (locationCar.latitude == 0 && locationCar.longitude == 0) {
        MKCoordinateRegion theRegion;
        theRegion.center = CLLocationCoordinate2DMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude);
        theSpan.latitudeDelta = 0.006;
        //
        theSpan.longitudeDelta = 0.006;
    }
    myLocation = newLocation.coordinate;
    isMyLocation = YES;
    
    //if((fabs(myLocation_old.latitude-myLocation.latitude)>0.01)||(fabs(myLocation_old.longitude-myLocation.longitude)>0.01))
    /*
     if((myLocation_old.latitude!=myLocation.latitude)||(myLocation_old.longitude!=myLocation.longitude))
     {
     myLocation_old =myLocation;
     isMyLocation_refresh=YES;
     }
     else{
     isMyLocation_refresh=NO;
     }
     */
    
    //判断是不是属于国内范围
    if (![CenterViewController isLocationOutOfChina:myLocation]) {
        //transform_bear_paw_2_mars(myLocation.latitude, myLocation.longitude, &lat, &lng);
        transform_mars_2_bear_paw(myLocation.latitude, myLocation.longitude, &lat, &lng);
    }
    myLocation.latitude = lat;
    myLocation.longitude = lng;
    
    //[defaults setDouble:newLocation.coordinate.latitude forKey:@"myLa"];
    //[defaults setDouble:newLocation.coordinate.longitude forKey:@"myLo"];
    
    [defaults setDouble:lat forKey:@"myLa"];
    [defaults setDouble:lng forKey:@"myLo"];
    [locationManager stopUpdatingLocation];
    //[manager stopUpdatingLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)showLeftAction:(id)sender {
    
    [defaults setObject:@"0" forKey:@"showLeft"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showLeft" object:self];
    
}

- (IBAction)showAudioView:(id)sender {
    if ([deviceModel.DeviceType isEqualToString:@"2"]) {
        //[bageView removeFromSuperview];
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"showAudio" object:self];
    } else {
        if (bageView)
            [bageView removeFromSuperview];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showAudio" object:self];
    }
}

- (IBAction)showSchoolView:(id)sender {
    if ([deviceModel.DeviceType isEqualToString:@"2"]) {
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"showSchool" object:self];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showSchool" object:self];
    }
}

- (IBAction)showTelPhone:(id)sender {
    
    //    UIStoryboard *UpgradeHardware = [UIStoryboard storyboardWithName:@"DialingNumberController" bundle:nil];
    //    UIViewController *firstVC = [UpgradeHardware instantiateViewControllerWithIdentifier:@"DialingNumberController"];
    //    [self.navigationController pushViewController:firstVC animated:YES];
    //    [[NSNotificationCenter defaultCenter] postNotificationName:@"showDialingNumber" object:self];
    
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc]init];
    NSString* cloudPlatform = [defaults objectForKey:MAIN_USER_CLOUD_PLAT_FORM];
    if (cloudPlatform.intValue > 0)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showDialingNumber" object:self];
    }else{
        if ([deviceModel.DeviceType isEqualToString:@"2"]) {
            LXActionSheet *actionSheet = [[LXActionSheet alloc] initWithTitle:NSLocalizedString(@"call", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:nil otherButtonTitles:@[NSLocalizedString(@"watch_no_d8", nil), NSLocalizedString(@"watch_short_phone_d8", nil)]];
            actionSheet.tag = 5;
            [actionSheet showInView:self.view];
        } else {
            LXActionSheet *actionSheet = [[LXActionSheet alloc] initWithTitle:NSLocalizedString(@"call", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:nil otherButtonTitles:@[NSLocalizedString(@"watch_no", nil), NSLocalizedString(@"watch_short_phone", nil)]];
            actionSheet.tag = 5;
            [actionSheet showInView:self.view];
        }
    }
}
- (void)didClickOnButtonIndex:(NSInteger *)buttonIndex {
    if (buttonIndex == 0) {
        if (deviceModel.PhoneNumber.length == 0) {
            if ([deviceModel.DeviceType isEqualToString:@"2"]) {
                [OMGToast showWithText:NSLocalizedString(@"edit_watch_no_first_d8", nil) bottomOffset:50 duration:3];
            } else {
                [OMGToast showWithText:NSLocalizedString(@"edit_watch_no_first", nil) bottomOffset:50 duration:3];
            }
            return;
        } else {
            [defaults setObject:@"0" forKey:@"telType"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showTelPhone" object:self];
        }
    } else if (buttonIndex == 1) {
        if (deviceModel.PhoneCornet.length == 0) {
            if ([deviceModel.DeviceType isEqualToString:@"2"]) {
                [OMGToast showWithText:NSLocalizedString(@"edit_watch_cornet_first_d8", nil) bottomOffset:50 duration:3];
            } else {
                [OMGToast showWithText:NSLocalizedString(@"edit_watch_cornet_first", nil) bottomOffset:50 duration:3];
            }
            return;
        } else {
            [defaults setObject:@"1" forKey:@"telType"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showTelPhone" object:self];
        }
    }
}

- (IBAction)mapType:(id)sender {
    
    if (mapType == 0) {
        mapType = 1;
        [self.mapTypeBtn setImage:[UIImage imageNamed:@"planar_map"] forState:UIControlStateNormal];
        [self.mapView setMapType:MKMapTypeSatellite];
    } else {
        [self.mapTypeBtn setImage:[UIImage imageNamed:@"satellite_maps"] forState:UIControlStateNormal];
        mapType = 0;
        [self.mapView setMapType:MKMapTypeStandard];
    }
}

- (IBAction)watchPhone:(id)sender {
    second = 60;
    WebService *webService = [WebService newWithWebServiceAction:@"RefreshDeviceState" andDelegate:self];
    webService.tag = 1111;
    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
    WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"deviceId" andValue:deviceModel.DeviceID];
    NSArray *parameter = @[loginParameter1, loginParameter2];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"RefreshDeviceStateResult"];
    self.locationBtn.enabled = NO;
    self.addressLabel.text = NSLocalizedString(@"get_location_b", nil);
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(changeBtnUse) userInfo:nil repeats:NO];
    secondTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(changeSecondLabel) userInfo:nil repeats:YES];
    
}

- (void)changeSecondLabel {
    second--;
    if (second == 0) {
        self.second_label.text = @"";
    } else if (second == 1) {
        if ((locationCar_old.latitude == locationCar.latitude) && (locationCar_old.longitude == locationCar.longitude)) {
            self.addressLabel.text = locationcache.LocationAddress;
            NSLog(@"%@", locationcache.LocationAddress);
        }
    } else {
        self.second_label.text = [NSString stringWithFormat:@"%d", second];
        
    }
    
}

- (void)changeBtnUse {
    self.second_label.text = @"";
    
    self.locationBtn.userInteractionEnabled = YES;
    self.locationBtn.enabled = YES;
    [refreshTimer invalidate];
    [secondTimer invalidate];
}

- (IBAction)findWatch:(id)sender {
    UIAlertView *alerview;
    if ([deviceModel.DeviceType isEqualToString:@"2"]) {
        alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"sure_find_watch_d8", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil), NSLocalizedString(@"OK", nil), nil];
    } else {
        alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"sure_find_watch", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil), NSLocalizedString(@"OK", nil), nil];
    }
    alerview.tag = 12;
    [alerview show];
}

- (IBAction)zoomIn:(id)sender {
    
    if (self.mapView.region.span.latitudeDelta > 60 || self.mapView.region.span.longitudeDelta > 60) {
        return;
    }
    theSpan.latitudeDelta = self.mapView.region.span.latitudeDelta / 2;
    
    theSpan.longitudeDelta = self.mapView.region.span.longitudeDelta / 2;
    
    MKCoordinateRegion theRegion;
    
    theRegion.center = [self.mapView centerCoordinate];
    
    theRegion.span = theSpan;
    
    [self.mapView setRegion:theRegion];
    
    [self getDevieSet];
}

- (IBAction)zoomOut:(id)sender {
    
    if (self.mapView.region.span.latitudeDelta > 60 || self.mapView.region.span.longitudeDelta > 60) {
        return;
    }
    theSpan.latitudeDelta = self.mapView.region.span.latitudeDelta * 2;
    
    theSpan.longitudeDelta = self.mapView.region.span.longitudeDelta * 2;
    
    MKCoordinateRegion theRegion;
    
    theRegion.center = [self.mapView centerCoordinate];
    
    theRegion.span = theSpan;
    
    [self.mapView setRegion:theRegion];
}

- (IBAction)showWatch:(id)sender {
    
    MKCoordinateRegion theRegion;
    
    theRegion.center = locationCar;
    theSpan.latitudeDelta = 0.006;
    //
    theSpan.longitudeDelta = 0.006;
    theRegion.span = theSpan;
    
    [self.mapView setRegion:theRegion];
    isMyLocation = NO;
    [_mapView removeAnnotations:_mapView.annotations];
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    
    annotation.coordinate = locationCar;
    
    [self.mapView addAnnotation:annotation];
    NSLog(@"dddd");
}

#pragma mark - 定位手机地址

- (IBAction)showPhone:(id)sender {
    
    MKCoordinateRegion theRegion;
    
    theRegion.center = myLocation;
    
    theSpan.latitudeDelta = 0.006;
    theSpan.longitudeDelta = 0.006;
    theRegion.span = theSpan;
    
    [self.mapView setRegion:theRegion];
    isMyLocation = YES;
    //[_mapView removeAnnotations:_mapView.annotations];
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    
    annotation.coordinate = myLocation;
    
    //[self.mapView addAnnotation:annotation];
    
    //启动跟踪定位
    [locationManager startUpdatingLocation];
    
    //设置MapView的委托为自己
    isMyLocation_show = YES;
    //[self.mapView setDelegate:self];
    //标注自身位置
    [self.mapView setShowsUserLocation:YES];
}


- (IBAction)showPhoto:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showPhotoView" object:self];
    
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    //放大地图到自身的经纬度位置。
    /*
     if(isMyLocation==NO)
     {
     locationPerson.latitude = [locationModel.Latitude doubleValue];
     locationPerson.longitude = [locationModel.Longitude doubleValue];
     if(locationPerson.latitude!=locationCar.latitude&&locationPerson.longitude!=locationCar.longitude)
     {
     MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(locationCar, 600, 600);
     [self.mapView setRegion:region animated:YES];
     }
     }
     else
     {
     if(isMyLocation_show==YES)
     {
     isMyLocation_show= NO;
     MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(myLocation, 600, 600);
     [self.mapView setRegion:region animated:YES];
     }
     }*/
    
    isMyLocation = YES;
    if ((myLocation_old.latitude != myLocation.latitude) || (myLocation_old.longitude != myLocation.longitude)) {
        myLocation_old = myLocation;
        [_mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(myLocation_old, 600, 600);
        [self.mapView setRegion:region animated:YES];
        
        if ((fabs(myLocation_old.latitude - myLocation.latitude) > 0.1) || (fabs(myLocation_old.longitude - myLocation.longitude) > 0.1)) {
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            [_mapView removeAnnotations:_mapView.annotations];
            
            annotation.coordinate = myLocation_old;
            [self.mapView addAnnotation:annotation];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.mapView removeFromSuperview];
    self.mapView.delegate = nil;
}

- (void)FirstLocation {
    isdoubleBounceTimer = YES;
    
    WebService *webService = [WebService newWithWebServiceAction:@"RefreshDeviceState" andDelegate:self];
    // webService.tag =1111;
    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
    WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"deviceId" andValue:deviceModel.DeviceID];
    NSArray *parameter = @[loginParameter1, loginParameter2];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"RefreshDeviceStateResult"];
}

- (void)checkMainUserPhoneNumber {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if ([CommUtil isBlank:[ud objectForKey:MAIN_USER_PHONE_NUMBER]]&&!IsCheckPhoneNumberDialogShown) {
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:NSLocalizedString(@"prompt_Tip", nil) contentText:NSLocalizedString(@"point_out", nil) leftButtonTitle:NSLocalizedString(@"cancel", nil) rightButtonTitle:NSLocalizedString(@"OK", nil)];
        [alert.xButton removeFromSuperview];
        [alert show];
        alert.leftBlock = ^() {
        };
        
        alert.rightBlock = ^() {
            
            [self showNext];
        };
        alert.dismissBlock = ^() {
        };
        IsCheckPhoneNumberDialogShown=true;
    }else
    {
        
    }
}

- (void)showNext
{
    NSString* BindNumber = [defaults objectForKey:MAIN_USER_BIND_NUMBER];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showNext" object:BindNumber];
}
//
//-(void)animationImageTwo
//{
//    //    [lock lock];
//    //    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
//    //    UIView* view = [[UIView alloc]initWithFrame: [UIScreen mainScreen].bounds];
//    //    self.centerView.alpha = 0;
//    //    self.view.alpha=0;
//    KKSequenceImageView* imageView = [[KKSequenceImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    NSMutableArray* images = [NSMutableArray array];
//    for (int i = 1; i <= 50; i++) {
//        NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"LunchImage_%d",i] ofType:@"png"];
//        if (path.length) {
//            [images addObject:path];
//        }
//    }
//    imageView.imagePathss = images;
//    imageView.durationMS = images.count * 50;
//    imageView.repeatCount = 1;
//    imageView.delegate = self;
//    //        [view addSubview:imageView];
//    [self.view addSubview:imageView];
//    //    [window sendSubviewToBack:imageView];
//    [imageView begin];
//    __weak typeof (self)weakSelf = self;
//    void(^blockee)(int arg1,int arg2);
//    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)((((int)imageView.durationMS)/1000.0)/*延迟执行时间*/ * NSEC_PER_SEC));
//    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
//
//        //        [UIView animateWithDuration:1 animations:^{
//        //
//        ////            imageView.alpha = 0;
//        //        } completion:^(BOOL finished)
//        //        {
//        //        [lock unlock];
//
//        [imageView removeFromSuperview];
//        [self otherOperations];
//        DataManager* data = [DataManager shareInstance];
//        data.isLogin = false;
//        //        }];
//
//    });
//}
-(void)otherOperations
{
    //     self.view.alpha=1;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(turnTimer) name:@"addPhoneNumber" object:nil];
    
    [self.headView.layer setCornerRadius:17.5];
    self.headView.layer.masksToBounds = YES;
    self.headView.layer.borderWidth = 2;
    self.headView.layer.borderColor = [[UIColor whiteColor] CGColor];
    second = 60;
    defaults = [NSUserDefaults standardUserDefaults];
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    isShow = NO;
    isGPS = YES;
    is_D8_show = NO;
    mapType = 0;
    self.addressLabel.text = NSLocalizedString(@"get_location_b", nil);
    deviceArray = [[NSMutableArray alloc] init];
    
    _geocoder = [[CLGeocoder alloc] init];
    locationArray = [[NSMutableArray alloc] init];
    location = [[NSArray alloc] init];
    locationManager = [[CLLocationManager alloc] init];
    [defaults setObject:@"0" forKey:@"addSuccess"];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
    app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    NSArray *arr = [app_Version componentsSeparatedByString:@"."];
    
    ver = [arr[0] intValue] * 10000 + [arr[1] intValue] * 100 + [arr[2] intValue];
    WebService *webService = [WebService newWithWebServiceAction:@"CheckAppVersion" andDelegate:self];
    webService.tag = 100;
    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
    WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"" andValue:[defaults objectForKey:@"LoginId"]];
    NSString *str = [defaults objectForKey:@"PhoneNumber"];
    NSArray *parameter = @[loginParameter1];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"CheckAppVersionResult"];
    
    manage = [DataManager shareInstance];
    
    deviceArray = [manage getAllFavourie];
    
    deviceArray = [manage isSelect:[defaults objectForKey:@"binnumber"]];
    if (deviceArray.count == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"poptoroot" object:self];
        [timer invalidate];
    } else {
        deviceModel = deviceArray[0];
    }
    
    locationArray = [manage isSelectLocationTable:deviceModel.DeviceID];
    
    if (locationArray.count != 0) {
        locationModel = locationArray[0];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"poptoroot" object:self];
    }
    
    self.mapView.delegate = self;
    
    if ([deviceModel.BabyName isEqualToString:@""]) {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        self.nameLabel.text = NSLocalizedString(@"app_name", nil);
    } else {
        self.nameLabel.text = deviceModel.BabyName;
    }
    
    if ([deviceModel.Photo isEqualToString:@""]) {
        self.headView.layer.contents = (id) [[UIImage imageNamed:@"user_head_normal"] CGImage];
    } else {
        [self.headView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:HTTPS, PHOTO, deviceModel.Photo]]];
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
        self.mapView.showsScale = YES;
    }
    
    [self getLocation];
    [self FirstLocation];
    
    locationcacheArray = [[NSMutableArray alloc] init];
    locationcacheArray = [manage isSelectLocationCacheWithDeviceID:deviceModel.DeviceID];
    if (locationcacheArray.count >= 1) {
        locationcache = locationcacheArray[0];
        locationcache_lately = locationcacheArray[locationcacheArray.count - 1];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"poptoroot" object:self];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ChangeHead) name:@"changeHeadImage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getContant) name:@"refreshBook" object:nil];
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(checkNotificationThread) object:nil];
    [thread start];
    NSThread *checkMainThread = [[NSThread alloc]initWithTarget:self selector:@selector(checkMainUserPhoneNumber) object:nil];
    [checkMainThread start];
    if (version >= 7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [locationManager requestWhenInUseAuthorization];  //调用了这句,就会弹出允许框了.
        
    }
    
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"定位服务当前可能尚未打开，请设置打开！");
        return;
    }
    locationManager.delegate = self;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {    //如果没有授权则请求用户授权
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            [locationManager requestWhenInUseAuthorization];
        } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
            
        }
    }
    
    //设置代理
    locationManager.delegate = self;
    //设置定位精度
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    //定位频率,每隔多少米定位一次
    CLLocationDistance distance = 10.0;//十米定位一次
    locationManager.distanceFilter = distance;
    //启动跟踪定位
    [locationManager startUpdatingLocation];
    //设置MapView的委托为自己
    [self.mapView setDelegate:self];
    //标注自身位置
    [self.mapView setShowsUserLocation:YES];
    
    //地图
    [self.mapView setZoomEnabled:YES];
    [self.mapView setScrollEnabled:YES];
    
    self.second_label.text = @"";
    self.shouhu_label.text = NSLocalizedString(@"school_defend", nil);
    self.weilliao_Label.text = NSLocalizedString(@"chat", nil);
    
    if (deviceModel.CurrentFirmware.length == 0) {
        deviceModel.CurrentFirmware = @"00000000";
    }
    
    if (([deviceModel.CurrentFirmware rangeOfString:@"D10_CHUANGMT"].location != NSNotFound) || ([deviceModel.CurrentFirmware rangeOfString:@"D9_CHUANGMT"].location != NSNotFound) || ([deviceModel.CurrentFirmware rangeOfString:@"D9_TP_CHUANGMT"].location != NSNotFound) || ([deviceModel.CurrentFirmware rangeOfString:@"D12_CHUANGMT"].location != NSNotFound)) {
        isGPS = NO;
    } else {
        isGPS = YES;
    }
    
    if (([deviceModel.DeviceType isEqualToString:@"2"]) || ([deviceModel.CurrentFirmware rangeOfString:@"D8_CH"].location != NSNotFound)) {
        is_D8_show = YES;
        self.weilliao_Label.hidden = YES;
        self.shouhu_label.hidden = YES;
        self.shouhuBtn.hidden = YES;
        self.audioBtn.hidden = YES;
        self.cirbgImage.hidden = YES;
        [defaults setInteger:1 forKey:@"deviceModelType"];
    } else {
        is_D8_show = NO;
        self.weilliao_Label.hidden = NO;
        self.shouhu_label.hidden = NO;
        self.shouhuBtn.hidden = NO;
        self.audioBtn.hidden = NO;
        self.cirbgImage.hidden = NO;
        [defaults setInteger:0 forKey:@"deviceModelType"];
    }
    
    if (locationCar_old.latitude == 0 && locationCar_old.longitude == 0) {
        locationCar_old.latitude = 39.908692;
        locationCar_old.longitude = 116.397477;
    }
    
    
}

- (void)requestLocationNotification
{
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = @"消息通知";
    //    content.subtitle = @"提醒";
    content.body = @"您有一条未读信息!";
    content.badge = @1;
    //    content.sound = @"苹果短信提示音.caf";
    [self playSoundEffect:@"水滴.wav"];
    /*触发模式1*/
    UNTimeIntervalNotificationTrigger *trigger1 = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
    // 创建本地通知
    NSString *requestIdentifer = @"TestRequestww1";
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifer content:content trigger:trigger1];
    
    //把通知加到UNUserNotificationCenter, 到指定触发点会被触发
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error)
     {
         NSLog(@"点击了~");
     }];
    
}
-(void)requestLocationNotification1
{
    /*
     ios8以上版本需要在appdelegate中注册申请权限 本地通知在软件杀死状态也可以接收到消息
     */
    
    // 1.创建本地通知
    UILocalNotification *localNote = [[UILocalNotification alloc] init];
    // 2.设置本地通知(发送的时间和内容是必须设置的)
    localNote.fireDate = [NSDate dateWithTimeIntervalSinceNow:3.0];
    localNote.alertBody = @"吃饭了么?";
    localNote.soundName = @"苹果短信提示音.caf";
    /**
     其他属性: timeZone 时区
     repeatInterval 多长时间重复一次:一年,一个世纪,一天..
     region 区域 : 传入中心点和半径就可以设置一个区域 (如果进入这个区域或者出来这个区域就发出一个通知)
     regionTriggersOnce  BOOL 默认为YES, 如果进入这个区域或者出来这个区域 只会发出 一次 通知,以后就不发送了
     alertAction: 设置锁屏状态下本地通知下面的 滑动来 ...字样  默认为滑动来查看
     hasAction: alertAction的属性是否生效
     alertLaunchImage: 点击通知进入app的过程中显示图片,随便写,如果设置了(不管设置的是什么),都会加载app默认的启动图
     alertTitle: 以前项目名称所在的位置的文字: 不设置显示项目名称, 在通知内容上方
     soundName: 有通知时的音效 UILocalNotificationDefaultSoundName默认声音
     可以更改这个声音: 只要将音效导入到工程中,localNote.soundName = @"nihao.waw"
     */
    
    
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        localNote.alertAction = @"快点啊"; // 锁屏状态下显示: 滑动来快点啊
        //    localNote.alertLaunchImage = @"123";
        localNote.alertTitle = @"东方_未明";
        localNote.soundName = UILocalNotificationDefaultSoundName;
        //    localNote.soundName = @"nihao.waw";
        
        /* 这里接到本地通知,badge变为5, 如果打开app,消除掉badge, 则在appdelegate中实现
         [application setApplicationIconBadgeNumber:0];
         */
        localNote.applicationIconBadgeNumber = 5;
        
        // 设置额外信息,appdelegate中收到通知,可以根据不同的通知的额外信息确定跳转到不同的界面
        localNote.userInfo = @{@"type":@1};
        
        // 3.调用通知
        //[UIApplication sharedApplication];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNote];
        
    });
    
    
    
    //    作者：东方_未明
    //    链接：http://www.jianshu.com/p/25b5397769f3
    //    來源：简书
    //    著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
}
-(void)playSoundEffect:(NSString *)name{
    NSString *audioFile=[[NSBundle mainBundle] pathForResource:name ofType:nil];
    NSURL *fileUrl=[NSURL fileURLWithPath:audioFile];
    //1.获得系统声音ID
    SystemSoundID soundID=0;
    /**
     * inFileUrl:音频文件url
     * outSystemSoundID:声音id（此函数会将音效文件加入到系统音频服务中并返回一个长整形ID）
     */
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);
    //如果需要在播放完之后执行某些操作，可以调用如下方法注册一个播放完成回调函数
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallback, NULL);
    //2.播放音频
    AudioServicesPlaySystemSound(soundID);//播放音效
    //    AudioServicesPlayAlertSound(soundID);//播放音效并震动
}
void soundCompleteCallback(SystemSoundID soundID,void * clientData){
    NSLog(@"播放完成...");
}
@end
