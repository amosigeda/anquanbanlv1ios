//
//  BabySelectViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//
#import "BabySelectViewController.h"
#import "BabySelectTableViewCell.h"
#import "DataManager.h"
#import "DeviceModel.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "OMGToast.h"
#import "LocationModel.h"
#import "LoginViewController.h"
#import "DeviceSetModel.h"
#import "Constants.h"
#import "CommUtil.h"
#import "MainMapViewController.h"

@interface BabySelectViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *_dataArray;
    DataManager *manager;
    DeviceModel *model;
    NSUserDefaults *defaults;
    NSTimer *timer;
    NSArray *classStar;
    NSArray *classStop;
    NSMutableArray *addd;
    DeviceSetModel *SetModel;
    UIButton* rightBtn;
}
@end

@implementation BabySelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];
    rightBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [rightBtn setTitle:NSLocalizedString(@"edit", nil) forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    rightBtn.frame = CGRectMake(0, 0, 50, 30);
    UIBarButtonItem* rightBtnItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    
    [rightBtn addTarget:self action:@selector(showNext) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setRightBarButtonItem:rightBtnItem];
    
    if([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.taleView.delegate = self;
    self.taleView.dataSource = self;
    self.taleView.rowHeight = 76;
    self.taleView.tableFooterView = [UIView new];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    manager = [DataManager shareInstance];
    addd = [[NSMutableArray alloc] init];
    //    for(int i = 0; i < _dataArray.count;i++){
    //        if(i > 0){
    //            DeviceModel *model1 = [_dataArray objectAtIndex:i-1];
    //            DeviceModel *model2 = [_dataArray objectAtIndex:i];
    //
    //            if(model2.DeviceID.intValue != model1.DeviceID.intValue)
    //            {
    //                [addd addObject:[_dataArray objectAtIndex:i]];
    //            }
    //
    //        } else{
    //            [addd addObject:[_dataArray objectAtIndex:0]];
    //        }
    //    }
    // timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshDevice) userInfo:nil repeats:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [addd removeAllObjects];
    NSArray *deviceArray = [manager isSelect:[defaults objectForKey:@"binnumber"]];
    [addd addObject:deviceArray[0]];
    [self refreshDevice];
    [self.navigationController.navigationBar setHidden:NO];
}

- (void)refreshDevice{
    WebService *webService = [WebService newWithWebServiceAction:@"GetDeviceList" andDelegate:self];
    webService.tag = 0;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"GET" andValue:[NSString stringWithFormat:@"watchAppUser/getBindList/%@",[defaults objectForKey:MAIN_USER_TOKEN]]];
    NSArray *parameter = @[parameter1];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"GetDeviceListResult"];
}

- (void)getDeviceList{
    WebService *webService = [WebService newWithWebServiceAction:@"GetDeviceList" andDelegate:self];
    webService.tag = 3;
    WebServiceParameter *parameter0 = [WebServiceParameter newWithKey:@"GET" andValue:[NSString stringWithFormat:@"watchAppUser/getbindDeviceList/%@",[defaults objectForKey:MAIN_USER_TOKEN]]];
    
    NSArray *parameter = @[parameter0];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"GetDeviceListResult"];
}

-(void)showNext{
    self.taleView.editing = !self.taleView.editing;
    if(self.taleView.editing){
        [rightBtn setTitle:NSLocalizedString(@"finish", nil) forState:UIControlStateNormal];
    }else{
        [rightBtn setTitle:NSLocalizedString(@"edit", nil) forState:UIControlStateNormal];
    }
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
            if(ws.tag == 0){
                if(code == 1){
                    NSArray *array = [object objectForKey:@"List"];
                    [addd removeAllObjects];
                    for (NSDictionary *dict in array) {
                        DeviceModel *deviceModel = [DeviceModel new];
                        deviceModel.DeviceID = [dict objectForKey:@"id"];
                        deviceModel.BindNumber = [dict objectForKey:@"imei"];
                        deviceModel.BabyName = [dict objectForKey:@"name"];
                        [addd addObject:deviceModel];
                    }
                    [self.taleView reloadData];
                }
            }else if(ws.tag == 1){
                [self refreshDevice];
            }else if(ws.tag == 2){
                if(code == 1){
                    [defaults setObject:[object objectForKey:@"LoginId"] forKey:MAIN_USER_LOGIN_ID];
                    [defaults setObject:[object objectForKey:@"UserId"] forKey:MAIN_USER_USER_ID];
                    [defaults setObject:[object objectForKey:@"UserType"] forKey:MAIN_USER_USER_TYPE];
                    [defaults setObject:[object objectForKey:@"Name"] forKey:MAIN_USER_USER_NAME];
                    [defaults setObject:[object objectForKey:@"PhoneNumber"] forKey:MAIN_USER_PHONE_NUMBER];
                    [defaults setObject:[object objectForKey:@"BindNumber"] forKey:MAIN_USER_BIND_NUMBER];
                    [defaults setObject:[object objectForKey:@"token"] forKey:MAIN_USER_TOKEN];
                    [defaults setObject:[object objectForKey:@"phone"] forKey:MAIN_USER_PHONE];
                    [defaults setObject:[object objectForKey:@"ip"] forKey:MAIN_USER_IP];
                    if([[object objectForKey:@"Notification"] isEqualToString:@"True"]){
                        [defaults setObject:@"1" forKey:@"Notification"];
                    }else{
                        [defaults setObject:@"0" forKey:@"Notification"];
                    }
                    if([[object objectForKey:@"NotificationSound"] isEqualToString:@"True"]) {
                        [defaults setObject:@"1" forKey:@"NotificationSound"];
                    }else{
                        [defaults setObject:@"0" forKey:@"NotificationSound"];
                    }
                    if([[object objectForKey:@"NotificationVibration"] isEqualToString:@"True"]){
                        [defaults setObject:@"1" forKey:@"NotificationVibration"];
                    }else{
                        [defaults setObject:@"0" forKey:@"NotificationVibration"];
                    }
                    [defaults setObject:@"1" forKey:@"DMloginScaleKey"];
                    [defaults setObject:[object objectForKey:@"BindNumber"] forKey:@"DMusername"];
                    [defaults setObject:@"" forKey:@"DMpassword"];
                    [self getDeviceList];
                }else{
                    [OMGToast showWithText:NSLocalizedString(@"send_fail", nil) bottomOffset:50 duration:3];
                }
            }else if(ws.tag == 3){
                if(code == 1){
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
                    NSArray *array = [object objectForKey:@"deviceList"];
                    [defaults setObject:[array[0] objectForKey:@"BindNumber"] forKey:@"binnumber"];
                    
                    
                    for(int i =0 ; i < array.count;i++)
                    {
                        NSDictionary *dic  = array[i];
                        [defaults setObject:[dic objectForKey:@"CloudPlatform"] forKey:MAIN_USER_CLOUD_PLAT_FORM];
                        NSArray *deviceArray = [manager isSelect:[dic objectForKey:@"BindNumber"]];
#pragma mark - 写入设备信息表
                        [manager addFavourite:[dic objectForKey:@"ActiveDate"] andBabyName:[dic objectForKey:@"BabyName"] andBindNumber:[dic objectForKey:@"BindNumber"] andDeviceType:[dic objectForKey:@"DeviceType"] andBirthday:[dic objectForKey:@"Birthday"] andCreateTime:[dic objectForKey:@"CreateTime"] andCurrentFirmware:[dic objectForKey:@"CurrentFirmware"] andDeviceID:[dic objectForKey:@"DeviceID"] andDeviceModelID:[dic objectForKey:@"DeviceModelID"] andFirmware:[dic objectForKey:@"Firmware"] andGender:[dic objectForKey:@"Gender"] andGrade:[dic objectForKey:@"Grade"] andHireExpireDate:[dic objectForKey:@"HireExpireDate"] andDate:[dic objectForKey:@"Date"] andHomeAddress:[dic objectForKey:@"HomeAddress"] andHomeLat:[dic objectForKey:@"HomeLat"] andHomeLng:[dic objectForKey:@"HomeLng"] andIsGuard:[dic objectForKey:@"IsGuard"] andPassword:[dic objectForKey:@"Password"] andPhoneCornet:[dic objectForKey:@"PhoneCornet"] andPhoneNumber:[dic objectForKey:@"PhoneNumber"] andPhoto:[dic objectForKey:@"Photo"] andSchoolAddress:[dic objectForKey:@"SchoolAddress"] andSchoolLat:[dic objectForKey:@"SchoolLat"] andSchoolLng:[dic objectForKey:@"SchoolLng"] andSerialNumber:[dic objectForKey:@"SerialNumber"] andUpdateTime:[dic objectForKey:@"UpdateTime"] andUserId:[dic objectForKey:@"UserId"] andSetVersionNO:[dic objectForKey:@"SetVersionNO"]  andContactVersionNO:[dic objectForKey:@"ContactVersionNO"]  andOperatorType:[dic objectForKey:@"OperatorType"]  andSmsNumber:[dic objectForKey:@"SmsNumber"]  andSmsBalanceKey:[dic objectForKey:@"SmsBalanceKey"]  andSmsFlowKey:[dic objectForKey:@"SmsFlowKey"] andLatestTime:[dic objectForKey:@"LatestTime"]];
                        deviceArray = [manager isSelect:[dic objectForKey:@"BindNumber"]];
#pragma mark - 写入设备设置表
                        
                        NSDictionary *set = [dic objectForKey:@"DeviceSet"];
                        NSArray *setInfo = [[set objectForKey:@"SetInfo"] componentsSeparatedByString:@"-"];
                        
                        classStar = [[set objectForKey:@"ClassDisabled1"] componentsSeparatedByString:@"-"];
                        
                        
                        classStop = [[set objectForKey:@"ClassDisabled2"] componentsSeparatedByString:@"-"];
                        
                        NSString* sosMagswitch =[set objectForKey:@"SosMsgswitch"];
                        if ([CommUtil isNotBlank:sosMagswitch]){
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
                    if([[defaults objectForKey:@"DMloginScaleKey"] intValue] == 0){
                        [defaults setObject:@"1" forKey:@"goSowMain"];
                    }
                    [defaults setObject:@"1" forKey:@"DMloginScaleKey"];
                    [self.taleView reloadData];
                    [self.navigationController popViewControllerAnimated:NO];
//                    MainMapViewController *mainMapController = [[MainMapViewController alloc] init];
//                    mainMapController.title = NSLocalizedString(@"main_title", nil);
//                    [self.navigationController pushViewController:mainMapController animated:YES];
                }else{
                    UIWindow *window = [UIApplication sharedApplication].keyWindow;
                    if ([window.rootViewController isKindOfClass:[UINavigationController class]]) {
                        UINavigationController *nav = window.rootViewController;
                        for(UIViewController *controller in nav.viewControllers){
                            if([controller isKindOfClass:[LoginViewController class]]){
                                return;
                            }
                        }
                    }
                    LoginViewController *vc = [[LoginViewController alloc] init];
                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                    [window setRootViewController:nav];
                    [window makeKeyAndVisible];
                    [OMGToast showWithText:NSLocalizedString(@"send_fail", nil) bottomOffset:50 duration:3];
                }
            }else if(code == 1){
                NSArray *array = [object objectForKey:@"deviceList"];
                
                for(int i =0 ; i < array.count;i++)
                {
                    
                    NSDictionary *dic  = [array objectAtIndex:i];
                    
                    if([manager isFavourite:[dic objectForKey:@"BindNumber"]])
                    {
                    }
                    else
                    {
#pragma mark - 写入设备信息表
                        [manager addFavourite:[dic objectForKey:@"ActiveDate"]
                                  andBabyName:[dic objectForKey:@"BabyName"] andBindNumber:[dic objectForKey:@"BindNumber"] andDeviceType:[dic objectForKey:@"DeviceType"] andBirthday:[dic objectForKey:@"Birthday"] andCreateTime:[dic objectForKey:@"CreateTime"] andCurrentFirmware:[dic objectForKey:@"CurrentFirmware"] andDeviceID:[dic objectForKey:@"DeviceID"] andDeviceModelID:[dic objectForKey:@"DeviceModelID"] andFirmware:[dic objectForKey:@"Firmware"] andGender:[dic objectForKey:@"Gender"] andGrade:[dic objectForKey:@"Grade"] andHireExpireDate:[dic objectForKey:@"HireExpireDate"] andDate:[dic objectForKey:@"Date"] andHomeAddress:[dic objectForKey:@"HomeAddress"] andHomeLat:[dic objectForKey:@"HomeLat"] andHomeLng:[dic objectForKey:@"HomeLng"] andIsGuard:[dic objectForKey:@"IsGuard"] andPassword:[dic objectForKey:@"Password"] andPhoneCornet:[dic objectForKey:@"PhoneCornet"] andPhoneNumber:[dic objectForKey:@"PhoneNumber"] andPhoto:[dic objectForKey:@"Photo"] andSchoolAddress:[dic objectForKey:@"SchoolAddress"] andSchoolLat:[dic objectForKey:@"SchoolLat"] andSchoolLng:[dic objectForKey:@"SchoolLng"] andSerialNumber:[dic objectForKey:@"SerialNumber"] andUpdateTime:[dic objectForKey:@"UpdateTime"] andUserId:[dic objectForKey:@"UserId"] andSetVersionNO:[dic objectForKey:@"SetVersionNO"]  andContactVersionNO:[dic objectForKey:@"ContactVersionNO"]  andOperatorType:[dic objectForKey:@"OperatorType"]  andSmsNumber:[dic objectForKey:@"SmsNumber"]  andSmsBalanceKey:[dic objectForKey:@"SmsBalanceKey"]  andSmsFlowKey:[dic objectForKey:@"SmsFlowKey"] andLatestTime:[dic objectForKey:@"LatestTime"] ];
                        
#pragma mark - 写入设备设置表
                        
                        NSDictionary *set = [dic objectForKey:@"DeviceSet"];
                        NSArray *setInfo = [[set objectForKey:@"SetInfo"] componentsSeparatedByString:@"-"];
                        
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
                        
                        _dataArray = [manager getAllFavourie];
                        
                        for(int i = 0; i < _dataArray.count;i++)
                        {
                            if(i > 0)
                            {
                                DeviceModel *model1 = [_dataArray objectAtIndex:i-1];
                                DeviceModel *model2 = [_dataArray objectAtIndex:i];
                                
                                if(model2.DeviceID.intValue != model1.DeviceID.intValue)
                                {
                                    [addd addObject:[_dataArray objectAtIndex:i]];
                                }
                                
                            }
                            else
                            {
                                [addd addObject:[_dataArray objectAtIndex:0]];
                            }
                        }
                        
                    }
                    
                    [self.taleView reloadData];
                }
            }
        }
    }
}

- (void)WebServiceGetError:(id)theWebService error:(NSString *)theError{
    [OMGToast showWithText:NSLocalizedString(@"waring_internet_error", nil) bottomOffset:50 duration:3];
}

- (void)viewDidDisappear:(BOOL)animated{
    if(timer){
        [timer invalidate];
        timer=nil;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return addd.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static  NSString *cell1 = @"babySelect";
    
    UINib *nib = [UINib nibWithNibName:@"BabySelectTableViewCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:cell1];
    
    BabySelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell1];
    if (cell == nil) {
        cell = [[BabySelectTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cell1];
    }
    
    model = [addd objectAtIndex:indexPath.row];
    
    if([model.Photo isEqualToString:@""]){
        cell.headView.image = [UIImage imageNamed:@"user_head_normal"];
    }else{
        [cell.headView setImageWithURL:[NSURL URLWithString:model.Photo]];
    }
    
    if(model.BabyName.length){
        cell.nameLabel.text = model.BabyName;
    }else{
        cell.nameLabel.text = model.BindNumber;
    }
    if([model.BindNumber isEqualToString:[defaults objectForKey:@"binnumber"]]){
        cell.gouView.hidden = NO;
        
    }else{
        cell.gouView.hidden = YES;
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DeviceModel *deviceModel = [addd objectAtIndex:indexPath.row];
    if(![deviceModel.BindNumber isEqualToString:[defaults objectForKey:@"binnumber"]]){
        WebService *webService = [WebService newWithWebServiceAction:@"SwitchDevice" andDelegate:self];
        webService.tag = 2;
        WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"GET" andValue:[NSString stringWithFormat:@"watchAppUser/switchDevice/%@",deviceModel.BindNumber]];
        NSArray *parameter = @[parameter1];
        // webservice请求并获得结
        
        webService.webServiceParameter = parameter;
        [webService getWebServiceResult:@"SwitchDeviceResult"];
    }
    //
    //    SetModel = [[manager isSelectDeviceSetTable:model.BindNumber] objectAtIndex:0];
    //    [defaults setObject:SetModel.TimeZone forKey:@"currentTimezone"];
    //    [defaults setObject:SetModel.Language forKey:@"currentLanguage"];
    //
    //    [defaults setObject:model.SmsBalanceKey forKey:@"huafei"];
    //    [defaults setObject:model.SmsFlowKey forKey:@"liuliang"];
    //
    //    [defaults setObject:model.BindNumber forKey:@"binnumber"];
    //    [defaults setObject:model.DeviceID forKey:@"loginDeviceID"];
    //
    //    NSMutableArray *time = [manager isSelectLocationTable:model.DeviceID];
    //    LocationModel *Locmodel = [time objectAtIndex:0];
    //    [defaults setObject:Locmodel.ServerTime forKey:@"ServerTime"];
    //    [defaults setObject:Locmodel.Latitude  forKey:@"Latitude"];
    //    [defaults setObject:Locmodel.Longitude forKey:@"Longitude"];
    //    [defaults setObject:Locmodel.LocationType forKey:@"LocationType"];
    //    BabySelectTableViewCell *cell = [self.taleView cellForRowAtIndexPath:indexPath];
    //    cell.gouView.hidden = NO;
    //    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeHeadImage" object:self];
    //    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    DeviceModel *deviceModel = [addd objectAtIndex:indexPath.row];
    return ![deviceModel.BindNumber isEqualToString:[defaults objectForKey:@"binnumber"]];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    DeviceModel *deviceModel = [addd objectAtIndex:indexPath.row];
    WebService *webService = [WebService newWithWebServiceAction:@"DeleteDevice" andDelegate:self];
    webService.tag = 1;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"GET" andValue:[NSString stringWithFormat:@"watchAppUser/deletebindDeviceById/%@/%@",[defaults objectForKey:MAIN_USER_TOKEN],deviceModel.DeviceID]];
    NSArray *parameter = @[parameter1];
    // webservice请求并获得结
    
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"DeleteDeviceResult"];
    [addd removeObjectAtIndex:indexPath.row];
    [self.taleView reloadData];
}

- (void)setviewinfo{
    [self.navigationController popViewControllerAnimated:YES];
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
