//
//  LoginViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//
#import "SVProgressHUD.h"
#import "SYQRCodeViewController.h"
#import "KKSequenceImageView.h"
#import "CommUtil.h"
#import "LoginViewController.h"
#import "WWSideslipViewController.h"
#import "LeftViewController.h"
#import "RightViewController.h"
#import "CenterViewController.h"
#import "ResignOneViewController.h"
#import "ForgetOneViewController.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "OMGToast.h"
#import "JSON.h"
#import "DataManager.h"
#import "SYQRCodeViewController.h"
#import "EditHeadAndNameViewController.h"
#import "GMDCircleLoader.h"
#import "UserModel.h"
#import "NSString+Tools.h"
#import "AppDelegate.h"
#import "ViewUtils.h"
#import <CloudPushSDK/CloudPushSDK.h>

BOOL is_forget_show;
@interface LoginViewController ()<WebServiceProtocol,UITextFieldDelegate,UIAlertViewDelegate>
{
    NSUserDefaults *defaults;
    NSArray *classStar;
    NSArray *classStop;
    UIAlertView *aletView;
    NSMutableArray *deviceArray;
    BOOL isShow;
    int height;
    
}



@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"login", nil);
    if([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    DataManager* data = [DataManager shareInstance];
    //    [self animationImageTwo];
    
    UserModel* model = [UserModel sharedUserInstance];
    model.isLogin = NO;
    defaults = [NSUserDefaults standardUserDefaults];
    self.loginBtn.backgroundColor = [UIColor whiteColor];
    //    self.resignButton.isHidden = YES;
    self.userTextfield.delegate = self;
    self.passwordTextField.delegate = self;
    [self.loginBtn setTintColor:[UIColor orangeColor]];
    [self.userTextfield setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.passwordTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    isShow = NO;
    self.userTextfield.text = [defaults objectForKey:@"DMusername"];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
    {
        self.passwordTextField.text = [defaults objectForKey:@"DMpassword"];
        
    }
    else
    {
        if([defaults integerForKey:@"loginType"] == 0)
        {
            self.passwordTextField.text = @"";
        }
        else
        {
            self.passwordTextField.text = [defaults objectForKey:@"DMpassword"];
        }
    }
    
    if([[defaults objectForKey:@"passType"] intValue] == 0)
    {
        self.passwordTextField.text = @"";
        
    }
    height = self.view.frame.size.height;
    
    //使用NSNotificationCenter 鍵盤出現時
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWasShown:)
     
                                                 name:UIKeyboardDidShowNotification object:nil];
    //使用NSNotificationCenter 鍵盤隐藏時
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWillBeHidden:)
     
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    
    [self.forgotButton setTitle:NSLocalizedString(@"forget_password", nil) forState:UIControlStateNormal];
    //    [self.resignButton setTitle:NSLocalizedString(@"reg", nil) forState:UIControlStateNormal];
    [self.loginBtn setTitle:NSLocalizedString(@"login", nil) forState:UIControlStateNormal];
    self.userTextfield.placeholder = NSLocalizedString(@"input_login_name", nil);
    self.passwordTextField.placeholder = NSLocalizedString(@"input_password", nil);
    self.loginTips.text = NSLocalizedString(@"login_account_tips", nil);
    [ViewUtils cutCircleWithView:self.loginBtn radius:5 borderWidth:1 borderColor:[UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1]];
    [ViewUtils cutCircleWithView:self.inputView radius:5 borderWidth:1 borderColor:[UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1]];
    [CloudPushSDK unbindAccount:^(CloudPushCallbackResult *res) {
        if (res.success) {
            NSLog(@"unbindAccount success");
        } else {
            NSLog(@"unbindAccount failed, error: %@", res.error);
        }
    }];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
//        self.view.frame = CGRectMake(self.view.frame.origin.x, -100, self.view.frame.size.width,height);
}

//当键盘隐藏的时候
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
//        self.view.frame = CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width, height);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender {
    
    [self.passwordTextField resignFirstResponder];
    [self.userTextfield resignFirstResponder];
    if(![self.userTextfield.text isValidateIMEI:self.userTextfield.text]){
        [OMGToast showWithText:NSLocalizedString(@"login_username_len_error_tips", nil) bottomOffset:50 duration:1];
        [GMDCircleLoader hideFromView:self.view animated:YES];
        return;
    }
    //判断密码不为空
    else if(self.passwordTextField.text.length == 0){
        [OMGToast showWithText:NSLocalizedString(@"input_password", nil) bottomOffset:50 duration:1];
        [GMDCircleLoader hideFromView:self.view animated:YES];
        return; 
    }
    
    WebService *webService = [WebService newWithWebServiceAction:@"Login" andDelegate:self];
    webService.tag = 0;
    WebServiceParameter *loginParameter0 = [WebServiceParameter newWithKey:@"POST" andValue:@"watchAppUser/login"];
    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"tel" andValue:self.userTextfield.text];
    WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"pwd" andValue:self.passwordTextField.text];
    //    WebServiceParameter *loginParameter0 = [WebServiceParameter newWithKey:@"POST" andValue:@"location/getlocationInfo"];
    //    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"lat" andValue:@"39.908692"];
    //    WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"lng" andValue:@"116.397477"];
    //    WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"mapType" andValue:@"1"];
    //    WebServiceParameter *loginParameter4 = [WebServiceParameter newWithKey:@"token" andValue:@"3BC8770257099A85F3EF13F5C349D685"];
    
    NSArray *parameter = @[loginParameter0, loginParameter1, loginParameter2];
    // webservice请求并获得结
    [GMDCircleLoader setOnView:self.view withTitle:NSLocalizedString(@"load", nil) animated:YES];
    self.loginBtn.enabled = NO;
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"LoginResult"];
    IsCheckPhoneNumberDialogShown=false;
}

- (IBAction)doResign:(id)sender {
    
    ResignOneViewController *resign = [[ResignOneViewController alloc] init];
    [defaults setInteger:0 forKey:@"reforType"];
    
    resign.title = NSLocalizedString(@"reg", nil);
    [self.navigationController pushViewController:resign animated:YES];
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
            
            if(ws.tag == 0)
            {
                if(code == 1)
                {
                    [defaults setObject:[object objectForKey:@"LoginId"] forKey:MAIN_USER_LOGIN_ID];
                    [defaults setObject:[object objectForKey:@"UserId"] forKey:MAIN_USER_USER_ID];
                    [defaults setObject:[object objectForKey:@"UserType"] forKey:MAIN_USER_USER_TYPE];
                    [defaults setObject:[object objectForKey:@"Name"] forKey:MAIN_USER_USER_NAME];
                    [defaults setObject:[object objectForKey:@"PhoneNumber"] forKey:MAIN_USER_PHONE_NUMBER];
                    [defaults setObject:[object objectForKey:@"BindNumber"] forKey:MAIN_USER_BIND_NUMBER];
                    [defaults setObject:[object objectForKey:@"token"] forKey:MAIN_USER_TOKEN];
                    [defaults setObject:[object objectForKey:@"phone"] forKey:MAIN_USER_PHONE];
                    [defaults setObject:[object objectForKey:@"ip"] forKey:MAIN_USER_IP];
                    if([[object objectForKey:@"Notification"] isEqualToString:@"True"])
                    {
                        [defaults setObject:@"1" forKey:@"Notification"];
                    }
                    else
                    {
                        [defaults setObject:@"0" forKey:@"Notification"];
                    }
                    
                    if([[object objectForKey:@"NotificationSound"] isEqualToString:@"True"])
                    {
                        [defaults setObject:@"1" forKey:@"NotificationSound"];
                    }
                    else
                    {
                        [defaults setObject:@"0" forKey:@"NotificationSound"];
                    }
                    
                    if([[object objectForKey:@"NotificationVibration"] isEqualToString:@"True"])
                    {
                        [defaults setObject:@"1" forKey:@"NotificationVibration"];
                    }
                    else
                    {
                        [defaults setObject:@"0" forKey:@"NotificationVibration"];
                    }
                    [defaults setObject:@"1" forKey:@"DMloginScaleKey"];
                    [self getDeviceList];
                }else{
                    self.loginBtn.enabled = YES;
                    [GMDCircleLoader hideFromView:self.view animated:YES];
                    if(code == 2){
                        [OMGToast showWithText:NSLocalizedString(@"login_info_error", nil) bottomOffset:50 duration:3];
                    }else if(code == -1){
                        [OMGToast showWithText:NSLocalizedString(@"login_imei_error_tips", nil) bottomOffset:50 duration:3];
                    }else{
                        [OMGToast showWithText:NSLocalizedString(@"login_error_tips", nil) bottomOffset:50 duration:3];
                    }
                }
                
            }//
            else if (ws.tag == 1)//设备信息
            {
                DataManager *manager = [DataManager shareInstance];
                [manager createDeviceTable];
                [manager createContactTable];
                //                [manager createFriendListTable];
                [manager createDeviceSetTable];
                [manager createAudioTable];
                [manager createMessageRecord];
                [manager createShortMessage];
                [manager dropLocation];
                [manager createLocation];
                [manager createLocationCache];
                
                if(code == 1)
                {
                    [GMDCircleLoader hideFromView:self.view animated:YES];
                    NSArray *array = [object objectForKey:@"deviceList"];
                    
                    [defaults setObject:[array[0] objectForKey:@"BindNumber"] forKey:@"binnumber"];
                    
                    
                    for(int i =0 ; i < array.count;i++)
                    {
                        NSDictionary *dic  = array[i];
                        [defaults setObject:[dic objectForKey:@"CloudPlatform"] forKey:MAIN_USER_CLOUD_PLAT_FORM];
                        deviceArray = [manager isSelect:[dic objectForKey:@"BindNumber"]];
#pragma mark - 写入设备信息表
                        [manager addFavourite:[dic objectForKey:@"ActiveDate"] andBabyName:[dic objectForKey:@"BabyName"] andBindNumber:[dic objectForKey:@"BindNumber"] andDeviceType:[dic objectForKey:@"DeviceType"] andBirthday:[dic objectForKey:@"Birthday"] andCreateTime:[dic objectForKey:@"CreateTime"] andCurrentFirmware:[dic objectForKey:@"CurrentFirmware"] andDeviceID:[dic objectForKey:@"DeviceID"] andDeviceModelID:[dic objectForKey:@"DeviceModelID"] andFirmware:[dic objectForKey:@"Firmware"] andGender:[dic objectForKey:@"Gender"] andGrade:[dic objectForKey:@"Grade"] andHireExpireDate:[dic objectForKey:@"HireExpireDate"] andDate:[dic objectForKey:@"Date"] andHomeAddress:[dic objectForKey:@"HomeAddress"] andHomeLat:[dic objectForKey:@"HomeLat"] andHomeLng:[dic objectForKey:@"HomeLng"] andIsGuard:[dic objectForKey:@"IsGuard"] andPassword:[dic objectForKey:@"Password"] andPhoneCornet:[dic objectForKey:@"PhoneCornet"] andPhoneNumber:[dic objectForKey:@"PhoneNumber"] andPhoto:[dic objectForKey:@"Photo"] andSchoolAddress:[dic objectForKey:@"SchoolAddress"] andSchoolLat:[dic objectForKey:@"SchoolLat"] andSchoolLng:[dic objectForKey:@"SchoolLng"] andSerialNumber:[dic objectForKey:@"SerialNumber"] andUpdateTime:[dic objectForKey:@"UpdateTime"] andUserId:[dic objectForKey:@"UserId"] andSetVersionNO:[dic objectForKey:@"SetVersionNO"]  andContactVersionNO:[dic objectForKey:@"ContactVersionNO"]  andOperatorType:[dic objectForKey:@"OperatorType"]  andSmsNumber:[dic objectForKey:@"SmsNumber"]  andSmsBalanceKey:[dic objectForKey:@"SmsBalanceKey"]  andSmsFlowKey:[dic objectForKey:@"SmsFlowKey"] andLatestTime:[dic objectForKey:@"LatestTime"]];
                        deviceArray = [manager isSelect:[dic objectForKey:@"BindNumber"]];
#pragma mark - 写入设备设置表
                        
                        NSDictionary *set = [dic objectForKey:@"DeviceSet"];
                        NSArray *setInfo = [[set objectForKey:@"SetInfo"] componentsSeparatedByString:@"-"];
                        
                        classStar = [[set objectForKey:@"ClassDisabled1"] componentsSeparatedByString:@"-"];
                        
                        
                        classStop = [[set objectForKey:@"ClassDisabled2"] componentsSeparatedByString:@"-"];
                        
                        NSString* sosMagswitch =[set objectForKey:@"SosMsgswitch"];
                        if ([CommUtil isNotBlank:sosMagswitch]) {
                            sosMagswitch = [set objectForKey:@"SosMsgswitch"];
                        }else
                        {
                            sosMagswitch = @"1";
                            
                        }
                        
                        [manager addDeviceSetTable:[dic objectForKey:@"BindNumber"]  andVersionNumber:nil andAutoAnswer:[setInfo objectAtIndex:11]  andReportCallsPosition:[setInfo objectAtIndex:10] andBodyFeelingAnswer:[setInfo objectAtIndex:9] andExtendEmergencyPower:[setInfo objectAtIndex:8] andClassDisable:[setInfo objectAtIndex:7] andTimeSwitchMachine:[setInfo objectAtIndex:6] andRefusedStrangerCalls:[setInfo objectAtIndex:5] andWatchOffAlarm:[setInfo objectAtIndex:4] andWatchCallVoice:[setInfo objectAtIndex:3] andWatchCallVibrate:[setInfo objectAtIndex:2] andWatchInformationSound:[setInfo objectAtIndex:1] andWatchInformationShock:[setInfo objectAtIndex:0] andClassDisabled1:[classStar objectAtIndex:0] andClassDisabled2:[classStar objectAtIndex:1] andClassDisabled3:[classStop objectAtIndex:0] andClassDisabled4:[classStop objectAtIndex:1] andWeekDisabled:[set objectForKey:@"WeekDisabled"] andTimerOpen:[set objectForKey:@"TimerOpen"] andTimerClose:[set objectForKey:@"TimerClose"] andBrightScreen:[set objectForKey:@"BrightScreen"] andweekAlarm1:[set objectForKey:@"WeekAlarm1"] andweekAlarm2:[set objectForKey:@"WeekAlarm2"] andweekAlarm3:[set objectForKey:@"WeekAlarm3"] andalarm1:[set objectForKey:@"Alarm1"] andalarm2:[set objectForKey:@"Alarm2"] andalarm3:[set objectForKey:@"Alarm3"] andlocationMode:[set objectForKey:@"LocationMode"] andlocationTime:[set objectForKey:@"LocationTime"] andflowerNumber:[set objectForKey:@"FlowerNumber"] andStepCalculate:[set objectForKey:@"StepCalculate"] andSleepCalculate:[set objectForKey:@"SleepCalculate"] andHrCalculate:[set objectForKey:@"HrCalculate"] andSosMsgswitch:
                         sosMagswitch andTimeZone:@"" andLanguage:@"" andDialPad:[set objectForKey:@"dialPad"]];
                        
#pragma mark - 写入联系人表
                        
                        NSArray *contact = [dic objectForKey:@"ContactArr"];
                        for(int i = 0; i < contact.count;i++)
                        {
                            NSDictionary *con = [contact objectAtIndex:i];
                            
                            [manager addContactTable:[dic objectForKey:@"BindNumber"] andDeviceContactId:[con objectForKey:@"DeviceContactId"] andRelationship:[con objectForKey:@"Relationship"] andPhoto:[con objectForKey:@"Photo"] andPhoneNumber:[con objectForKey:@"PhoneNumber"] andPhoneShort:[con objectForKey:@"PhoneShort"] andType:[con objectForKey:@"Type"] andObjectId:[con objectForKey:@"ObjectId"] andHeadImg:[con objectForKey:@"HeadImg"]];
                        }
                        
#pragma mark - 写入位置表
                        NSDictionary *location = [dic objectForKey:@"DeviceState"];
                        [manager addLocationDeviceID:[dic objectForKey:@"DeviceID"] andAltitude:[location objectForKey:@"Altitude"] andCourse:[location objectForKey:@"Course"] andLocationType:[location objectForKey:@"LocationType"] andCreateTime:[location objectForKey:@"CreateTime"] andElectricity:[location objectForKey:@"Electricity"] andGSM:[location objectForKey:@"GSM"] andStep:[location objectForKey:@"Step"] andHealth:[location objectForKey:@"Health"] andLatitude:[location objectForKey:@"Latitude"] andLongitude:[location objectForKey:@"Longitude"] andOnline:[location objectForKey:@"Online"] andSatelliteNumber:[location objectForKey:@"SatelliteNumber"] andServerTime:[location objectForKey:@"ServerTime"] andSpeed:[location objectForKey:@"Speed"] andUpdateTime:[location objectForKey:@"UpdateTime"] andDeviceTime:[location objectForKey:@"DeviceTime"]];
                    }
                    self.loginBtn.enabled = YES;
                    
                    [GMDCircleLoader hideFromView:self.view animated:YES];
                    [defaults setObject:self.userTextfield.text forKey:@"DMusername"];
                    [defaults setObject:self.passwordTextField.text forKey:@"DMpassword"];
                    UIWindow *window = [UIApplication sharedApplication].keyWindow;
                    if ([window.rootViewController isKindOfClass:[UINavigationController class]]) {
                        UINavigationController *nav = window.rootViewController;
                        for(UIViewController *controller in nav.viewControllers){
                            if([controller isKindOfClass:[RDVTabBarController class]]){
                                return;
                            }
                        }
                    }
                    RDVTabBarController *tabBarController = [AppDelegate setupViewControllers];
                    [window setRootViewController:tabBarController];
                    [window makeKeyAndVisible];
                    if([[defaults objectForKey:@"DMloginScaleKey"] intValue] == 0){
                        [defaults setObject:@"1" forKey:@"goSowMain"];
                    }
                    [defaults setObject:@"1" forKey:@"DMloginScaleKey"];
                    
                    
                    //                    LeftViewController * left = [[LeftViewController alloc]init];
                    //                    CenterViewController * main = [[CenterViewController alloc]init];
                    //                    RightViewController * right = [[RightViewController alloc]init];
                    //
                    //                    WWSideslipViewController * slide = [[WWSideslipViewController alloc]initWithLeftView:left andMainView:main andRightView:right andBackgroundImage:nil];
                    //
                    //                    [slide setSpeedf:0.5];
                    //
                    //                    //点击视图是是否恢复位置
                    //                    slide.sideslipTapGes.enabled = YES;
                    //                    if([[defaults objectForKey:@"DMloginScaleKey"] intValue] == 0)
                    //                    {
                    //                        [defaults setObject:@"1" forKey:@"goSowMain"];
                    //                    }
                    //
                    //                    [defaults setObject:@"1" forKey:@"DMloginScaleKey"];
                    //                    [self.navigationController pushViewController:slide animated:YES];
                }else if(code == 2){
                    self.loginBtn.enabled = YES;
                    [GMDCircleLoader hideFromView:self.view animated:YES];
                    UIAlertView *view = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"add_equipment", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
                    [defaults setInteger:1 forKey:@"resignType"];
                    
                    [defaults setValue:@"2" forKey:@"editWatch"];
                    view.tag = 0;
                    [view show];
                }
            }
            else if(ws.tag == 2)
            {
                self.loginBtn.enabled = YES;
                
                [GMDCircleLoader hideFromView:self.view animated:YES];
                if(code == 1)
                {
                    EditHeadAndNameViewController *edit = [[EditHeadAndNameViewController alloc] init];
                    [defaults setInteger:2 forKey:@"editWatch"];
                    
                    [self.navigationController pushViewController:edit animated:YES];
                    
                }
                else if(code == 4)
                {
                    
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else if (code == 3)
                {
                    [self.navigationController popViewControllerAnimated:YES];
                    
                }
                else if (code == 2)
                {
                    aletView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"input_name", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
                    aletView.alertViewStyle = UIAlertViewStylePlainTextInput;
                    aletView.tag = 1;
                    [aletView show];
                }
            }
            
            else if (ws.tag == 5)
            {
                self.loginBtn.enabled = YES;
                
                [self.navigationController popViewControllerAnimated:YES];
            }
//            if (code != 1){
//                self.loginBtn.enabled = YES;
//                [GMDCircleLoader hideFromView:self.view animated:YES];
//                if (code==-2) {
//                    [OMGToast showWithText:NSLocalizedString(@"have_unbind", nil)  bottomOffset:50 duration:2];
//                }else
//                {
//                    [OMGToast showWithText:NSLocalizedString([object objectForKey:@"Message"], nil)  bottomOffset:50 duration:2];
//                }
//
//
//
//            }
            
        }
    }
}

- (IBAction)showPassword:(id)sender {
    
    if (isShow == NO) {
        [self.showPasswordBtn setBackgroundImage:[UIImage imageNamed:@"show_pass_pressed"] forState:UIControlStateNormal];
        self.passwordTextField.secureTextEntry = NO;
        isShow = YES;
    }
    else
    {
        [self.showPasswordBtn setBackgroundImage:[UIImage imageNamed:@"show_pass_normal"] forState:UIControlStateNormal];
        self.passwordTextField.secureTextEntry = YES;
        
        isShow = NO;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        if(alertView.tag == 0)
        {
            [defaults setInteger:0 forKey:@"edit"];
            
            SYQRCodeViewController *qrcodevc = [[SYQRCodeViewController alloc] init];
            qrcodevc.title =NSLocalizedString(@"scan", nil);
            qrcodevc.SYQRCodeSuncessBlock = ^(SYQRCodeViewController *aqrvc,NSString *qrString){
                
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
                webService.tag = 2;
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
        else if (alertView.tag == 1)
        {
            WebService *webService = [WebService newWithWebServiceAction:@"LinkDevice" andDelegate:self];
            webService.tag = 5;
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
}

- (void)getDeviceList{
    WebService *webService = [WebService newWithWebServiceAction:@"GetDeviceList" andDelegate:self];
    webService.tag = 1;
    WebServiceParameter *parameter0 = [WebServiceParameter newWithKey:@"GET" andValue:[NSString stringWithFormat:@"watchAppUser/getbindDeviceList/%@",[defaults objectForKey:MAIN_USER_TOKEN]]];
    
    NSArray *parameter = @[parameter0];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"GetDeviceListResult"];
}

- (void)WebServiceGetError:(id)theWebService error:(NSString *)theError{
    self.loginBtn.enabled = YES;
    [GMDCircleLoader hideFromView:self.view animated:YES];
    [OMGToast showWithText:NSLocalizedString(@"waring_internet_error", nil) bottomOffset:50 duration:3];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (IBAction)forgotAction:(id)sender {
    ForgetOneViewController *vc = [[ForgetOneViewController alloc] init];
    
    [defaults setInteger:1 forKey:@"reforType"];
    is_forget_show=YES;
    vc.title = NSLocalizedString(@"forget_password", nil);
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_userTextfield resignFirstResponder];
    [_passwordTextField resignFirstResponder];
}
- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],UITextAttributeTextColor,nil]];
    is_forget_show=NO;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
    {
        self.passwordTextField.text = [defaults objectForKey:@"DMpassword"];
        
    }
    else
    {
        if([defaults integerForKey:@"loginType"] == 0)
        {
            self.passwordTextField.text = @"";
        }
        else
        {
            self.passwordTextField.text = [defaults objectForKey:@"DMpassword"];
        }
        
        
    }
    
    if([[defaults objectForKey:@"passType"] intValue] == 0)
    {
        self.passwordTextField.text = @"";
        
    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


- (IBAction)QRCodeAction:(id)sender
{
    is_forget_show = YES;
    SYQRCodeViewController* syq = [[SYQRCodeViewController alloc]init];
    //扫描结果
    syq.SYQRCodeSuncessBlock = ^(SYQRCodeViewController *aqrvc,NSString *qrString)
    {
        
        [syq.navigationController popViewControllerAnimated:YES];
        if ([qrString isValidateIMEI:qrString]){
            
            NSLog(@"%@",qrString);
            [_userTextfield setText:qrString];
            is_forget_show = NO;
        }else{
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"input_login_IMEIError", nil)];
        }
    };
    //扫描失败
    syq.SYQRCodeFailBlock = ^(SYQRCodeViewController * syqrcode){
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"scans_error", nil)];
        [syq dismissViewControllerAnimated:NO completion:nil];
        NSLog(@"扫描失败");
    };
    //扫描取消
    syq.SYQRCodeCancleBlock = ^(SYQRCodeViewController *syqrcode)
    {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"scan_cancellation", nil)];
        [syq dismissViewControllerAnimated:NO completion:nil];
        NSLog(@"扫描取消");
    };
    [self.navigationController pushViewController:syq animated:YES];
}

-(void)animationImageTwo
{
    DataManager* data = [DataManager shareInstance];
    if (data.isLogin)
    {
        data.isLogin = false;
        UIWindow* win =  [UIApplication sharedApplication].keyWindow;
        KKSequenceImageView* imageView = [[KKSequenceImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        NSMutableArray* images = [NSMutableArray array];
        for (int i = 1; i <= 50; i++) {
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
        [win addSubview:imageView];
        [imageView begin];
        __weak typeof (self)weakSelf = self;
        
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)((((int)imageView.durationMS)/1000.0)/*延迟执行时间*/ * NSEC_PER_SEC));
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            
            //        [UIView animateWithDuration:1 animations:^{
            //
            ////            imageView.alpha = 0;
            //        } completion:^(BOOL finished)
            //        {
            
            [imageView removeFromSuperview];
            //        [weakSelf otherOperations];
            //        }];
            
        });
    }
}
@end
