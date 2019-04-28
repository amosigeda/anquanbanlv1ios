//
//  AddWatchTextViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//
#import "AddWatchTextViewController.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "OMGToast.h"
#import "EditHeadAndNameViewController.h"
#import "WWSideslipViewController.h"
#import "LeftViewController.h"
#import "RightViewController.h"
#import "CenterViewController.h"
#import "LoginViewController.h"
#import "YCHUDView.h"
#import "DataManager.h"
#import "NSString+Tools.h"

@interface AddWatchTextViewController ()<UITextFieldDelegate,UIAlertViewDelegate>
{
    NSUserDefaults *defaults;
    // UIAlertView *alertView;
    NSTimer *refreshDeviceTimer;
    DataManager *manager;
}
@end

@implementation AddWatchTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    manager = [DataManager shareInstance];
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    self.bindIng.backgroundColor = MCN_buttonColor;
    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    self.ok_Btn.backgroundColor = MCN_buttonColor;
    self.cancel_Btn.backgroundColor = MCN_buttonColor;
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];
    
    if([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.IMEITextField.delegate = self;
    self.input_TextField.delegate = self;
    
    self.IMEITextField.placeholder = NSLocalizedString(@"input_bind_number", nil);
    
    if([defaults integerForKey:@"deviceModelType"] == 1)
    {
        self.list_Label.text = NSLocalizedString(@"binding_list_d8", nil);
    }
    else{
        self.list_Label.text = NSLocalizedString(@"binding_list", nil);
    }
    [self.bindIng setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
    self.prolist_Label.text = NSLocalizedString(@"prompt", nil);
    self.pc_List_Label.text = NSLocalizedString(@"input_name", nil);
    [self.cancel_Btn setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [self.ok_Btn setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
    self.bgView.layer.cornerRadius = 10;
    self.bgView.layer.masksToBounds = YES;
    
}

- (void)setviewinfo
{
    [self.navigationController popViewControllerAnimated:YES];
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

- (IBAction)addWatch:(id)sender {
    
    if(![self.IMEITextField.text isValidateIMEI:self.IMEITextField.text]){
        [OMGToast showWithText:NSLocalizedString(@"enter_right_serial_number", nil) bottomOffset:50 duration:2];
        return;
    }else{
        [self.navigationController popViewControllerAnimated:NO];
        if(self.SYQRCodeSuncessBlock){
            self.SYQRCodeSuncessBlock(nil, self.IMEITextField.text);
        }
        [self.IMEITextField resignFirstResponder];
    }
    //    WebService *webService = [WebService newWithWebServiceAction:@"LinkDeviceCheck" andDelegate:self];
    //    webService.tag = 0;
    //    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
    //    WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"bindNumber" andValue:self.IMEITextField.text];
    //
    //    NSArray *parameter = @[loginParameter1, loginParameter2];
    //    // webservice请求并获得结果
    //    webService.webServiceParameter = parameter;
    //    [webService getWebServiceResult:@"LinkDeviceCheckResult"];
}

- (void)getDeviceList
{
    WebService *webService = [WebService newWithWebServiceAction:@"GetDeviceList" andDelegate:self];
    webService.tag = 2;
    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
    
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
                    [defaults setObject:self.IMEITextField.text forKey:@"bindNumber"];
                    [defaults setObject:[object objectForKey:@"DeviceId"] forKey:@"AddDeviceID"];
                    
                    EditHeadAndNameViewController *edit = [[EditHeadAndNameViewController alloc] init];
                    [defaults setInteger:1 forKey:@"editWatch"];
                    [self.navigationController pushViewController:edit animated:YES];
                }
                else if (ws.tag == 3 )
                {
                    //
                    [OMGToast showWithText:NSLocalizedString([object objectForKey:@"Message"], nil)  bottomOffset:50 duration:2];
                    [YCHUDView setOnView:self.view withTitle:NSLocalizedString(@"wait_admin_confirm", nil) andTime:1.0 withType:@"1" animated:YES];
                    
                    refreshDeviceTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(requestAgree) userInfo:nil repeats:YES];
                    
                }
                else if (ws.tag == 20)
                {
                    NSArray *arrays = [object objectForKey:@"Notification"];
                    for(int i = 0; i < arrays.count ;i++)
                    {
                        if([[[arrays objectAtIndex:i] objectForKey:@"Type"] isEqualToString:@"3"])
                        {
                            [YCHUDView hideFromView:self.view animated:YES];
                            
                            [self getDeviceList];
                            [refreshDeviceTimer invalidate];
                        }
                    }
                }
                else if ( ws.tag == 2)
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
                    //                    if(![defaults objectForKey:@"binnumber"] || [[defaults objectForKey:@"binnumber"] isEqualToString:@""])
                    //                    {
                    [defaults setObject:[[array objectAtIndex:0] objectForKey:@"BindNumber"] forKey:@"binnumber"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeHeadImage" object:self];
                    
                    //                    }
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
                    NSLog(@"%ld",[defaults integerForKey:@"resignType"]);
                    
                    if([defaults integerForKey:@"resignType"] == 0)
                    {
                        for (UIViewController *controller in self.navigationController.viewControllers) {
                            if ([controller isKindOfClass:[slide class]]) {
                                [self.navigationController popToViewController:controller animated:YES];
                            }
                        }
                    }
                    else if([defaults integerForKey:@"resignType"] == 1)
                    {
                        [self.navigationController pushViewController:slide animated:YES];
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
            else if (code == 2)
            {
                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
                {
                    UIAlertView * alertViews = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"input_name", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
                    alertViews.alertViewStyle = UIAlertViewStylePlainTextInput;
                    [alertViews show];
                }
                else
                {
                    self.bgView.hidden = NO;
                }
            }
            else if(code == 5)
            {
                [OMGToast showWithText:NSLocalizedString([object objectForKey:@"Message"], nil)  bottomOffset:50 duration:2];
                [YCHUDView setOnView:self.view withTitle:NSLocalizedString(@"wait_admin_confirm", nil) andTime:1.0 withType:@"1" animated:YES];
                
                refreshDeviceTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(requestAgree) userInfo:nil repeats:YES];
            }
            
            else if (code == 0)
            {
                // [OMGToast showWithText:NSLocalizedString(@"登陆异常", nil) bottomOffset:50 duration:3];
                LoginViewController *vc = [[LoginViewController alloc] init];
                for (UIViewController *controller in self.navigationController.viewControllers) {
                    if ([controller isKindOfClass:[vc class]]) {
                        [self.navigationController popToViewController:controller animated:YES];
                    }
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
    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
    
    NSArray *parameter = @[loginParameter1];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"GetNotificationResult"];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        WebService *webService = [WebService newWithWebServiceAction:@"LinkDevice" andDelegate:self];
        webService.tag = 3;
        WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
        
        WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"name" andValue:[NSString stringWithFormat:@"%@",[alertView textFieldAtIndex:0].text]];
        WebServiceParameter *loginParameter4 = [WebServiceParameter newWithKey:@"bindNumber" andValue:self.IMEITextField.text];
        WebServiceParameter *loginParameter5 = [WebServiceParameter newWithKey:@"language" andValue:[defaults objectForKey:@"currentLanguage_phone"]];
        WebServiceParameter *loginParameter6 = [WebServiceParameter newWithKey:@"timeZone" andValue:[defaults objectForKey:@"currentTimezone"]];
        
        NSArray *parameter = @[loginParameter1,loginParameter3,loginParameter4,loginParameter5,loginParameter6];
        // webservice请求并获得结果
        webService.webServiceParameter = parameter;
        [webService getWebServiceResult:@"LinkDeviceResult"];
    }
}

- (IBAction)cacel_Action:(id)sender {
    
    self.bgView.hidden = YES;
    
}

- (IBAction)comfire_Action:(id)sender {
    
    WebService *webService = [WebService newWithWebServiceAction:@"LinkDevice" andDelegate:self];
    webService.tag = 3;
    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
    
    WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"name" andValue:[NSString stringWithFormat:@"%@",self.input_TextField.text]];
    WebServiceParameter *loginParameter4 = [WebServiceParameter newWithKey:@"bindNumber" andValue:self.IMEITextField.text];
    WebServiceParameter *loginParameter5 = [WebServiceParameter newWithKey:@"language" andValue:[defaults objectForKey:@"currentLanguage"]];
    WebServiceParameter *loginParameter6 = [WebServiceParameter newWithKey:@"timeZone" andValue:[defaults objectForKey:@"currentTimezone"]];
    
    NSArray *parameter = @[loginParameter1,loginParameter3,loginParameter4,loginParameter5,loginParameter6];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"LinkDeviceResult"];
    [self.input_TextField resignFirstResponder];
    self.bgView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController.navigationBar setHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
