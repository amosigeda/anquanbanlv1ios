//
//  AppDelegate.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import <UserNotifications/UserNotifications.h>

#import "AppDelegate.h"
#import "WWSideslipViewController.h"
#import "LeftViewController.h"
#import "RightViewController.h"
#import "CenterViewController.h"
#import "LoginViewController.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "OMGToast.h"
#import "EditHeadAndNameViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "MPNotificationView.h"
#import "DataManager.h"
#import "DeviceModel.h"
#import "MyUncaughtExceptionHandler.h"
#import "UserModel.h"
#import "Masonry.h"
#import "UIImage+GIF.h"
#import "KKSequenceImageView.h"
#import "HomeTabViewController.h"
#import "MeTabViewController.h"
#import "FindTabViewController.h"
#import "ZJTPrefixHeader.pch"
#import "HMAD/HMAD.h"
//#import <adsdk/SDKEntry.h>
#import <CloudPushSDK/CloudPushSDK.h>
#import <Bugly/Bugly.h>
#import "DubbingRootViewController.h"

@interface AppDelegate ()<WebServiceProtocol,UIAlertViewDelegate,KKSequenceImageDelegate,UNUserNotificationCenterDelegate>
{
    NSUserDefaults *defaults;
    UINavigationController *nav;
    DataManager *manager;
    DeviceModel *deviceModel;
}
@property(nonatomic,strong)UIView *lunchView;
@property(nonatomic,strong)KKSequenceImageView* imageView;
@end

@implementation AppDelegate
{
@private NSDate * leaveTime;
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    @try {
        //注册bugly
        [Bugly startWithAppId:@"e9b58ca958"];
        /*注册HM广告SDK */
        HMAD *hmAd = [HMAD regWithAppId:@"hmMElubSU2MbT6Rvw0" secretKey:@"54e71b92344189ee2ef0f33079620bd0"];
        //[SDKEntry init:nil];
    } @catch (NSException *exception) {
        NSLog(@"---------------%@-",exception);
    }
    
    self.application=application;
    self.launchOptions=launchOptions;
    
    /** 20190324 **/
     
    [self initCloudPush];
    [CloudPushSDK sendNotificationAck:launchOptions];
    [self registerMessageReceive];
    //---------------
    manager = [DataManager shareInstance];
    defaults = [NSUserDefaults standardUserDefaults];
    [self.window makeKeyAndVisible];
    //     解析成json数据
    //启动viewcontroller放在其闪屏页后面
    //[self otherOperations:application and:launchOptions];
    /**20190324 这个迁移到下面来**/
    [self ReceiveRemoteNotification:application didFinishLaunchingWithOptions:launchOptions];
   
    
    
    
    //    NSLock* lock = [[NSLock alloc]init];
    ////    [lock lock];
    ////    [self lauchScreenImageName:@"comm_bg"];
    ////    [self animationImageTwo];
    //
    //        [lock lock];
    //    KKSequenceImageView* imageView = [[KKSequenceImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    //    NSMutableArray* images = [NSMutableArray array];
    //    for (int i = 1; i <= 45; i++) {
    //        NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"LunchImage_%d",i] ofType:@"png"];
    //        if (path.length) {
    //            [images addObject:path];
    //        }
    //    }
    //    imageView.imagePathss = images;
    //    imageView.durationMS = images.count * 50;
    //    imageView.repeatCount = 1;
    //    imageView.delegate = self;
    //    //        [_lunchView addSubview:_imageView];
    //    [self.window addSubview:imageView];
    //    [imageView begin];
    //    [lock unlock];
    //
    //    __weak typeof (self)weakSelf = self;
    //
    //    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(((((int)imageView.durationMS)/1000.0)-0.2)/*延迟执行时间*/ * NSEC_PER_SEC));
    //    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
    ////
    ////                [UIView animateWithDuration:1 animations:^{
    ////
    ////                    imageView.alpha = 0;
    ////                } completion:^(BOOL finished)
    ////                {
    ////
    ////                }];
    //        [imageView removeFromSuperview];
    ////        [weakSelf otherOperations:application and:launchOptions];
    //        //        [lock unlock];
    //
    //
    //
    //
    //        //        }];
    //
    //    });
    
    //    UIView* View =
    //    _lunchView = [[UIView alloc]init];
    //    _lunchView.frame = CGRectMake(0, 0, self.window.screen.bounds.size.width, self.window.screen.bounds.size.height);
    //    [_window addSubview:_lunchView];
    //    _imageView = [[KKSequenceImageView alloc] initWithFrame:CGRectMake(0, 0, self.window.screen.bounds.size.width,self.window.screen.bounds.size.height)];
    //    NSMutableArray* images = [NSMutableArray array];
    //    [self.window bringSubviewToFront:_lunchView];
    //    //    _imageView.image = [UIImage sd_animatedGIFNamed:@"树林"];
    //    for (int i = 1; i <= 50; i++) {
    //        NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"LunchImage_%d",i] ofType:@"png"];
    //        if (path.length) {
    //            [images addObject:path];
    //        }
    //    }
    //    _imageView.imagePathss = images;
    //    _imageView.durationMS = images.count * 40;
    //    _imageView.repeatCount = 1;
    //    _imageView.delegate = self;
    //    [_lunchView addSubview:_imageView];
    //    [_imageView begin];
    
    
    
    
    
    [self loadRootViewController];
    
    return YES;
}



-(void)rootWindows{
    NSLog(@"---闪屏页面后最开始页面---");
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //UIViewController *viewcontroller = [storyboard instantiateViewControllerWithIdentifier:@"Tabbar"];
    //self.window.rootViewController=viewcontroller;
    //[self.window makeKeyAndVisible];
    
    [self otherOperations:self.application and:self.launchOptions];
}


//初始化根目录
- (void)loadRootViewController{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    self.window.rootViewController=[[DubbingRootViewController  alloc] init];
}


- (void)initCloudPush {
    // SDK初始化
    [CloudPushSDK asyncInit:@"25809649" appSecret:@"09e939abb4f32d9f19754932ebd5fcaf" callback:^(CloudPushCallbackResult *res) {
        if (res.success) {
            NSLog(@"Push SDK init success, deviceId: %@.", [CloudPushSDK getDeviceId]);
        } else {
            NSLog(@"Push SDK init failed, error: %@", res.error);
        }
    }];
}

/**
 *    注册苹果推送，获取deviceToken用于推送
 *
 *    @param     application
 */
- (void)registerAPNS:(UIApplication *)application {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:
         [UIUserNotificationSettings settingsForTypes:
          (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge)
                                           categories:nil]];
        [application registerForRemoteNotifications];
    }
    else {
        // iOS < 8 Notifications
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    }
}

/**
 *    注册推送消息到来监听
 */
- (void)registerMessageReceive {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessageReceived:) name:@"CCPDidReceiveMessageNotification" object:nil];
}

/**
 *    处理到来推送消息
 *
 *    @param     notification
 */
- (void)onMessageReceived:(NSNotification *)notification {
    CCPSysMessage *message = [notification object];
    NSString *title = [[NSString alloc] initWithData:message.title encoding:NSUTF8StringEncoding];
    NSString *body = [[NSString alloc] initWithData:message.body encoding:NSUTF8StringEncoding];
    NSLog(@"Receive message title: %@, content: %@.", title, body);
    if(body.length){
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        // 解析成json数据
        id object = [parser objectWithString:body error:&error];
        if (!error && object) {
            // 获得状态
            int code = [[object objectForKey:@"Code"] intValue];
            if (code == 1) {
                manager =[DataManager shareInstance];
                NSArray *array = [manager isSelect:[defaults objectForKey:@"binnumber"]];
                if(array == nil || array.count < 1){
                    return;
                }
                deviceModel = [manager isSelect:[defaults objectForKey:@"binnumber"]][0];
                
                dispatch_sync(dispatch_get_main_queue(), ^{//其实这个也是在子线程中执行的，只是把它放到了主线程的队列中
                    [UIApplication sharedApplication].applicationIconBadgeNumber = [[object objectForKey:@"New"] intValue];
                });
                
                //语音----------------------------------------------------------------------
                NSArray *NewList = [object objectForKey:@"NewList"];
                for (int i = 0; i < NewList.count; i++) {
                    if ([[[NewList objectAtIndex:i] objectForKey:@"DeviceID"] isEqualToString:deviceModel.DeviceID]) {
                        int Voice1 = [[[NewList objectAtIndex:i] objectForKey:@"Voice"] intValue];
                        if (Voice1 > 0) {
//                            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshIIIIII" object:self];
                            
                            if ([deviceModel.DeviceType isEqualToString:@"1"]) {
                                [self requestLocationNotification];
                            }
                        }
                        
                        //小红点
                        if ([[[NewList objectAtIndex:i] objectForKey:@"Message"] intValue] > 0
                            || [[[NewList objectAtIndex:i] objectForKey:@"SMS"] intValue] > 0) {
                            if ([[[NewList objectAtIndex:i] objectForKey:@"Message"] intValue] > 0) {
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage" object:[[NewList objectAtIndex:i] objectForKey:@"Message"]];
                            }
                            if ([[[NewList objectAtIndex:i] objectForKey:@"SMS"] intValue] > 0) {
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshSMS" object:[[NewList objectAtIndex:i] objectForKey:@"SMS"]];
                            }
                        }
                        if ([[[NewList objectAtIndex:i] objectForKey:@"Photo"] intValue] > 0) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPhoto" object:self];
                        }
                    }
                }
                //位置----------------------------------------------------------------------
                NSArray *location = [object objectForKey:@"DeviceState"];
                if (location.count > 0) {
                    for (int i = 0; i < location.count; i++) {
                        if ([[[location objectAtIndex:i] objectForKey:@"DeviceID"] isEqualToString:deviceModel.DeviceID]) {
                            dispatch_queue_t queue = dispatch_queue_create("name", NULL);
                            //创建一个子线程
                            dispatch_async(queue, ^{
                                // 子线程code... ..
                                [manager deleteLocationWithDeviceID:deviceModel.DeviceID];
                                
                                if (location.count != 0) {
                                    
                                    [manager addLocationDeviceID:deviceModel.DeviceID andAltitude:[[location objectAtIndex:i] objectForKey:@"Altitude"] andCourse:[[location objectAtIndex:i] objectForKey:@"Course"] andLocationType:[[location objectAtIndex:i] objectForKey:@"LocationType"] andCreateTime:[[location objectAtIndex:i] objectForKey:@"DeviceTime"] andElectricity:[[location objectAtIndex:i] objectForKey:@"Electricity"] andGSM:[[location objectAtIndex:i] objectForKey:@"GSM"] andStep:[[location objectAtIndex:i] objectForKey:@"Step"] andHealth:[[location objectAtIndex:i] objectForKey:@"Health"] andLatitude:[[location objectAtIndex:i] objectForKey:@"Latitude"] andLongitude:[[location objectAtIndex:i] objectForKey:@"Longitude"] andOnline:[[location objectAtIndex:i] objectForKey:@"Online"] andSatelliteNumber:[[location objectAtIndex:i] objectForKey:@"SatelliteNumber"] andServerTime:[[location objectAtIndex:i] objectForKey:@"ServerTime"] andSpeed:[[location objectAtIndex:i] objectForKey:@"Speed"] andUpdateTime:nil andDeviceTime:[[location objectAtIndex:i] objectForKey:@"DeviceTime"]];
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
                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshLocation" object:self];
                                            
                                        }
                                    }
                                });
                            });
                        }
                    }
                }
                
                
                NSArray *notification = [object objectForKey:@"Notification"];
                if (notification.count > 0) {
                    for (int i = 0; i < notification.count; i++) {
                        if ([[[notification objectAtIndex:i] objectForKey:@"Type"] intValue] == 230) {
                            [defaults setObject:[[notification objectAtIndex:i] objectForKey:@"DeviceID"] forKey:@"NODeviceID"];
                        } else if ([[[notification objectAtIndex:i] objectForKey:@"Type"] intValue] == 231) {
                            [defaults setObject:[[notification objectAtIndex:i] objectForKey:@"DeviceID"] forKey:@"NODeviceID"];
                        } else if ([[[notification objectAtIndex:i] objectForKey:@"Type"] intValue] == 232) {
                            [defaults setObject:[[notification objectAtIndex:i] objectForKey:@"DeviceID"] forKey:@"NODeviceID"];
                            if ([[defaults objectForKey:@"addSuccess"] intValue] == 1) {
                                [defaults setObject:@"0" forKey:@"addSuccess"];
                            }
                        } else if ([[[notification objectAtIndex:i] objectForKey:@"Type"] intValue] == 2) {
                            if ([[defaults objectForKey:@"Type2"] intValue] == 1) {
                                NSArray *arr = [[[notification objectAtIndex:i] objectForKey:@"Content"] componentsSeparatedByString:@","];
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:[[notification objectAtIndex:i] objectForKey:@"Message"] delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
                                
                                alert.tag = 102;
                                [alert show];
                                
                                [defaults setObject:[[notification objectAtIndex:i] objectForKey:@"DeviceID"] forKey:@"NODeviceID"];
                                [defaults setObject:[arr objectAtIndex:0] forKey:@"NOUseID"];
                                
                                [manager addContactTable:[defaults objectForKey:@"binnumber"] andDeviceContactId:@"100000000" andRelationship:[arr objectAtIndex:1] andPhoto:@"8" andPhoneNumber:NSLocalizedString(@"to_agree_with_associated_equipment", nil) andPhoneShort:nil andType:nil andObjectId:nil andHeadImg:nil];
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
                            }
                        }else if ([[notification[i] objectForKey:@"Type"] intValue] == 1) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshIIIIII" object:self];
//                            NSArray *array = [object objectForKey:@"VoiceList"];
//
//                            for(int i = 0; i < array.count;i++){
//                                [manager addAudioWithDeviceVoiceId:[[array objectAtIndex:i] objectForKey:@"DeviceVoiceId"] andDeviceID:[[array objectAtIndex:i] objectForKey:@"DeviceID"] andState:[[array objectAtIndex:i] objectForKey:@"State"] andType:[[array objectAtIndex:i] objectForKey:@"Type"] andObjectId:[[array objectAtIndex:i] objectForKey:@"ObjectId"]  andMark:[[array objectAtIndex:i] objectForKey:@"Mark"] andPath:[[array objectAtIndex:i] objectForKey:@"Path"]  andLength:[[array objectAtIndex:i] objectForKey:@"Length"]  andMsgType:[[array objectAtIndex:i] objectForKey:@"MsgType"] andCreateTime:[[array objectAtIndex:i] objectForKey:@"CreateTime"] andUpdateTime:[[array objectAtIndex:i] objectForKey:@"UpdateTime"]];
//                            }
                        }
                    }
                }
            }
        }
    }
}

- (void)sequenceImageDidPlayCompeletion:(KKSequenceImageView *)imageView{
    [_lunchView removeFromSuperview];
    _imageView = nil;
}

//- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
//{
//    //register to receive notifications
////    [application registerForRemoteNotifications];
//}
//
//
//- (void)applicationDidBecomeActive:(UIApplication *)application
//{
//    NSLog(@"AppDelegate.applicationDidBecomeActive");
//}
//
//- (void)applicationWillTerminate:(UIApplication *)application
//{
//    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//}
//
////NSString *deviceTokenStr_test;
//
//- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)pToken {
//    NSString *deviceTokenStr = [NSString stringWithFormat:@"%@",pToken];
//    defaults = [NSUserDefaults standardUserDefaults];
//
//    //modify the token, remove the  "<, >"
//    NSLog(@"    deviceTokenStr  lentgh:  %lu  ->%@", (unsigned long)[deviceTokenStr length], [[deviceTokenStr substringWithRange:NSMakeRange(0, 72)] substringWithRange:NSMakeRange(1, 71)]);
//    deviceTokenStr = [[deviceTokenStr substringWithRange:NSMakeRange(0, 72)] substringWithRange:NSMakeRange(1, 71)];
//
//    NSLog(@"deviceTokenStr = %@",deviceTokenStr);
//
//    //deviceTokenStr_test=deviceTokenStr;
//
//    [[NSUserDefaults standardUserDefaults] setObject:deviceTokenStr forKey:@"pToken"];
//    [[NSUserDefaults standardUserDefaults]  synchronize];
//    //注册成功，将deviceToken保存到应用服务器数据库中
//
//}
//
//- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
//    NSString *error_str = [NSString stringWithFormat: @"%@", error];
//    NSLog(@"Failed to get token, error:%@", error_str);
//}
//
////- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
////    NSLog(@"%@", userInfo);
////    defaults = [NSUserDefaults standardUserDefaults];
////
////    NSString *message = [userInfo[@"aps"] objectForKey:@"alert"];
////
////    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:message delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil),nil];
////
////    [alert show];
////}
//
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;
//{
//    defaults = [NSUserDefaults standardUserDefaults];
//
//    NSLog(@"this is iOS7 Remote Notification");
//
//    NSArray *array = userInfo[@"Content"];
//
//    [defaults setObject:array[0] forKey:@"NoType"];
//    [defaults setObject:array[1] forKey:@"NODeviceID"];
//
//    NSLog(@"%@", userInfo);
//    SBJsonParser *parser = [[SBJsonParser alloc] init];
//    NSError *error = nil;
//
//    manager =[DataManager shareInstance];
//    deviceModel = [manager isSelect:[defaults objectForKey:@"binnumber"]][0];
//
//    // 解析成json数据
//
//    if( [[defaults objectForKey:@"NotificationVibration"] intValue] == 1)
//    {
//        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
//
//    }
//    if([[defaults objectForKey:@"NotificationSound"] intValue] == 1)
//    {
//        AudioServicesPlaySystemSound(1007);
//    }
//
//    NSString *message = [userInfo[@"aps"] objectForKey:@"alert"];
//
//    [MPNotificationView notifyWithText:@"酷宝贝"
//                                detail:message
//                                 image:[UIImage imageNamed:@"icon"]
//                           andDuration:3.0];
//
//     if([[defaults objectForKey:@"NoType"] intValue] == 2)
//     {
//         [defaults setObject:@"0" forKey:@"Type2"];
//
//         NSArray *arr =  [array[2] componentsSeparatedByString:@","];
//         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:message delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil),nil];
//
//         alert.tag = 2;
//         [alert show];
//
//         [defaults setObject:array[1] forKey:@"NODeviceID"];
//         [defaults setObject:[array[2] componentsSeparatedByString:@","][0] forKey:@"NOUseID"];
//
//         [manager addContactTable:[defaults objectForKey:@"binnumber"] andDeviceContactId:@"100000000" andRelationship:[array[2] componentsSeparatedByString:@","][1] andPhoto:@"8" andPhoneNumber:NSLocalizedString(@"to_agree_with_associated_equipment", nil) andPhoneShort:nil andType:nil andObjectId:nil andHeadImg:nil];
//    }
//    else if ([[defaults objectForKey:@"NoType"] intValue] == 9)
//    {
//        if([array[1] intValue] == deviceModel.DeviceID.intValue)
//        {
//            [defaults setObject:@"" forKey:@"binnumber"];
//            [defaults setObject:@"0" forKey:@"DMloginScaleKey"];
//
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"poptoroot" object:self];
//        }
//        [defaults setObject:@"0" forKey:@"Type9"];
//    }
//
//    else if ([[defaults objectForKey:@"NoType"] intValue] == 3)
//    {
//        [defaults setObject:array[1] forKey:@"selectDeviceID"];
//
//        WebService *webService = [WebService newWithWebServiceAction:@"GetDeviceList" andDelegate:self];
//        webService.tag = 4;
//        WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
//
//        NSArray *parameter = @[loginParameter1];
//        // webservice请求并获得结果
//        webService.webServiceParameter = parameter;
//        [webService getWebServiceResult:@"GetDeviceListResult"];
//        [defaults setObject:@"0" forKey:@"Type3"];
//
//    }
//
//    application.applicationIconBadgeNumber = [[userInfo[@"aps"] objectForKey:@"badge"] integerValue];
//    // Required
//    completionHandler(UIBackgroundFetchResultNoData);
//}

- (void)WebServiceGetCompleted:(id)theWebService
{
    WebService *ws = theWebService;
    
    if ([[theWebService soapResults] length] > 0) {
        
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        // 解析成json数据
        id object = [parser objectWithString:[theWebService soapResults] error:&error];
        
        if (!error && object) {
            // 获得状态
            int code = [[object objectForKey:@"Code"] intValue];
            
            if(code == 1)
            {
                //同意绑定后 刷新宝贝数据
                if (ws.tag == 4)
                {
                    NSArray *ar = [object objectForKey:@"deviceList"];
                    for(int i = 0; i < ar.count;i++)
                    {
                        if([[[ar objectAtIndex:i] objectForKey:@"DeviceID"] intValue] == [[defaults objectForKey:@"selectDeviceID"] intValue])
                        {
                            NSDictionary *dic = [ar objectAtIndex:i];
#pragma mark - 写入设备信息表
                            [manager addFavourite:[dic objectForKey:@"ActiveDate"]
                                      andBabyName:[dic objectForKey:@"BabyName"] andBindNumber:[dic objectForKey:@"BindNumber"] andDeviceType:[dic objectForKey:@"DeviceType"] andBirthday:[dic objectForKey:@"Birthday"] andCreateTime:[dic objectForKey:@"CreateTime"] andCurrentFirmware:[dic objectForKey:@"CurrentFirmware"] andDeviceID:[dic objectForKey:@"DeviceID"] andDeviceModelID:[dic objectForKey:@"DeviceModelID"] andFirmware:[dic objectForKey:@"Firmware"] andGender:[dic objectForKey:@"Gender"] andGrade:[dic objectForKey:@"Grade"] andHireExpireDate:[dic objectForKey:@"HireExpireDate"] andDate:[dic objectForKey:@"Date"] andHomeAddress:[dic objectForKey:@"HomeAddress"] andHomeLat:[dic objectForKey:@"HomeLat"] andHomeLng:[dic objectForKey:@"HomeLng"] andIsGuard:[dic objectForKey:@"IsGuard"] andPassword:[dic objectForKey:@"Password"] andPhoneCornet:[dic objectForKey:@"PhoneCornet"] andPhoneNumber:[dic objectForKey:@"PhoneNumber"] andPhoto:[dic objectForKey:@"Photo"] andSchoolAddress:[dic objectForKey:@"SchoolAddress"] andSchoolLat:[dic objectForKey:@"SchoolLat"] andSchoolLng:[dic objectForKey:@"SchoolLng"] andSerialNumber:[dic objectForKey:@"SerialNumber"] andUpdateTime:[dic objectForKey:@"UpdateTime"] andUserId:[dic objectForKey:@"UserId"] andSetVersionNO:[dic objectForKey:@"SetVersionNO"]  andContactVersionNO:[dic objectForKey:@"ContactVersionNO"]  andOperatorType:[dic objectForKey:@"OperatorType"]  andSmsNumber:[dic objectForKey:@"SmsNumber"]  andSmsBalanceKey:[dic objectForKey:@"SmsBalanceKey"]  andSmsFlowKey:[dic objectForKey:@"SmsFlowKey"] andLatestTime:[dic objectForKey:@"LatestTime"]];
                            
#pragma mark - 写入设备设置表
                            
                            NSDictionary *set = [dic objectForKey:@"DeviceSet"];
                            NSArray *setInfo = [[set objectForKey:@"SetInfo"] componentsSeparatedByString:@"-"];
                            
                            NSArray * classStar = [[set objectForKey:@"ClassDisabled1"] componentsSeparatedByString:@"-"];
                            
                            
                            NSArray * classStop = [[set objectForKey:@"ClassDisabled2"] componentsSeparatedByString:@"-"];
                            
                            [manager addDeviceSetTable:[dic objectForKey:@"BindNumber"]  andVersionNumber:nil andAutoAnswer:[setInfo objectAtIndex:11]  andReportCallsPosition:[setInfo objectAtIndex:10] andBodyFeelingAnswer:[setInfo objectAtIndex:9] andExtendEmergencyPower:[setInfo objectAtIndex:8] andClassDisable:[setInfo objectAtIndex:7] andTimeSwitchMachine:[setInfo objectAtIndex:6] andRefusedStrangerCalls:[setInfo objectAtIndex:5] andWatchOffAlarm:[setInfo objectAtIndex:4] andWatchCallVoice:[setInfo objectAtIndex:3] andWatchCallVibrate:[setInfo objectAtIndex:2] andWatchInformationSound:[setInfo objectAtIndex:1] andWatchInformationShock:[setInfo objectAtIndex:0] andClassDisabled1:[classStar objectAtIndex:0] andClassDisabled2:[classStar objectAtIndex:1] andClassDisabled3:[classStop objectAtIndex:0] andClassDisabled4:[classStop objectAtIndex:1] andWeekDisabled:[set objectForKey:@"WeekDisabled"] andTimerOpen:[set objectForKey:@"TimerOpen"] andTimerClose:[set objectForKey:@"TimerClose"] andBrightScreen:[set objectForKey:@"BrightScreen"]  andweekAlarm1:[set objectForKey:@"WeekAlarm1"] andweekAlarm2:[set objectForKey:@"WeekAlarm2"] andweekAlarm3:[set objectForKey:@"WeekAlarm3"] andalarm1:[set objectForKey:@"Alarm1"] andalarm2:[set objectForKey:@"Alarm2"] andalarm3:[set objectForKey:@"Alarm3"] andlocationMode:[set objectForKey:@"LocationMode"] andlocationTime:[set objectForKey:@"LocationTime"] andflowerNumber:[set objectForKey:@"FlowerNumber"] andStepCalculate:[set objectForKey:@"StepCalculate"] andSleepCalculate:[set objectForKey:@"SleepCalculate"] andHrCalculate:[set objectForKey:@"HrCalculate"] andSosMsgswitch:[set objectForKey:@"SosMsgswitch"] andTimeZone:@"" andLanguage:@"" andDialPad:@"0"];
                            
#pragma mark - 写入联系人表
                            
                            NSArray *contact = [dic objectForKey:@"ContactArr"];
                            for(int i = 0; i < contact.count;i++)
                            {
                                NSDictionary *con = [contact objectAtIndex:i];
                                
                                [manager addContactTable:[dic objectForKey:@"BindNumber"] andDeviceContactId:[con objectForKey:@"DeviceContactId"] andRelationship:[con objectForKey:@"Relationship"] andPhoto:[con objectForKey:@"Photo"] andPhoneNumber:[con objectForKey:@"PhoneNumber"] andPhoneShort:[con objectForKey:@"PhoneShort"] andType:[con objectForKey:@"Type"] andObjectId:[con objectForKey:@"ObjectId"] andHeadImg:[con objectForKey:@"HeadImg"]];
                            }
                            
#pragma mark - 写入位置表
                            NSDictionary *locations = [dic objectForKey:@"DeviceState"];
                            [manager addLocationDeviceID:[dic objectForKey:@"DeviceID"] andAltitude:[locations objectForKey:@"Altitude"] andCourse:[locations objectForKey:@"Course"] andLocationType:[locations objectForKey:@"LocationType"] andCreateTime:[locations objectForKey:@"CreateTime"] andElectricity:[locations objectForKey:@"Electricity"] andGSM:[locations objectForKey:@"GSM"] andStep:[locations objectForKey:@"Step"] andHealth:[locations objectForKey:@"Health"] andLatitude:[locations objectForKey:@"Latitude"] andLongitude:[locations objectForKey:@"Longitude"] andOnline:[locations objectForKey:@"Online"] andSatelliteNumber:[locations objectForKey:@"SatelliteNumber"] andServerTime:[locations objectForKey:@"ServerTime"] andSpeed:[locations objectForKey:@"Speed"] andUpdateTime:[locations objectForKey:@"UpdateTime"] andDeviceTime:[locations objectForKey:@"DeviceTime"]];
                        }
                        
                    }
                    deviceModel  =  [[manager isSelectFaWithDevice:[defaults objectForKey:@"selectDeviceID"]] objectAtIndex:0];
                    
                    [defaults setObject:deviceModel.BindNumber forKey:@"binnumber"];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeHeadImage" object:self];
                    
                }
            }
        }
    }
}

- (void)requestLocationNotification{
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
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallback2, NULL);
    //2.播放音频
    AudioServicesPlaySystemSound(soundID);//播放音效
    //    AudioServicesPlayAlertSound(soundID);//播放音效并震动
}

void soundCompleteCallback2(SystemSoundID soundID,void * clientData){
    NSLog(@"播放完成...");
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        if(alertView.tag == 2)
        {
            EditHeadAndNameViewController *vc = [[EditHeadAndNameViewController alloc] init];
            [defaults setInteger:4 forKey:@"editWatch"];
            [nav pushViewController:vc animated:YES];
            
        }
        else if (alertView.tag == 3)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshDevice" object:self];
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

-(void)otherOperations:(UIApplication *)application and:(NSDictionary *)launchOptions
{
    //    [NSThread sleepForTimeInterval:0.5];
    //    [_window makeKeyAndVisible];
    
    
    //    [_splashView mas_makeConstraints:^(MASConstraintMaker *make)
    //    {
    //        make.top.equalTo(_window);
    //        make.left.equalTo(_window);
    //        make.right.equalTo(_window);
    //        make.bottom.equalTo(_window);
    //    }];
    
    //    [_splashView mac]
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    defaults = [NSUserDefaults standardUserDefaults];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [defaults setObject:@"1" forKey:@"passType"];
    [defaults setObject:@"1" forKey:@"Type2"];
    [defaults setObject:@"1" forKey:@"Type3"];
    [defaults setObject:@"1" forKey:@"Type9"];
    [defaults setObject:@"1" forKey:@"goSowMain"];
    
    [defaults setInteger:1 forKey:@"loginType"];
    LoginViewController *login = [[LoginViewController alloc] init];
    
    
    //获取当前语言
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = languages[0];
    
    if([currentLanguage isEqualToString:@"zh-Hans-CN"] || [currentLanguage isEqualToString:@"zh-Hans"])
    {
        [defaults setObject:@"2" forKey:@"currentLanguage_phone"];
    }
    if([currentLanguage isEqualToString:@"zh-Hant"]|| [currentLanguage isEqualToString:@"zh-Hant-CN"] || [currentLanguage isEqualToString:@"zh-HK"])
    {
        [defaults setObject:@"3" forKey:@"currentLanguage_phone"];
        
    }
    if([currentLanguage isEqualToString:@"en"] || [currentLanguage isEqualToString:@"en-CN"])
    {
        [defaults setObject:@"1" forKey:@"currentLanguage_phone"];
    }
    
    //获取当前版本号
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
    NSString *app_Version = infoDictionary[@"CFBundleShortVersionString"];
    
    NSArray *arr =[app_Version componentsSeparatedByString:@"."];
    
    [defaults setObject:[NSString stringWithFormat:@"%d",[arr[0] intValue] * 10000 + [arr[1] intValue] * 100 +[arr[2] intValue]] forKey:@"currentVersion"] ;
    
    if([[defaults objectForKey:@"currentTimezone"] length] == 0)
    {
        [defaults setObject:@"1" forKey:@"currentTimezone"];
    }
    
    manager  = [DataManager shareInstance];
    [manager createDataBaseAndTable];
    [manager createPhoto];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 8.0)
    {
        if([[defaults objectForKey:@"DMloginScaleKey"] intValue] == 1 && [[manager getAllFavourie] count] > 0)
        {
            //            LeftViewController * left = [[LeftViewController alloc]init];
            //            CenterViewController * main = [[CenterViewController alloc]init];
            //            RightViewController * right = [[RightViewController alloc]init];
            //
            //            WWSideslipViewController * slide = [[WWSideslipViewController alloc]initWithLeftView:left andMainView:main andRightView:right andBackgroundImage:nil];
            //
            //            [slide setSpeedf:0.5];
            //
            //            //点击视图是是否恢复位置
            //            slide.sideslipTapGes.enabled = YES;
            //
            //            nav = [[UINavigationController alloc] init];
            //            [nav addChildViewController:login];
            //            [nav initWithRootViewController:slide];
            nav = [AppDelegate setupViewControllers];
        }
        else
        {
            nav = [[UINavigationController alloc] initWithRootViewController:login];
        }
    }
    else
    {
        nav = [[UINavigationController alloc] initWithRootViewController:login];
    }
    
    [self.window setRootViewController:nav];
    
    [self.window makeKeyAndVisible];
    
    //错误日志
    [MyUncaughtExceptionHandler setDefaultHandler];
    
    // 发送崩溃日志
    NSFileManager* fileManager=[NSFileManager defaultManager];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dataPath = [path stringByAppendingPathComponent:@"Exception.txt"];
    NSData *data = [NSData dataWithContentsOfFile:dataPath];
    
    NSString *ErrorTontext  =[[ NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (data != nil)
    {
        WebService *webService = [WebService newWithWebServiceAction:@"ExceptionError" andDelegate:self];
        webService.tag = 0;
        WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"error" andValue:ErrorTontext];
        
        NSArray *parameter = @[loginParameter1];
        // webservice请求并获得结果
        webService.webServiceParameter = parameter;
        [webService getWebServiceResult:@"ExceptionErrorResult"];
        
        BOOL blDele= [fileManager removeItemAtPath:dataPath error:nil];
        if (blDele) {
            NSLog(@"dele success");
        }else {
            NSLog(@"dele fail");
        }
    }
    
    
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings
                                                                             settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge)
                                                                             categories:nil]];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        //这里还是原来的代码
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
    if(launchOptions)
    {
        NSString *message = [[launchOptions objectForKey:@"aps"]objectForKey:@"alert"];
        NSArray *array = [launchOptions objectForKey:@"Content"];
        
        [defaults setObject:[array objectAtIndex:0] forKey:@"NoType"];
        [defaults setObject:[array objectAtIndex:1] forKey:@"NODeviceID"];
        if([[defaults objectForKey:@"NoType"] intValue] == 2)
        {
            NSArray *arr =  [[array objectAtIndex:2] componentsSeparatedByString:@","];
            [defaults setObject:[arr objectAtIndex:0] forKey:@"NOUseID"];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:message delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil),nil];
            
            alert.tag = 2;
            [alert show];
            
        }
        else if([[defaults objectForKey:@"NoType"] intValue] == 3)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:message delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil),nil];
            
            alert.tag = 3;
            [alert show];
            
        }
        else if([[defaults objectForKey:@"NoType"] intValue] == 4)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:message delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil),nil];
            
            alert.tag = 4;
            [alert show];
            
        }
        else if ([[defaults objectForKey:@"NoTyoe"] intValue] == 1)
        {
            // [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshAudio" object:[[object objectForKey:@"L"] objectForKey:@"V"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshIIIIII" object:self];
            // [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshBook" object:self];
            
        }
        
    }
    application.applicationIconBadgeNumber = 0;
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    NSLog(@"this is iOS7 Remote Notification");
}

-(void)animationImageTwo
{
    //    [lock lock];
    KKSequenceImageView* imageView = [[KKSequenceImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    NSMutableArray* images = [NSMutableArray array];
    for (int i = 1; i <= 45; i++) {
        NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"LunchImage_%d",i] ofType:@"png"];
        if (path.length) {
            [images addObject:path];
        }
    }
    imageView.imagePathss = images;
    imageView.durationMS = images.count * 50;
    imageView.repeatCount = 1;
    imageView.delegate = self;
    //        [_lunchView addSubview:_imageView];
    [self.window addSubview:imageView];
    [imageView begin];
    __weak typeof (self)weakSelf = self;
    
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)((((int)imageView.durationMS)/1000.0)/*延迟执行时间*/ * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        
        //        [UIView animateWithDuration:1 animations:^{
        //
        ////            imageView.alpha = 0;
        //        } completion:^(BOOL finished)
        //        {
        //        [lock unlock];
        [imageView removeFromSuperview];
        
        
        //        }];
        
    });
}


#pragma mark - Methods

+ (RDVTabBarController *)setupViewControllers {
    HomeTabViewController *firstViewController = [[HomeTabViewController alloc] init];
    UIViewController *firstNavigationController = [[UINavigationController alloc] initWithRootViewController:firstViewController];
    
    MeTabViewController *secondViewController = [[MeTabViewController alloc] init];
    UIViewController *secondNavigationController = [[UINavigationController alloc] initWithRootViewController:secondViewController];
    
    FindTabViewController *thirdViewController = [[FindTabViewController alloc] init];
    UIViewController *thirdNavigationController = [[UINavigationController alloc] initWithRootViewController:thirdViewController];
    RDVTabBarController *tabBarController = [[RDVTabBarController alloc] init];
    [tabBarController setViewControllers:@[firstNavigationController, secondNavigationController,thirdNavigationController]];
    [self customizeTabBarForController:tabBarController];
    tabBarController.tabBar.backgroundView.backgroundColor = [UIColor colorWithRed:40/255.0 green:220/255.0 blue:220/255.0 alpha:0.9];
    return tabBarController;
}

+ (void)customizeTabBarForController:(RDVTabBarController *)tabBarController {
    //    UIImage *finishedImage = [UIImage imageNamed:@"tabbar_selected_background"];
    //    UIImage *unfinishedImage = [UIImage imageNamed:@"tabbar_normal_background"];
    NSArray *tabBarItemImages = @[@"ic_main_home", @"ic_main_me", @"ic_main_find"];
    NSArray *tabBarItemTitles = @[NSLocalizedString(@"home", nil), NSLocalizedString(@"me", nil), NSLocalizedString(@"find", nil)];
    NSInteger index = 0;
    for (RDVTabBarItem *item in [[tabBarController tabBar] items]) {
        //        [item setBackgroundSelectedImage:finishedImage withUnselectedImage:unfinishedImage];
        item.title = tabBarItemTitles[index];
        NSDictionary *tabBarTitleUnselectedDic = @{NSForegroundColorAttributeName:[UIColor colorWithRed:1 green:250/255.0 blue:240/255.0 alpha:1],NSFontAttributeName:[UIFont systemFontOfSize:12]};
        NSDictionary *tabBarTitleSelectedDic = @{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:12]};
        //修改tabberItem的title颜色
        item.selectedTitleAttributes = tabBarTitleSelectedDic;
        item.unselectedTitleAttributes = tabBarTitleUnselectedDic;
        UIImage *selectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_selected", [tabBarItemImages objectAtIndex:index]]];
        UIImage *unselectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@", [tabBarItemImages objectAtIndex:index]]];
        [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
        index++;
    }
}

+ (void)customizeInterface {
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    UIImage *backgroundImage = nil;
    NSDictionary *textAttributes = nil;
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        backgroundImage = [UIImage imageNamed:@"navigationbar_background_tall"];
        textAttributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18],NSForegroundColorAttributeName: [UIColor blackColor]};
    } else {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
        backgroundImage = [UIImage imageNamed:@"navigationbar_background"];
        textAttributes = @{UITextAttributeFont: [UIFont boldSystemFontOfSize:18],UITextAttributeTextColor: [UIColor blackColor],UITextAttributeTextShadowColor: [UIColor clearColor],UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetZero]};
#endif
    }
    
    [navigationBarAppearance setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    [navigationBarAppearance setTitleTextAttributes:textAttributes];
}




-(void)ReceiveRemoteNotification:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        
        //iOS10特有
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            
            if (granted) {
                // 点击允许
                NSLog(@"注册成功");
                [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                    //                    NSLog(@"%@", settings);
                }];
            } else {
                // 点击不允许
                NSLog(@"注册失败");
            }
            
        }];
    }else if ([[UIDevice currentDevice].systemVersion floatValue] >8.0){
        
        //iOS8 - iOS10
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge categories:nil]];
        
    }else if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0) {
        //iOS8系统以下
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    }
    // 注册获得device Token
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    
}







// iOS 10收到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    
    NSDictionary * userInfo = notification.request.content.userInfo;
    
    UNNotificationRequest *request = notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    
    
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"iOS10 前台收到远程通知:%@", [self logDic:userInfo]);
        
        
    }
    else {
        // 判断为本地通知
        NSLog(@"iOS10 前台收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
    
    
    
}

// 通知的点击事件
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
    
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    UNNotificationRequest *request = response.notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"iOS10 收到远程通知:%@", [self logDic:userInfo]);
        
    }
    else {
        // 判断为本地通知
        NSLog(@"iOS10 收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    
    
    
    // Warning: UNUserNotificationCenter delegate received call to -userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler: but the completion handler was never called.
    completionHandler();  // 系统要求执行这个方法
    
    
}



- (NSString *)logDic:(NSDictionary *)dic {
    if (![dic count]) {
        return nil;
    }
    NSString *tempStr1 =
    [[dic description] stringByReplacingOccurrencesOfString:@"\\u"
                                                 withString:@"\\U"];
    NSString *tempStr2 =
    [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 =
    [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str =
    [NSPropertyListSerialization propertyListFromData:tempData
                                     mutabilityOption:NSPropertyListImmutable
                                               format:NULL
                                     errorDescription:NULL];
    return str;
}


- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [CloudPushSDK registerDevice:deviceToken withCallback:^(CloudPushCallbackResult *res) {
        if (res.success) {
            NSLog(@"Register deviceToken success.");
        } else {
            NSLog(@"Register deviceToken failed, error: %@", res.error);
        }
    }];
    
    NSLog(@"%@", [NSString stringWithFormat:@"Device Token: %@", deviceToken]);
}

- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}



- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    NSLog(@"iOS6及以下系统，收到通知:%@", [self logDic:userInfo]);
    NSLog(@"Receive one notification.");
    // 取得APNS通知内容
    NSDictionary *aps = [userInfo valueForKey:@"aps"];
    // 内容
    NSString *content = [aps valueForKey:@"alert"];
    // badge数量
    NSInteger badge = [[aps valueForKey:@"badge"] integerValue];
    // 播放声音
    NSString *sound = [aps valueForKey:@"sound"];
    // 取得Extras字段内容
    NSString *Extras = [userInfo valueForKey:@"Extras"]; //服务端中Extras字段，key是自己定义的
    NSLog(@"content = [%@], badge = [%ld], sound = [%@], Extras = [%@]", content, (long)badge, sound, Extras);
    // iOS badge 清0
    application.applicationIconBadgeNumber = 0;
    // 通知打开回执上报
    // [CloudPushSDK handleReceiveRemoteNotification:userInfo];(Deprecated from v1.8.1)
    [CloudPushSDK sendNotificationAck:userInfo];
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:
(void (^)(UIBackgroundFetchResult))completionHandler {
    
    
    NSLog(@"iOS7及以上系统，收到通知:%@", [self logDic:userInfo]);
    
    
    completionHandler(UIBackgroundFetchResultNewData);
}

@end
