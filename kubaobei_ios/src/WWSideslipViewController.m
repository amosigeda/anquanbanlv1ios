//
//  WWSideslipViewController.m
//  WWSideslipViewControllerSample
//
//  Created by 王维 on 14-8-26.
//  Copyright (c) 2014年 wangwei. All rights reserved.
//
#import "DialingNumberController.h"
#import "CommUtil.h"
#import "Constants.h"
#import "WWSideslipViewController.h"
#import "APPSetViewController.h"
#import "BookViewController.h"
#import "WatchPhoneViewController.h"
#import "MessageRecordViewController.h"
#import "ProblemFeedbackViewController.h"
#import "BabyListViewController.h"
#import "AboutWatchViewController.h"
#import "WatchSetViewController.h"
#import "SYQRCodeViewController.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "OMGToast.h"
#import "EditHeadAndNameViewController.h"
#import "AudioViewController.h"
#import "DataManager.h"
#import "AudioModel.h"
#import "DeviceModel.h"
#import "BabySelectViewController.h"
#import "FeedbackViewController.h"
#import "SchoolGuardianViewController.h"
#import "ElectronicViewController.h"
#import "LoginViewController.h"
#import "EditHeadAndNameViewController.h"
#import "HistoryViewController.h"
#import "PhotoViewController.h"
#import "HealthViewController.h"
#import "FriendListViewController.h"

@interface WWSideslipViewController ()<WebServiceProtocol,UIAlertViewDelegate>
{
    NSUserDefaults *defaults;
    SYQRCodeViewController *vc;
    DeviceModel *deviceModel;
    AudioModel *audioModel;
    DataManager *manager;
    UIAlertView *alertView;
    NSMutableArray *deviceArray;
    NSMutableArray *modelArray;
    UIPanGestureRecognizer * pan;
}
@end

@implementation WWSideslipViewController
@synthesize speedf,sideslipTapGes;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"0" forKey:@"showRight"];
    [defaults setObject:@"0" forKey:@"showLeft"];

    manager = [DataManager shareInstance];
    modelArray = [manager getAllFavourie];
    modelArray =  [manager isSelect:[defaults objectForKey:@"binnumber"]];
    if(modelArray.count == 0)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"poptoroot" object:self];
    }
    else
    {
        deviceModel = modelArray[0];
    }
    
    self.view.backgroundColor = [UIColor colorWithRed:93/255.0 green:0 blue:96/255.0 alpha:1];
      NSNotificationCenter *addPhoneNumberNotification = [NSNotificationCenter defaultCenter];
    [addPhoneNumberNotification addObserver:self selector:@selector(showNext:) name:@"showNext" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showRighViewBig) name:@"showRight" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLeftView) name:@"showLeft" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAPPSet) name:@"showSet" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLocation) name:@"showLocation" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showBookView) name:@"showBook" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMessageRecord) name:@"showMessageRecord" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showProblem) name:@"showProblem" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showWatchPhone) name:@"showWatchPhone" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showBabyList) name:@"showBabyList" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAboutWatch) name:@"showAboutWatch" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showWatchSet) name:@"showWatchSet" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showHealthManagement) name:@"showHealthManagement" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAddView) name:@"showAddView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAudio) name:@"showAudio" object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showDialingNumber) name:@"showDialingNumber" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TelPhone) name:@"showTelPhone" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showFriendList) name:@"showFriendList" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSchool) name:@"showSchool" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresgBook) name:@"refreshBook" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showHistory) name:@"showHistory" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectBaby) name:@"selectBaby" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showWeiLan) name:@"showWeiLan" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(poptoroot) name:@"poptoroot" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showEditHeadAndName) name:@"showEditHeadAndName" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPhotoView) name:@"showPhotoView" object:nil];
    [self getDeviceList];
}

- (void)getDeviceList
{
    WebService *webService = [WebService newWithWebServiceAction:@"GetDeviceList" andDelegate:self];
    webService.tag = 5;
    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
    NSArray *parameter = @[loginParameter1];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"GetDeviceListResult"];
}

- (void)showPhotoView
{
    PhotoViewController *photo = [[PhotoViewController alloc] init];
    if([defaults integerForKey:@"deviceModelType"] == 1)
    {
        photo.title = NSLocalizedString(@"watch_album_d8", nil);
    }
    else{
        photo.title = NSLocalizedString(@"watch_album", nil);
    }
    [self.navigationController pushViewController:photo animated:YES];
}

- (void)showHistory
{
    HistoryViewController *history = [[HistoryViewController alloc] init];
    history.title = NSLocalizedString(@"history_track", nil);
    [self.navigationController pushViewController:history animated:YES];
}

- (void)showEditHeadAndName
{
    EditHeadAndNameViewController *vc =[[EditHeadAndNameViewController alloc] init];
    vc.title = NSLocalizedString(@"edit_image_name", nil);
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)poptoroot
{
    LoginViewController *vcs = [[LoginViewController alloc] init];
    for (UIViewController *controller in self.navigationController.viewControllers) {
        DataManager* data = [DataManager shareInstance];
        if ([controller isKindOfClass:[vcs class]]&& data.isLogin == false) {
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
}

- (void)showWeiLan
{
    ElectronicViewController *weilanm = [[ElectronicViewController alloc] init];
    weilanm.title = NSLocalizedString(@"fence", nil);
    [self.navigationController pushViewController:weilanm animated:YES];
}

- (void)showSchool
{
    SchoolGuardianViewController *vc = [[SchoolGuardianViewController alloc] init];
    vc.title = NSLocalizedString(@"school_defend", nil);
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)selectBaby
{
    BabySelectViewController *baby = [[BabySelectViewController alloc] init];
    if([defaults integerForKey:@"deviceModelType"] == 1)
    {
        baby.title = NSLocalizedString(@"select_watch_d8", nil);
    }
    else{
        baby.title = NSLocalizedString(@"select_watch", nil);
    }
    [self.navigationController pushViewController:baby animated:YES];
}

- (void)refresgBook
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshBookList" object:self];
}

- (void)TelPhone
{
    manager = [DataManager shareInstance];
    deviceArray =  [manager isSelect:[defaults objectForKey:@"binnumber"]];
    deviceModel = [deviceArray objectAtIndex:0];
    
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",deviceModel.PhoneNumber];
    NSMutableString *str1 = [[NSMutableString alloc] initWithFormat:@"tel:%@",deviceModel.PhoneCornet];
    
    if([[defaults objectForKey:@"telType"] intValue] == 0)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];

    }
    else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str1]];

    }

}
-(void)showDialingNumber
{
        UIStoryboard *UpgradeHardware = [UIStoryboard storyboardWithName:@"DialingNumberController" bundle:nil];
        UIViewController *firstVC = [UpgradeHardware instantiateViewControllerWithIdentifier:@"DialingNumberController"];
        [self.navigationController pushViewController:firstVC animated:YES];
}
- (void)showAudio
{
    AudioViewController *audio = [[AudioViewController alloc] init];
    audio.title = NSLocalizedString(@"chat", nil);
    [self.navigationController pushViewController:audio animated:YES];
}

- (void)showAddView
{
    [defaults setInteger:1 forKey:@"editWatch"];
    
    SYQRCodeViewController *qrcodevc = [[SYQRCodeViewController alloc] init];
    qrcodevc.title =NSLocalizedString(@"scans", nil);
    qrcodevc.SYQRCodeSuncessBlock = ^(SYQRCodeViewController *aqrvc,NSString *qrString){
        vc = aqrvc;
        
        if([qrString rangeOfString:@"?"].location != NSNotFound)
        {
            [defaults setObject:[[qrString componentsSeparatedByString:@"?"] objectAtIndex:1] forKey:@"bindNumber"];
        }
        else if(([qrString rangeOfString:@"/"].location != NSNotFound))
        {
            NSArray *arr = [qrString componentsSeparatedByString:@"/"];
            
            
            [defaults setObject:[[qrString componentsSeparatedByString:@"/"] objectAtIndex:arr.count-1] forKey:@"bindNumber"];
        }
        else
        {
            [defaults setObject:qrString forKey:@"bindNumber"];
        }
        
        WebService *webService = [WebService newWithWebServiceAction:@"LinkDeviceCheck" andDelegate:self];
        webService.tag = 0;
        WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
        WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"bindNumber" andValue:[defaults objectForKey:@"bindNumber"]];
        
        NSArray *parameter = @[loginParameter1, loginParameter2];
        // webservice请求并获得结果
        webService.webServiceParameter = parameter;
        [webService getWebServiceResult:@"LinkDeviceCheckResult"];
        
        // [aqrvc.navigationController popViewControllerAnimated:YES];
        
    };
    qrcodevc.SYQRCodeFailBlock = ^(SYQRCodeViewController *aqrvc){
        
        [aqrvc dismissViewControllerAnimated:NO completion:nil];
    };
    qrcodevc.SYQRCodeCancleBlock = ^(SYQRCodeViewController *aqrvc){
        [aqrvc dismissViewControllerAnimated:NO completion:nil];
    };
    //  [self presentViewController:qrcodevc animated:YES completion:nil];
    [self.navigationController pushViewController:qrcodevc animated:YES];
}

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
                if(ws.tag == 0)
                {
                    EditHeadAndNameViewController *edit = [[EditHeadAndNameViewController alloc] init];
                    [defaults setInteger:1 forKey:@"editWatch"];
                    
                    [self.navigationController pushViewController:edit animated:YES];
                }
                else if(ws.tag == 5)
                {
                    NSArray *array = [object objectForKey:@"deviceList"];
                    
                    for(int i =0 ; i < array.count;i++)
                    {
                        
                        NSDictionary *dic  = [array objectAtIndex:i];
                        
                        if([manager isFavourite:[dic objectForKey:@"BindNumber"]])
                        {
                            
                        }
                        else
                        {
                            [defaults setObject:[dic objectForKey:@"DeviceID"] forKey:@"loginDeviceID"];
#pragma mark - 写入设备信息表
                            [manager addFavourite:[dic objectForKey:@"ActiveDate"]
                                      andBabyName:[dic objectForKey:@"BabyName"] andBindNumber:[dic objectForKey:@"BindNumber"] andDeviceType:[dic objectForKey:@"DeviceType"] andBirthday:[dic objectForKey:@"Birthday"] andCreateTime:[dic objectForKey:@"CreateTime"] andCurrentFirmware:[dic objectForKey:@"CurrentFirmware"] andDeviceID:[dic objectForKey:@"DeviceID"] andDeviceModelID:[dic objectForKey:@"DeviceModelID"] andFirmware:[dic objectForKey:@"Firmware"] andGender:[dic objectForKey:@"Gender"] andGrade:[dic objectForKey:@"Grade"] andHireExpireDate:[dic objectForKey:@"HireExpireDate"] andDate:[dic objectForKey:@"Date"] andHomeAddress:[dic objectForKey:@"HomeAddress"] andHomeLat:[dic objectForKey:@"HomeLat"] andHomeLng:[dic objectForKey:@"HomeLng"] andIsGuard:[dic objectForKey:@"IsGuard"] andPassword:[dic objectForKey:@"Password"] andPhoneCornet:[dic objectForKey:@"PhoneCornet"] andPhoneNumber:[dic objectForKey:@"PhoneNumber"] andPhoto:[dic objectForKey:@"Photo"] andSchoolAddress:[dic objectForKey:@"SchoolAddress"] andSchoolLat:[dic objectForKey:@"SchoolLat"] andSchoolLng:[dic objectForKey:@"SchoolLng"] andSerialNumber:[dic objectForKey:@"SerialNumber"] andUpdateTime:[dic objectForKey:@"UpdateTime"] andUserId:[dic objectForKey:@"UserId"] andSetVersionNO:[dic objectForKey:@"SetVersionNO"]  andContactVersionNO:[dic objectForKey:@"ContactVersionNO"]  andOperatorType:[dic objectForKey:@"OperatorType"]  andSmsNumber:[dic objectForKey:@"SmsNumber"]  andSmsBalanceKey:[dic objectForKey:@"SmsBalanceKey"]  andSmsFlowKey:[dic objectForKey:@"SmsFlowKey"] andLatestTime:[dic objectForKey:@"LatestTime"] ];
                            
#pragma mark - 写入设备设置表
                            
                            NSDictionary *set = [dic objectForKey:@"DeviceSet"];
                            NSArray *setInfo = [[set objectForKey:@"SetInfo"] componentsSeparatedByString:@"-"];
                            
                            NSArray *classStar;
                            NSArray *classStop;
                            
                            classStar = [[set objectForKey:@"ClassDisabled1"] componentsSeparatedByString:@"-"];
                            
                            
                            classStop = [[set objectForKey:@"ClassDisabled2"] componentsSeparatedByString:@"-"];
                            
                            [manager addDeviceSetTable:[dic objectForKey:@"BindNumber"]  andVersionNumber:nil andAutoAnswer:[setInfo objectAtIndex:11]  andReportCallsPosition:[setInfo objectAtIndex:10] andBodyFeelingAnswer:[setInfo objectAtIndex:9] andExtendEmergencyPower:[setInfo objectAtIndex:8] andClassDisable:[setInfo objectAtIndex:7] andTimeSwitchMachine:[setInfo objectAtIndex:6] andRefusedStrangerCalls:[setInfo objectAtIndex:5] andWatchOffAlarm:[setInfo objectAtIndex:4] andWatchCallVoice:[setInfo objectAtIndex:3] andWatchCallVibrate:[setInfo objectAtIndex:2] andWatchInformationSound:[setInfo objectAtIndex:1] andWatchInformationShock:[setInfo objectAtIndex:0] andClassDisabled1:[classStar objectAtIndex:0] andClassDisabled2:[classStar objectAtIndex:1] andClassDisabled3:[classStop objectAtIndex:0] andClassDisabled4:[classStop objectAtIndex:1] andWeekDisabled:[set objectForKey:@"WeekDisabled"] andTimerOpen:[set objectForKey:@"TimerOpen"] andTimerClose:[set objectForKey:@"TimerClose"] andBrightScreen:[set objectForKey:@"BrightScreen"] andweekAlarm1:[set objectForKey:@"WeekAlarm1"] andweekAlarm2:[set objectForKey:@"WeekAlarm2"] andweekAlarm3:[set objectForKey:@"WeekAlarm3"] andalarm1:[set objectForKey:@"Alarm1"] andalarm2:[set objectForKey:@"Alarm2"] andalarm3:[set objectForKey:@"Alarm3"] andlocationMode:[set objectForKey:@"LocationMode"] andlocationTime:[set objectForKey:@"LocationTime"] andflowerNumber:[set objectForKey:@"FlowerNumber"] andStepCalculate:[set objectForKey:@"StepCalculate"] andSleepCalculate:[set objectForKey:@"SleepCalculate"] andHrCalculate:[set objectForKey:@"HrCalculate"] andSosMsgswitch:[set objectForKey:@"SosMsgswitch"] andTimeZone:@"" andLanguage:@"" andDialPad:@"0"];
                            
#pragma mark - 写入联系人表
                            
                            NSArray *contact = [dic objectForKey:@"ContactArr"];
                            for(int i = 0; i < contact.count;i++)
                            {
                                NSDictionary *con = [contact objectAtIndex:i];
                                
                                [manager addContactTable:[dic objectForKey:@"BindNumber"] andDeviceContactId:[con objectForKey:@"DeviceContactId"] andRelationship:[con objectForKey:@"Relationship"] andPhoto:[con objectForKey:@"Photo"] andPhoneNumber:[con objectForKey:@"PhoneNumber"] andPhoneShort:[con objectForKey:@"PhoneShort"] andType:[con objectForKey:@"Type"] andObjectId:[con objectForKey:@"ObjectId"] andHeadImg:[con objectForKey:@"HeadImg"]];
                            }
                            
#pragma mark - 写入位置表
                            NSDictionary *location = [dic objectForKey:@"DeviceState"];
                            [manager addLocationDeviceID:[dic objectForKey:@"DeviceID"] andAltitude:[location objectForKey:@"Altitude"] andCourse:[location objectForKey:@"Course"] andLocationType:[location objectForKey:@"LocationType"] andCreateTime:[location objectForKey:@"CreateTime"] andElectricity:[location objectForKey:@"Electricity"] andGSM:[location objectForKey:@"GSM"] andStep:[location objectForKey:@"Step"] andHealth:[location objectForKey:@"Health"] andLatitude:[location objectForKey:@"Latitude"] andLongitude:[location objectForKey:@"Longitude"] andOnline:[location objectForKey:@"Online"] andSatelliteNumber:[location objectForKey:@"SatelliteNumber"] andServerTime:[location objectForKey:@"ServerTime"] andSpeed:[location objectForKey:@"Speed"] andUpdateTime:[location objectForKey:@"UpdateTime"]  andDeviceTime:[location objectForKey:@"DeviceTime"]];
                        }
                    }
                }
            }
            else if(code == 4)
            {
                [OMGToast showWithText:NSLocalizedString(@"equipment_has_been_associated", nil) bottomOffset:50 duration:2];
                [self.navigationController popViewControllerAnimated:YES];
            }
            else if (code == 3)
            {
                [OMGToast showWithText:NSLocalizedString(@"device_no_exist", nil) bottomOffset:50 duration:2];
                [self.navigationController popViewControllerAnimated:YES];

            }
            else if(code == 5)
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
            
            else if (code == 2)
            {
                alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"input_name", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
                alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                [alertView show];
            }
            else if(code == 0)
            {
                [OMGToast showWithText:NSLocalizedString(@"abnormal_login", nil) bottomOffset:50 duration:3];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"poptoroot" object:self];

            }
            
            if(ws.tag == 3)
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
            
            if(ws.tag != 5)
            {
                [OMGToast showWithText:NSLocalizedString([object objectForKey:@"Message"], nil)  bottomOffset:50 duration:2];

            }
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        WebService *webService = [WebService newWithWebServiceAction:@"LinkDevice" andDelegate:self];
        webService.tag = 3;
        WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];

        WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"name" andValue:[NSString stringWithFormat:@"%@",[alertView textFieldAtIndex:0].text]];
        WebServiceParameter *loginParameter4 = [WebServiceParameter newWithKey:@"bindNumber" andValue:[defaults objectForKey:@"bindNumber"]];
        WebServiceParameter *loginParameter5 = [WebServiceParameter newWithKey:@"language" andValue:[defaults objectForKey:@"currentLanguage_phone"]];
        WebServiceParameter *loginParameter6 = [WebServiceParameter newWithKey:@"timeZone" andValue:[defaults objectForKey:@"currentTimezone"]];

        NSArray *parameter = @[loginParameter1,loginParameter3,loginParameter4,loginParameter5,loginParameter6];
        // webservice请求并获得结果
        webService.webServiceParameter = parameter;
        [webService getWebServiceResult:@"LinkDeviceResult"];
    }
}

- (void)showBabyList
{
    BabyListViewController *baby = [[BabyListViewController alloc] init];
    baby.title = NSLocalizedString(@"babyinfo", nil);
    [self.navigationController pushViewController:baby animated:YES];
}

- (void)showWatchSet
{
    WatchSetViewController *watch = [[WatchSetViewController alloc] init];
    if([defaults integerForKey:@"deviceModelType"] == 1)
    {
         watch.title = NSLocalizedString(@"watch_setting_d8", nil);
    }
    else{
        watch.title = NSLocalizedString(@"watch_setting", nil);
    }
    [self.navigationController pushViewController:watch animated:YES];
    
}

- (void)showHealthManagement
{
    HealthViewController *health = [[HealthViewController alloc] init];
    health.title = NSLocalizedString(@"health_management", nil);
    [self.navigationController pushViewController:health animated:YES];
    
}

- (void)showFriendList
{
    FriendListViewController *friendlist = [[FriendListViewController alloc] init];
    friendlist.title = NSLocalizedString(@"Watch_FriendList", nil);
    [self.navigationController pushViewController:friendlist animated:YES];
    
}

- (void)showAboutWatch
{
    AboutWatchViewController *about = [[AboutWatchViewController alloc] init];
    if([defaults integerForKey:@"deviceModelType"] == 1)
    {
        about.title = NSLocalizedString(@"about_watch_d8", nil);
    }
    else{
        about.title = NSLocalizedString(@"about_watch", nil);
    }
    [self.navigationController pushViewController:about animated:YES];
}

- (void)showMessageRecord
{
    MessageRecordViewController *message = [[MessageRecordViewController alloc] init];
    message.title = NSLocalizedString(@"msg_record", nil);
    [self.navigationController pushViewController:message animated:YES];
}

- (void)showProblem
{
    FeedbackViewController *pro = [[FeedbackViewController alloc] init];
    pro.title = NSLocalizedString(@"problem_feedback", nil);
    [self.navigationController pushViewController:pro animated:YES];
}

- (void)showWatchPhone
{
    WatchPhoneViewController *wat = [[WatchPhoneViewController alloc] init];
    if([defaults integerForKey:@"deviceModelType"] == 1)
    {
        wat.title = NSLocalizedString(@"watch_fare_d8", nil);
    }
    else{
        wat.title = NSLocalizedString(@"watch_fare", nil);
    }
    [self.navigationController pushViewController:wat animated:YES];
}

- (void)showBookView
{
    BookViewController *book = [[BookViewController alloc] init];
    book.title = NSLocalizedString(@"mail_list", nil);
    [self.navigationController pushViewController:book animated:YES];
}



- (void)showAPPSet
{
    APPSetViewController *appset = [[APPSetViewController alloc] init];
    appset.title = NSLocalizedString(@"setting", nil);
    [defaults setObject:@"0" forKey:@"showRight"];
    [self.navigationController pushViewController:appset animated:YES];
}

- (void)showLeftViewBig
{
    if([[defaults objectForKey:@"showLeft"] isEqualToString:@"0"])
    {
        [UIView beginAnimations:nil context:nil];

        righControl.view.hidden = YES;
        leftControl.view.hidden = NO;
        
        mainControl.view.transform = CGAffineTransformScale(CGAffineTransformIdentity,0.8,0.9);
        leftControl.view.transform = CGAffineTransformScale(CGAffineTransformIdentity,1+scalef/1100,1+scalef/1100);
        
        mainControl.view.center = CGPointMake(mainControl.view.frame.size.width*1.5,[UIScreen mainScreen].bounds.size.height/2);
        [defaults setObject:@"1" forKey:@"showLeft"];
        [UIView commitAnimations];
    }
    else
    {
        [UIView beginAnimations:nil context:nil];
    //    mainControl.view.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.0,1.0);
       //  mainControl.view.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2,[UIScreen mainScreen].bounds.size.height/2);
        mainControl.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        [UIView commitAnimations];
        [defaults setObject:@"0" forKey:@"showLeft"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showRighViewBig
{
    
    if([[defaults objectForKey:@"showRight"] isEqualToString:@"0"])
    {
        [UIView beginAnimations:nil context:nil];

        righControl.view.hidden = NO;
        leftControl.view.hidden = YES;
        
        mainControl.view.transform = CGAffineTransformScale(CGAffineTransformIdentity,0.8,0.8);
        mainControl.view.center = CGPointMake(-60,[UIScreen mainScreen].bounds.size.height/2);
        
        [UIView commitAnimations];
        speedf = 0.5;
        [defaults setObject:@"1" forKey:@"showRight"];
        
    }
    else
    {
        [UIView beginAnimations:nil context:nil];
        mainControl.view.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.0,1.0);
        // mainControl.view.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2,[UIScreen mainScreen].bounds.size.height/2);
        
        mainControl.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        [UIView commitAnimations];
        [defaults setObject:@"0" forKey:@"showRight"];
    }
}

-(instancetype)initWithLeftView:(UIViewController *)LeftView
                    andMainView:(UIViewController *)MainView
                   andRightView:(UIViewController *)RighView
                        andBackgroundImage:(UIImage *)image;
{
    if(self){
        speedf = 0.5;
        
        leftControl = LeftView;
        mainControl = MainView;
        righControl = RighView;
        
        UIImageView * imgview = [[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        [imgview setImage:image];
        [self.view addSubview:imgview];
        
        //滑动手势
        pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
        [mainControl.view addGestureRecognizer:pan];
        
        //单击手势
        sideslipTapGes= [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handeTap:)];
        [sideslipTapGes setNumberOfTapsRequired:1];
        
        [mainControl.view addGestureRecognizer:sideslipTapGes];
        
        leftControl.view.hidden = YES;
        righControl.view.hidden = YES;
        
        [self.view addSubview:leftControl.view];
        [leftControl.view setFrame:self.view.frame];
//        [self.view addSubview:righControl.view];
//        [righControl.view setFrame:self.view.frame];
        [self.view addSubview:mainControl.view];
        [mainControl.view setFrame:self.view.frame];
        
    }
    return self;
}
-(void)showNext:(NSNotification*)addPhoneNumberNotification
{
    if (self.navigationController) {
        NSLog(@"!");
    }
    [defaults setInteger:1 forKey:@"edit"];
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0/*延迟执行时间*/ * NSEC_PER_SEC));
    
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{

        EditHeadAndNameViewController *vc = [[EditHeadAndNameViewController alloc] init];
        NSString* bindNumber;
        if ([CommUtil isNotBlank:addPhoneNumberNotification.object]) {
           bindNumber = addPhoneNumberNotification.object;
        }
        vc.bindNumber = bindNumber;
        [self.navigationController pushViewController:vc  animated:YES];
    });
    
}
- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
  //  mainControl.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

#pragma mark - 滑动手势

//滑动手势
- (void) handlePan: (UIPanGestureRecognizer *)rec{
    
    CGPoint point = [rec translationInView:self.view];

    scalef = (point.x*speedf+scalef);
    //根据视图位置判断是左滑还是右边滑动
    if (rec.view.frame.origin.x>=0){
        rec.view.center = CGPointMake(rec.view.center.x + point.x*speedf,rec.view.center.y);
        rec.view.transform = CGAffineTransformScale(CGAffineTransformIdentity,1-scalef/1000,1-scalef/1000);
        [rec setTranslation:CGPointMake(0, 0) inView:self.view];
       // leftControl.view.transform = CGAffineTransformScale(CGAffineTransformIdentity,1+scalef/1100,1+scalef/1100);
       // righControl.view.transform = CGAffineTransformScale(CGAffineTransformIdentity,1+scalef/1100,1+scalef/1100);

        righControl.view.hidden = YES;
        leftControl.view.hidden = NO;
    }
    else
    {
//        rec.view.center = CGPointMake(rec.view.center.x +point.x*speedf,rec.view.center.y);
//        rec.view.transform = CGAffineTransformScale(CGAffineTransformIdentity,1+scalef/1000,1+scalef/1000);
//        [rec setTranslation:CGPointMake(0, 0) inView:self.view];
      //  leftControl.view.transform = CGAffineTransformScale(CGAffineTransformIdentity,1-scalef/1100,1-scalef/1100);
     //   righControl.view.transform = CGAffineTransformScale(CGAffineTransformIdentity,1-scalef/1100,1-scalef/1100);

        righControl.view.hidden = YES;
        leftControl.view.hidden = YES;
    }
    
    //手势结束后修正位置
    if (rec.state == UIGestureRecognizerStateEnded) {
        if (scalef>5*speedf){
            [self showLeftView];

        }
        else if (scalef<-100*speedf)
        {
            mainControl.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            scalef = 0;

        }
        else
        {
            [self showMainView];
            scalef = 0;
        }
    }
}

#pragma mark - 单击手势
-(void)handeTap:(UITapGestureRecognizer *)tap{
    
    if (tap.state == UIGestureRecognizerStateEnded) {
        [UIView beginAnimations:nil context:nil];
        tap.view.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.0,1.0);
        tap.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        [UIView commitAnimations];
        scalef = 0;
        [defaults setObject:@"0" forKey:@"showRight"];
        [defaults setObject:@"0" forKey:@"showLeft"];

    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if([[defaults objectForKey:@"goSowMain"] intValue] == 1)
    {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
        {
            [self showMainView];
            scalef = 0;
            [defaults setObject:@"0" forKey:@"goSowMain"];
            
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{

}

#pragma mark - 修改视图位置
//恢复位置
-(void)showMainView{
    [UIView beginAnimations:nil context:nil];
    mainControl.view.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.0,1.0);
   // mainControl.view.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2,[UIScreen mainScreen].bounds.size.height/2);
    
    mainControl.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [defaults setObject:@"0" forKey:@"showRight"];
    [defaults setObject:@"0" forKey:@"showLeft"];


    [UIView commitAnimations];
}

//显示左视图
-(void)showLeftView{
    [UIView beginAnimations:nil context:nil];
    righControl.view.hidden = YES;
    leftControl.view.hidden = NO;
    mainControl.view.transform = CGAffineTransformScale(CGAffineTransformIdentity,0.8,0.8);
    mainControl.view.center = CGPointMake(380,[UIScreen mainScreen].bounds.size.height/2);
    [defaults setObject:@"1" forKey:@"showLeft"];
    
    [UIView commitAnimations];

}

//显示右视图
-(void)showRighView{
    [UIView beginAnimations:nil context:nil];
    righControl.view.hidden = NO;
    leftControl.view.hidden = YES;
    mainControl.view.transform = CGAffineTransformScale(CGAffineTransformIdentity,0.8,0.8);
    mainControl.view.center = CGPointMake(-60,[UIScreen mainScreen].bounds.size.height/2);
   // righControl.view.transform = CGAffineTransformScale(CGAffineTransformIdentity,1-scalef/1100,1-scalef/1100);
    [defaults setObject:@"1" forKey:@"showRight"];
    [UIView commitAnimations];
}

@end
