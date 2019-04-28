//
//  EditHeadAndNameViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "EditHeadAndNameViewController.h"
#import "AddNameViewController.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "OMGToast.h"
#import "WWSideslipViewController.h"
#import "DataManager.h"
#import "DeviceModel.h"
#import "ContactModel.h"
#import "LeftViewController.h"
#import "CenterViewController.h"
#import "RightViewController.h"
#import "LoginViewController.h"
#import "YCHUDView.h"
#define kMaxLength 8

@interface EditHeadAndNameViewController ()<UITextFieldDelegate,UIAlertViewDelegate>
{
    NSUserDefaults *defaluts;
    
    ContactModel *conModel;
    DeviceModel *deviceModel;
    
    NSMutableArray *deviceArray;
    NSMutableArray *conArray;
    DataManager *manager;
    NSTimer *refreshDeviceTimer;

    __weak IBOutlet UIButton *nextsStep;
}
@end

@implementation EditHeadAndNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    defaluts = [NSUserDefaults standardUserDefaults];
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{UITextAttributeTextColor: [UIColor whiteColor]}];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];
    
    UIButton* rightBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [rightBtn setTitle:NSLocalizedString(@"next", nil) forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    rightBtn.frame = CGRectMake(0, 0, 50, 30);
    
    UIBarButtonItem* rightBtnItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    
    [rightBtn addTarget:self action:@selector(showNext) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setRightBarButtonItem:rightBtnItem];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    NSLog(@"%f",self.cuntomLabel.frame.origin.y);
    self.scrollView.contentSize = CGSizeMake(320, 500);
    
    self.fatherButton.selected = YES;
    [self.fatherButton setBackgroundImage:[UIImage imageNamed:@"father_pressed"] forState:UIControlStateNormal];
    [defaluts setObject:@"1" forKey:@"headType"];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.inputNameTextField.delegate= self;
    self.inputNameTextField.hidden = YES;
    self.inputNameTextField.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    [defaluts setObject:self.fatherLabel.text forKey:@"Chenghu"];
    
    manager = [DataManager shareInstance];

    if([defaluts integerForKey:@"editWatch"] == 3)
    {
        deviceArray =  [manager isSelect:[defaluts objectForKey:@"binnumber"]];
        deviceModel = deviceArray[0];
        
        conArray = [manager isSelectContactTable:[defaluts objectForKey:@"binnumber"]];
        
        conModel = conArray[(NSUInteger) [defaluts integerForKey:@"selectIndex"]];
    }
    
    self.fatherLabel.text = NSLocalizedString(@"father", nil);
    self.motherLabel.text = NSLocalizedString(@"mother", nil);
    self.grandfatherLabel.text = NSLocalizedString(@"grandpa", nil);
    self.grandmotherLabel.text = NSLocalizedString(@"grandma", nil);
    self.grandPaLabel.text = NSLocalizedString(@"grandfather", nil);
    self.grandMaLabel.text = NSLocalizedString(@"grandmother", nil);
    self.customLabel.text = NSLocalizedString(@"custom", nil);
    self.inputNameTextField.placeholder = NSLocalizedString(@"manually_enter_call", nil);
    
}

- (void)showNext
{

    int i =[defaluts integerForKey:@"editWatch"];
    if([defaluts integerForKey:@"editWatch"] == 10)
    {
        [defaluts setInteger:10 forKey:@"resignType"];
        
        AddNameViewController *vc = [[AddNameViewController alloc] init];
        vc.title = NSLocalizedString(@"contant_phone", nil);
        [self.navigationController pushViewController:vc animated:YES];
    }else if([defaluts integerForKey:@"editWatch"] == 0)
    {
        [defaluts setInteger:5 forKey:@"resignType"];

        AddNameViewController *vc = [[AddNameViewController alloc] init];
        vc.title = NSLocalizedString(@"contant_phone", nil);
        vc.bindNumber = self.bindNumber;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if([defaluts integerForKey:@"editWatch"] == 1)
    {
        //关联时编辑用
        [defaluts setInteger:0 forKey:@"resignType"];
        WebService *webService = [WebService newWithWebServiceAction:@"LinkDevice" andDelegate:self];
        webService.tag = 0;
        WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaluts objectForKey:@"LoginId"]];
        WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"photo" andValue:[NSString stringWithFormat:@"%ld", (long) [defaluts integerForKey:@"headType"]]];
        WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"name" andValue:[NSString stringWithFormat:@"%@",[defaluts objectForKey:@"Chenghu"]]];
        WebServiceParameter *loginParameter4 = [WebServiceParameter newWithKey:@"bindNumber" andValue:[defaluts objectForKey:@"bindNumber"]];
        WebServiceParameter *loginParameter5 = [WebServiceParameter newWithKey:@"language" andValue:[defaluts objectForKey:@"currentLanguage_phone"]];
        WebServiceParameter *loginParameter6 = [WebServiceParameter newWithKey:@"timeZone" andValue:[defaluts objectForKey:@"currentTimezone"]];

        NSArray *parameter = @[loginParameter1, loginParameter2,loginParameter3,loginParameter4,loginParameter5,loginParameter6];
        // webservice请求并获得结果
        webService.webServiceParameter = parameter;
        [webService getWebServiceResult:@"LinkDeviceResult"];
    }
    else if ([defaluts integerForKey:@"editWatch"] == 2)
    {
        [defaluts setInteger:1 forKey:@"resignType"];
        
        WebService *webService = [WebService newWithWebServiceAction:@"LinkDevice" andDelegate:self];
        webService.tag = 3;
        WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaluts objectForKey:@"LoginId"]];
        WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"photo" andValue:[NSString stringWithFormat:@"%ld",[defaluts integerForKey:@"headType"]]];
        WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"name" andValue:[NSString stringWithFormat:@"%@",[defaluts objectForKey:@"Chenghu"]]];
        WebServiceParameter *loginParameter4 = [WebServiceParameter newWithKey:@"bindNumber" andValue:[defaluts objectForKey:@"bindNumber"]];
        WebServiceParameter *loginParameter5 = [WebServiceParameter newWithKey:@"language" andValue:[defaluts objectForKey:@"currentLanguage_phone"]];
        WebServiceParameter *loginParameter6 = [WebServiceParameter newWithKey:@"timeZone" andValue:[defaluts objectForKey:@"currentTimezone"]];

        NSArray *parameter = @[loginParameter1, loginParameter2,loginParameter3,loginParameter4,loginParameter5,loginParameter6];
        // webservice请求并获得结果
        webService.webServiceParameter = parameter;
        [webService getWebServiceResult:@"LinkDeviceResult"];
    }
    else if([defaluts integerForKey:@"editWatch"] == 3)
    {
        //编辑通讯录联系人
        WebService *webService = [WebService newWithWebServiceAction:@"EditRelation" andDelegate:self];
        webService.tag = 1;
        WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"POST" andValue:@"phonebook/updatePhoneBook"];
        WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"token" andValue:[defaluts objectForKey:MAIN_USER_TOKEN]];
        WebServiceParameter *parameter3 = [WebServiceParameter newWithKey:@"imei" andValue:[defaluts objectForKey:@"binnumber"]];
        WebServiceParameter *parameter4 = [WebServiceParameter newWithKey:@"id" andValue:conModel.DeviceContactId];
        WebServiceParameter *parameter5 = [WebServiceParameter newWithKey:@"name" andValue:[NSString stringWithFormat:@"%@",[defaluts objectForKey:@"Chenghu"]]];
        WebServiceParameter *parameter6 = [WebServiceParameter newWithKey:@"headtype" andValue:[NSString stringWithFormat:@"%ld",[defaluts integerForKey:@"headType"]]];
        WebServiceParameter *parameter7 = [WebServiceParameter newWithKey:@"phone" andValue:conModel.PhoneNumber];
        WebServiceParameter *parameter8 = [WebServiceParameter newWithKey:@"cornet" andValue:conModel.PhoneShort];
        NSArray *parameter = @[parameter1, parameter2, parameter3, parameter4, parameter5, parameter6, parameter7, parameter8];
        // webservice请求并获得结果
        webService.webServiceParameter = parameter;
        [webService getWebServiceResult:@"EditRelationResult"];
    }
    else if ([defaluts integerForKey:@"editWatch"] == 4)
    {
        WebService *webService = [WebService newWithWebServiceAction:@"LinkDeviceConfirm" andDelegate:self];
        webService.tag = 10;
        WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaluts objectForKey:@"LoginId"]];
        WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"deviceId" andValue:[defaluts objectForKey:@"NODeviceID"]];
        WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"userId" andValue:[defaluts objectForKey:@"NOUseID"]];
        WebServiceParameter *loginParameter4 = [WebServiceParameter newWithKey:@"name" andValue:[defaluts objectForKey:@"Chenghu"]];
        WebServiceParameter *loginParameter5 = [WebServiceParameter newWithKey:@"photo" andValue:[NSString stringWithFormat:@"%ld",[defaluts integerForKey:@"headType"]]];
        WebServiceParameter *loginParameter6 = [WebServiceParameter newWithKey:@"confirm" andValue:@"1"];
        NSArray *parameter = @[loginParameter1,loginParameter2,loginParameter3,loginParameter4,loginParameter5,loginParameter6];
        // webservice请求并获得结果
        webService.webServiceParameter = parameter;
        [webService getWebServiceResult:@"LinkDeviceConfirmResult"];
    }
    else if ([defaluts integerForKey:@"editWatch"] == 100)
    {
        WebService *webService = [WebService newWithWebServiceAction:@"LinkDeviceConfirm" andDelegate:self];
        webService.tag = 100;
        WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaluts objectForKey:@"LoginId"]];
        WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"deviceId" andValue:[defaluts objectForKey:@"NODeviceID"]];
        WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"userId" andValue:[defaluts objectForKey:@"NOUseID"]];
        WebServiceParameter *loginParameter4 = [WebServiceParameter newWithKey:@"name" andValue:[defaluts objectForKey:@"Chenghu"]];
        WebServiceParameter *loginParameter5 = [WebServiceParameter newWithKey:@"photo" andValue:[NSString stringWithFormat:@"%ld",[defaluts integerForKey:@"headType"]]];
        WebServiceParameter *loginParameter6 = [WebServiceParameter newWithKey:@"confirm" andValue:@"1"];
        NSArray *parameter = @[loginParameter1,loginParameter2,loginParameter3,loginParameter4,loginParameter5,loginParameter6];
        // webservice请求并获得结果
        webService.webServiceParameter = parameter;
        [webService getWebServiceResult:@"LinkDeviceConfirmResult"];
    }
}

- (void)getDeviceList
{
    WebService *webService = [WebService newWithWebServiceAction:@"GetDeviceList" andDelegate:self];
    webService.tag = 2;
    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaluts objectForKey:@"LoginId"]];
    
    NSArray *parameter = @[loginParameter1];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"GetDeviceListResult"];
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
                    //关联
                    [self getDeviceList];
                }
                else if (ws.tag == 2)
                {
                     manager = [DataManager shareInstance];
                    [manager createDeviceTable];
                    [manager createContactTable];
                    [manager createDeviceSetTable];
                    [manager createAudioTable];
                    [manager createMessageRecord];
                    [manager createShortMessage];
                    [manager dropLocation];
                    [manager createLocation];
                    [manager createLocationCache];

                    NSArray *array = [object objectForKey:@"deviceList"];
                       if(![defaluts objectForKey:@"binnumber"] || [[defaluts objectForKey:@"binnumber"] isEqualToString:@""])                    {
                        [defaluts setObject:[[array objectAtIndex:0] objectForKey:@"BindNumber"] forKey:@"binnumber"];
                    }
                    for(int i =0 ; i < array.count;i++)
                    {
                        NSDictionary *dic  = [array objectAtIndex:i];
#pragma mark - 写入设备信息表
                        [manager addFavourite:[dic objectForKey:@"ActiveDate"]
                                  andBabyName:[dic objectForKey:@"BabyName"] andBindNumber:[dic objectForKey:@"BindNumber"] andDeviceType:[dic objectForKey:@"DeviceType"] andBirthday:[dic objectForKey:@"Birthday"] andCreateTime:[dic objectForKey:@"CreateTime"] andCurrentFirmware:[dic objectForKey:@"CurrentFirmware"] andDeviceID:[dic objectForKey:@"DeviceID"] andDeviceModelID:[dic objectForKey:@"DeviceModelID"] andFirmware:[dic objectForKey:@"Firmware"] andGender:[dic objectForKey:@"Gender"] andGrade:[dic objectForKey:@"Grade"] andHireExpireDate:[dic objectForKey:@"HireExpireDate"] andDate:[dic objectForKey:@"Date"] andHomeAddress:[dic objectForKey:@"HomeAddress"] andHomeLat:[dic objectForKey:@"HomeLat"] andHomeLng:[dic objectForKey:@"HomeLng"] andIsGuard:[dic objectForKey:@"IsGuard"] andPassword:[dic objectForKey:@"Password"] andPhoneCornet:[dic objectForKey:@"PhoneCornet"] andPhoneNumber:[dic objectForKey:@"PhoneNumber"] andPhoto:[dic objectForKey:@"Photo"] andSchoolAddress:[dic objectForKey:@"SchoolAddress"] andSchoolLat:[dic objectForKey:@"SchoolLat"] andSchoolLng:[dic objectForKey:@"SchoolLng"] andSerialNumber:[dic objectForKey:@"SerialNumber"] andUpdateTime:[dic objectForKey:@"UpdateTime"] andUserId:[dic objectForKey:@"UserId"] andSetVersionNO:[dic objectForKey:@"SetVersionNO"]  andContactVersionNO:[dic objectForKey:@"ContactVersionNO"]  andOperatorType:[dic objectForKey:@"OperatorType"]  andSmsNumber:[dic objectForKey:@"SmsNumber"]  andSmsBalanceKey:[dic objectForKey:@"SmsBalanceKey"]  andSmsFlowKey:[dic objectForKey:@"SmsFlowKey"] andLatestTime:[dic objectForKey:@"LatestTime"]];
                        
#pragma mark - 写入设备设置表
                        NSDictionary *set = [dic objectForKey:@"DeviceSet"];
                        NSArray *setInfo = [[set objectForKey:@"SetInfo"] componentsSeparatedByString:@"-"];
                        NSArray *classStar = [[set objectForKey:@"ClassDisabled1"] componentsSeparatedByString:@"-"];
                        NSArray *classStop = [[set objectForKey:@"ClassDisabled2"] componentsSeparatedByString:@"-"];
                        [manager addDeviceSetTable:[dic objectForKey:@"BindNumber"]  andVersionNumber:nil andAutoAnswer:[setInfo objectAtIndex:11]  andReportCallsPosition:[setInfo objectAtIndex:10] andBodyFeelingAnswer:[setInfo objectAtIndex:9] andExtendEmergencyPower:[setInfo objectAtIndex:8] andClassDisable:[setInfo objectAtIndex:7] andTimeSwitchMachine:[setInfo objectAtIndex:6] andRefusedStrangerCalls:[setInfo objectAtIndex:5] andWatchOffAlarm:[setInfo objectAtIndex:4] andWatchCallVoice:[setInfo objectAtIndex:3] andWatchCallVibrate:[setInfo objectAtIndex:2] andWatchInformationSound:[setInfo objectAtIndex:1] andWatchInformationShock:[setInfo objectAtIndex:0] andClassDisabled1:[classStar objectAtIndex:0] andClassDisabled2:[classStar objectAtIndex:1] andClassDisabled3:[classStop objectAtIndex:0] andClassDisabled4:[classStop objectAtIndex:1] andWeekDisabled:[set objectForKey:@"WeekDisabled"] andTimerOpen:[set objectForKey:@"TimerOpen"] andTimerClose:[set objectForKey:@"TimerClose"] andBrightScreen:[set objectForKey:@"BrightScreen"] andweekAlarm1:[set objectForKey:@"WeekAlarm1"] andweekAlarm2:[set objectForKey:@"WeekAlarm2"] andweekAlarm3:[set objectForKey:@"WeekAlarm3"] andalarm1:[set objectForKey:@"Alarm1"] andalarm2:[set objectForKey:@"Alarm2"] andalarm3:[set objectForKey:@"Alarm3"] andlocationMode:[set objectForKey:@"LocationMode"] andlocationTime:[set objectForKey:@"LocationTime"] andflowerNumber:[set objectForKey:@"FlowerNumber"] andStepCalculate:[set objectForKey:@"StepCalculate"] andSleepCalculate:[set objectForKey:@"SleepCalculate"] andHrCalculate:[set objectForKey:@"HrCalculate"] andSosMsgswitch:[set objectForKey:@"SosMsgswitch"] andTimeZone:@"" andLanguage:@"" andDialPad:@"0"];
#pragma mark - 写入位置表
                        NSDictionary *location = [dic objectForKey:@"DeviceState"];
                        [manager addLocationDeviceID:[dic objectForKey:@"DeviceID"] andAltitude:[location objectForKey:@"Altitude"] andCourse:[location objectForKey:@"Course"] andLocationType:[location objectForKey:@"LocationType"] andCreateTime:[location objectForKey:@"CreateTime"] andElectricity:[location objectForKey:@"Electricity"] andGSM:[location objectForKey:@"GSM"] andStep:[location objectForKey:@"Step"] andHealth:[location objectForKey:@"Health"] andLatitude:[location objectForKey:@"Latitude"] andLongitude:[location objectForKey:@"Longitude"] andOnline:[location objectForKey:@"Online"] andSatelliteNumber:[location objectForKey:@"SatelliteNumber"] andServerTime:[location objectForKey:@"ServerTime"] andSpeed:[location objectForKey:@"Speed"] andUpdateTime:[location objectForKey:@"UpdateTime"] andDeviceTime:[location objectForKey:@"DeviceTime"]];
#pragma mark - 写入联系人表

                        NSArray *contact = [dic objectForKey:@"ContactArr"];
                        for(int i = 0; i < contact.count;i++)
                        {
                            NSDictionary *con = [contact objectAtIndex:i];
                            
                            [manager addContactTable:[dic objectForKey:@"BindNumber"] andDeviceContactId:[con objectForKey:@"DeviceContactId"] andRelationship:[con objectForKey:@"Relationship"] andPhoto:[con objectForKey:@"Photo"] andPhoneNumber:[con objectForKey:@"PhoneNumber"] andPhoneShort:[con objectForKey:@"PhoneShort"] andType:[con objectForKey:@"Type"] andObjectId:[con objectForKey:@"ObjectId"] andHeadImg:[con objectForKey:@"HeadImg"]];
                        }
                    }
                    
                    LeftViewController * left = [[LeftViewController alloc]init];
                    CenterViewController * main = [[CenterViewController alloc]init];
                    RightViewController * right = [[RightViewController alloc]init];
                    
                    WWSideslipViewController * slide = [[WWSideslipViewController alloc]initWithLeftView:left andMainView:main andRightView:right andBackgroundImage:nil];
                    
                    [slide setSpeedf:0.5];
                    
                    //点击视图是是否恢复位置
                    slide.sideslipTapGes.enabled = YES;
                    
                    if([defaluts integerForKey:@"resignType"] == 0)
                    {
                        for (UIViewController *controller in self.navigationController.viewControllers) {
                            if ([controller isKindOfClass:[slide class]]) {
                                [self.navigationController popToViewController:controller animated:YES];
                            }
                        }
                    }
                    else if([defaluts integerForKey:@"resignType"] == 1)
                    {
                        [self.navigationController pushViewController:slide animated:YES];
                    }
                }
                else if(ws.tag == 1)
                {
                    //编辑通讯录
                    [manager updataCONTACTSQL:@"contact_tal" andType:@"Photo" andValue:[NSString stringWithFormat:@"%ld",[defaluts integerForKey:@"headType"]] andDeviceConID:conModel.DeviceContactId];
                     [manager updataCONTACTSQL:@"contact_tal" andType:@"Relationship" andValue:[defaluts objectForKey:@"Chenghu"] andDeviceConID:conModel.DeviceContactId];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else if (ws.tag == 3)
                {
                    [self getDeviceList];
                }
                else if (ws.tag == 10)
                {
                    [manager deleContactItem:@"100000000"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshBook" object:self];

                    [self.navigationController popViewControllerAnimated:YES];
                }
                else if (ws.tag == 100)
                {
                    
                    [manager deleContactItem:@"100000000"];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshBook" object:self];
                    
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else if (ws.tag == 20)
                {
                    NSArray *arrays = [object objectForKey:@"Notification"];
                    for(int i = 0; i < arrays.count ;i++)
                    {
                        if([[[arrays objectAtIndex:i] objectForKey:@"DeviceID"] isEqualToString:[defaluts objectForKey:@"AddDeviceID"]])
                        {
                            [YCHUDView hideFromView:self.view animated:YES];

                            [self getDeviceList];
                        }
                    }
                }
            }else if(ws.tag == 1){
                if(code == 2){
                    [OMGToast showWithText:NSLocalizedString(@"send_error_from_device_offline_tips", nil) bottomOffset:50 duration:3];
                }else{
                    [OMGToast showWithText:NSLocalizedString(@"check_device_online_tips", nil) bottomOffset:50 duration:3];
                }
            }
        }
    }
}

- (void)WebServiceGetError:(id)theWebService error:(NSString *)theError{
    [OMGToast showWithText:NSLocalizedString(@"waring_internet_error", nil) bottomOffset:50 duration:3];
}

- (void)requestAgree
{
    
    WebService *webService = [WebService newWithWebServiceAction:@"GetNotification" andDelegate:self];
    webService.tag = 20;
    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaluts objectForKey:@"LoginId"]];
    
    NSArray *parameter = @[loginParameter1];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"GetNotificationResult"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:NO];
}

- (void)setviewinfo
{
   
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)edit:(id)sender {
    
    UIButton *button = sender;
    switch (button.tag) {
        case 0:
        {
            [self.fatherButton setBackgroundImage:[UIImage imageNamed:@"father_pressed"] forState:UIControlStateNormal];
            [self.matherButton setBackgroundImage:[UIImage imageNamed:@"mother_normal"] forState:UIControlStateNormal];
            [self.grandpaButton setBackgroundImage:[UIImage imageNamed:@"grandpa_normal"] forState:UIControlStateNormal];
            [self.grandmaButton setBackgroundImage:[UIImage imageNamed:@"grandma_normal"] forState:UIControlStateNormal];
            [self.grandfatherButton setBackgroundImage:[UIImage imageNamed:@"grandfather_normal"] forState:UIControlStateNormal];
            [self.grandmotherButton setBackgroundImage:[UIImage imageNamed:@"grandmother_normal"] forState:UIControlStateNormal];
            [self.customButton setBackgroundImage:[UIImage imageNamed:@"custom_normal"] forState:UIControlStateNormal];
            [defaluts setObject:self.fatherLabel.text forKey:@"Chenghu"];
            [defaluts setInteger:button.tag + 1 forKey:@"headType"];
            break;
        }
        case 1:
        {
            [self.fatherButton setBackgroundImage:[UIImage imageNamed:@"father_normal"] forState:UIControlStateNormal];
            [self.matherButton setBackgroundImage:[UIImage imageNamed:@"mother_pressed"] forState:UIControlStateNormal];
            [self.grandpaButton setBackgroundImage:[UIImage imageNamed:@"grandpa_normal"] forState:UIControlStateNormal];
            [self.grandmaButton setBackgroundImage:[UIImage imageNamed:@"grandma_normal"] forState:UIControlStateNormal];
            [self.grandfatherButton setBackgroundImage:[UIImage imageNamed:@"grandfather_normal"] forState:UIControlStateNormal];
            [self.grandmotherButton setBackgroundImage:[UIImage imageNamed:@"grandmother_normal"] forState:UIControlStateNormal];
            [self.customButton setBackgroundImage:[UIImage imageNamed:@"custom_normal"] forState:UIControlStateNormal];
            [defaluts setObject:self.motherLabel.text forKey:@"Chenghu"];
            [defaluts setInteger:button.tag + 1 forKey:@"headType"];

            break;
        }
        case 2:
        {
            [self.fatherButton setBackgroundImage:[UIImage imageNamed:@"father_normal"] forState:UIControlStateNormal];
            [self.matherButton setBackgroundImage:[UIImage imageNamed:@"mother_normal"] forState:UIControlStateNormal];
            [self.grandpaButton setBackgroundImage:[UIImage imageNamed:@"grandpa_pressed"] forState:UIControlStateNormal];
            [self.grandmaButton setBackgroundImage:[UIImage imageNamed:@"grandma_normal"] forState:UIControlStateNormal];
            [self.grandfatherButton setBackgroundImage:[UIImage imageNamed:@"grandfather_normal"] forState:UIControlStateNormal];
            [self.grandmotherButton setBackgroundImage:[UIImage imageNamed:@"grandmother_normal"] forState:UIControlStateNormal];
            [self.customButton setBackgroundImage:[UIImage imageNamed:@"custom_normal"] forState:UIControlStateNormal];
            [defaluts setObject:self.grandPaLabel.text forKey:@"Chenghu"];
            [defaluts setInteger:button.tag + 1 forKey:@"headType"];

            break;
        }
        case 3:
        {
            [self.fatherButton setBackgroundImage:[UIImage imageNamed:@"father_normal"] forState:UIControlStateNormal];
            [self.matherButton setBackgroundImage:[UIImage imageNamed:@"mother_normal"] forState:UIControlStateNormal];
            [self.grandpaButton setBackgroundImage:[UIImage imageNamed:@"grandpa_normal"] forState:UIControlStateNormal];
            [self.grandmaButton setBackgroundImage:[UIImage imageNamed:@"grandma_pressed"] forState:UIControlStateNormal];
            [self.grandfatherButton setBackgroundImage:[UIImage imageNamed:@"grandfather_normal"] forState:UIControlStateNormal];
            [self.grandmotherButton setBackgroundImage:[UIImage imageNamed:@"grandmother_normal"] forState:UIControlStateNormal];
            [self.customButton setBackgroundImage:[UIImage imageNamed:@"custom_normal"] forState:UIControlStateNormal];
            [defaluts setObject:self.grandMaLabel.text forKey:@"Chenghu"];
            [defaluts setInteger:button.tag + 1 forKey:@"headType"];

            break;
        }
        case 4:
        {
            [self.fatherButton setBackgroundImage:[UIImage imageNamed:@"father_normal"] forState:UIControlStateNormal];
            [self.matherButton setBackgroundImage:[UIImage imageNamed:@"mother_normal"] forState:UIControlStateNormal];
            [self.grandpaButton setBackgroundImage:[UIImage imageNamed:@"grandpa_normal"] forState:UIControlStateNormal];
            [self.grandmaButton setBackgroundImage:[UIImage imageNamed:@"grandma_normal"] forState:UIControlStateNormal];
            [self.grandfatherButton setBackgroundImage:[UIImage imageNamed:@"grandfather_pressed"] forState:UIControlStateNormal];
            [self.grandmotherButton setBackgroundImage:[UIImage imageNamed:@"grandmother_normal"] forState:UIControlStateNormal];
            [self.customButton setBackgroundImage:[UIImage imageNamed:@"custom_normal"] forState:UIControlStateNormal];
            [defaluts setObject:self.grandfatherLabel.text forKey:@"Chenghu"];
            [defaluts setInteger:button.tag + 1 forKey:@"headType"];

            break;
        }
            
        case 5:
        {
            [self.fatherButton setBackgroundImage:[UIImage imageNamed:@"father_normal"] forState:UIControlStateNormal];
            [self.matherButton setBackgroundImage:[UIImage imageNamed:@"mother_normal"] forState:UIControlStateNormal];
            [self.grandpaButton setBackgroundImage:[UIImage imageNamed:@"grandpa_normal"] forState:UIControlStateNormal];
            [self.grandmaButton setBackgroundImage:[UIImage imageNamed:@"grandma_normal"] forState:UIControlStateNormal];
            [self.grandfatherButton setBackgroundImage:[UIImage imageNamed:@"grandfather_normal"] forState:UIControlStateNormal];
            [self.grandmotherButton setBackgroundImage:[UIImage imageNamed:@"grandmother_pressed"] forState:UIControlStateNormal];
            [self.customButton setBackgroundImage:[UIImage imageNamed:@"custom_normal"] forState:UIControlStateNormal];
            [defaluts setObject:self.grandmotherLabel.text forKey:@"Chenghu"];
            [defaluts setInteger:button.tag + 1 forKey:@"headType"];

            break;
        }
            
        case 6:
        {
            [self.fatherButton setBackgroundImage:[UIImage imageNamed:@"father_normal"] forState:UIControlStateNormal];
            [self.matherButton setBackgroundImage:[UIImage imageNamed:@"mother_normal"] forState:UIControlStateNormal];
            [self.grandpaButton setBackgroundImage:[UIImage imageNamed:@"grandpa_normal"] forState:UIControlStateNormal];
            [self.grandmaButton setBackgroundImage:[UIImage imageNamed:@"grandma_normal"] forState:UIControlStateNormal];
            [self.grandfatherButton setBackgroundImage:[UIImage imageNamed:@"grandfather_normal"] forState:UIControlStateNormal];
            [self.grandmotherButton setBackgroundImage:[UIImage imageNamed:@"grandmother_normal"] forState:UIControlStateNormal];
            [self.customButton setBackgroundImage:[UIImage imageNamed:@"custom_pressed"] forState:UIControlStateNormal];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"edit_name", nil) message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK",nil), nil];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            [defaluts setInteger:button.tag + 1 forKey:@"headType"];
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                        name:@"UITextFieldTextDidChangeNotification"
                                                      object:[alertView textFieldAtIndex:0]];
            [alertView textFieldAtIndex:0].delegate = self;

            [alertView show];

            break;
        }

        default:
            break;
    }
}

-(void)textFiledEditChanged:(NSNotification *)obj{
    UITextField *textField = (UITextField *)obj.object;
    
    NSString *toBeString = textField.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > kMaxLength) {
                textField.text = [toBeString substringToIndex:kMaxLength];
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > kMaxLength) {
            textField.text = [toBeString substringToIndex:kMaxLength];
        }
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        if([alertView textFieldAtIndex:0].text.length == 0)
        {
            [defaluts setObject:NSLocalizedString(@"custom", nil) forKey:@"Chenghu"];
        }
        else
        {
            [defaluts setObject:[alertView textFieldAtIndex:0].text forKey:@"Chenghu"];
            
        }
        self.customLabel.text = [defaluts objectForKey:@"Chenghu"];
        
        [defaluts setInteger:5 forKey:@"resignType"];
        
//        AddNameViewController *vc = [[AddNameViewController alloc] init];
//        vc.title = @"联系人号码";
//        [self.navigationController pushViewController:vc animated:YES];
    }

    
}

//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    self.inputNameTextField.frame = CGRectMake(0, self.view.frame.size.height - height - 30,self.view.frame.size.width, 30);
   }

//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification
{
   
    self.inputNameTextField.hidden = YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
