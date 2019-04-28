//
//  FlowersRewardViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "FlowersRewardViewController.h"
#import "LightTimeTableViewCell.h"
#import "DataManager.h"
#import "DeviceSetModel.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "Constants.h"
#import "JSON.h"
#import "OMGToast.h"

@interface FlowersRewardViewController ()<UITableViewDataSource,UITableViewDelegate,WebServiceProtocol>
{
    DataManager *manager;
    NSArray *titleArray;
    NSMutableArray *array;
    DeviceSetModel *model;
    NSUserDefaults *defaults;
    NSIndexPath *_indexPath;
}
@end

@implementation FlowersRewardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];
    
    titleArray = [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"0%@",NSLocalizedString(@"red_flowers_num", nil)],[NSString stringWithFormat:@"1%@",NSLocalizedString(@"red_flowers_num", nil)],[NSString stringWithFormat:@"2%@",NSLocalizedString(@"red_flowers_num", nil)],[NSString stringWithFormat:@"3%@",NSLocalizedString(@"red_flowers_num", nil)],[NSString stringWithFormat:@"4%@",NSLocalizedString(@"red_flowers_num", nil)],[NSString stringWithFormat:@"5%@",NSLocalizedString(@"red_flowers_num", nil)], nil];
    
    self.tableVIew.delegate = self;
    self.tableVIew.dataSource = self;
    self.tableVIew.rowHeight = 40;
    self.tableVIew.tableFooterView = [UIView new];
    defaults = [NSUserDefaults standardUserDefaults];
    
    manager = [DataManager shareInstance];
    array =   [manager isSelectDeviceSetTable:[defaults objectForKey:@"binnumber"]];
    model = [array objectAtIndex:0];
    [defaults setObject:model.flowerNumber forKey:@"Flower_Num"];
    if(model.flowerNumber.length == 0)
    {
        [defaults setObject:@"0" forKey:@"Flower_Num"];
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static  NSString *cell1 = @"cell1";
    
    UINib *nib = [UINib nibWithNibName:@"LightTimeTableViewCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:cell1];
    
    LightTimeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell1];
    if (cell == nil) {
        cell = [[LightTimeTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cell1];
    }
    cell.titleLabel.text = [titleArray objectAtIndex:indexPath.row];
    cell.gouImage.hidden = YES;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self.tableVIew reloadData];
    LightTimeTableViewCell *cell = [self.tableVIew cellForRowAtIndexPath:indexPath];
    cell.gouImage.hidden = NO;
    
    if(indexPath.row == 0){
        [defaults setObject:@"0" forKey:@"Flower_Num"];
    }
    else if(indexPath.row == 1){
        [defaults setObject:@"1" forKey:@"Flower_Num"];
    }
    else if(indexPath.row == 2){
        [defaults setObject:@"2" forKey:@"Flower_Num"];
    }
    else if(indexPath.row == 3){
        [defaults setObject:@"3" forKey:@"Flower_Num"];
    }else if(indexPath.row == 4){
        [defaults setObject:@"4" forKey:@"Flower_Num"];
    }else if(indexPath.row == 5){
        [defaults setObject:@"5" forKey:@"Flower_Num"];
    }else{
        [defaults setObject:@"1" forKey:@"Flower_Num"];
    }
    array =   [manager isSelectDeviceSetTable:[defaults objectForKey:@"binnumber"]];
    model = [array objectAtIndex:0];
    [defaults setObject:model.BrightScreen forKey:@"lightTime"];
    [defaults setObject:model.AutoAnswer forKey:@"AutoAnswer"];
    [defaults setObject:model.ReportCallsPosition forKey:@"ReportCallsPosition"];
    [defaults setObject:model.BodyFeelingAnswer forKey:@"BodyFeelingAnswer"];
    [defaults setObject:model.ExtendEmergencyPower forKey:@"ExtendEmergencyPower"];
    [defaults setObject:model.ClassDisable forKey:@"ClassDisable"];
    [defaults setObject:model.TimeSwitchMachine forKey:@"TimeSwitchMachine"];
    [defaults setObject:model.RefusedStrangerCalls forKey:@"RefusedStrangerCalls"];
    [defaults setObject:model.WatchOffAlarm forKey:@"WatchOffAlarm"];
    [defaults setObject:model.WatchCallVoice forKey:@"watchCallSound"];
    [defaults setObject:model.WatchCallVibrate forKey:@"watchCallVib"];
    [defaults setObject:model.WatchInformationSound forKey:@"watchInmatSound"];
    [defaults setObject:model.WatchInformationShock forKey:@"watchInmatVib"];
    [defaults setObject:model.locationMode forKey:@"Dingwei_Mode"];
    [defaults setObject:model.locationTime forKey:@"Dingwei_Time"];
    [defaults setObject:model.SosMsgswitch forKey:@"SosMsgswitch"];
    
    if(model.locationMode.length == 0)
    {
        [defaults setObject:@"1" forKey:@"Dingwei_Mode"];
    }
    if(model.locationTime.length == 0)
    {
        [defaults setObject:@"0" forKey:@"Dingwei_Time"];
    }
    NSString *str = [NSString stringWithFormat:@"%@-%@-%@-%@-%@-%@-%@-%@-%@-%@-%@-%@",[defaults objectForKey:@"watchInmatVib"],[defaults objectForKey:@"watchInmatSound"],[defaults objectForKey:@"watchCallVib"],[defaults objectForKey:@"watchCallSound"],[defaults objectForKey:@"WatchOffAlarm"],[defaults objectForKey:@"RefusedStrangerCalls"],[defaults objectForKey:@"TimeSwitchMachine"],[defaults objectForKey:@"ClassDisable"],[defaults objectForKey:@"ExtendEmergencyPower"],[defaults objectForKey:@"BodyFeelingAnswer"],[defaults objectForKey:@"ReportCallsPosition"],[defaults objectForKey:@"AutoAnswer"]];
    WebService *webService = [WebService newWithWebServiceAction:@"UpdateDeviceSet" andDelegate:self];
    webService.tag = 0;
    
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"POST" andValue:@"watchset/set"];
    WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"token" andValue:[defaults objectForKey:MAIN_USER_TOKEN]];
    WebServiceParameter *parameter3 = [WebServiceParameter newWithKey:@"imei" andValue:[defaults objectForKey:@"binnumber"]];
    WebServiceParameter *parameter4 = [WebServiceParameter newWithKey:@"setInfo" andValue:str];
    WebServiceParameter *parameter5 = [WebServiceParameter newWithKey:@"brightScreen" andValue:[defaults objectForKey:@"lightTime"]];
    WebServiceParameter *parameter6 = [WebServiceParameter newWithKey:@"language" andValue:@""];
    WebServiceParameter *parameter7 = [WebServiceParameter newWithKey:@"timeZone" andValue:@""];
    WebServiceParameter *parameter8 = [WebServiceParameter newWithKey:@"flowerNumber" andValue:[NSString stringWithFormat:@"%ld",indexPath.row]];
    WebServiceParameter *parameter9 = [WebServiceParameter newWithKey:@"locationMode" andValue:[defaults objectForKey:@"Dingwei_Mode"]];
    WebServiceParameter *parameter10 = [WebServiceParameter newWithKey:@"locationTime" andValue:[defaults objectForKey:@"Dingwei_Time"]];
    WebServiceParameter *parameter11 = [WebServiceParameter newWithKey:@"sosMsgswitch" andValue:[defaults objectForKey:@"SosMsgswitch"]];
    WebServiceParameter *parameter12 = [WebServiceParameter newWithKey:@"infoVibration" andValue:[defaults objectForKey:@"watchInmatVib"]];
    WebServiceParameter *parameter13 = [WebServiceParameter newWithKey:@"infoVoice" andValue:[defaults objectForKey:@"watchInmatSound"]];
    WebServiceParameter *parameter14 = [WebServiceParameter newWithKey:@"phoneComeVibration" andValue:[defaults objectForKey:@"watchCallVib"]];
    WebServiceParameter *parameter15 = [WebServiceParameter newWithKey:@"phoneComeVoice" andValue:[defaults objectForKey:@"watchCallSound"]];
    WebServiceParameter *parameter16 = [WebServiceParameter newWithKey:@"watchOffAlarm" andValue:[defaults objectForKey:@"WatchOffAlarm"]];
    WebServiceParameter *parameter17 = [WebServiceParameter newWithKey:@"rejectStrangers" andValue:[defaults objectForKey:@"RefusedStrangerCalls"]];
    WebServiceParameter *parameter18 = [WebServiceParameter newWithKey:@"timerSwitch" andValue:[defaults objectForKey:@"TimeSwitchMachine"]];
    WebServiceParameter *parameter19 = [WebServiceParameter newWithKey:@"disabledInClass" andValue:[defaults objectForKey:@"ClassDisable"]];
    WebServiceParameter *parameter20 = [WebServiceParameter newWithKey:@"reserveEmergencyPower" andValue:[defaults objectForKey:@"ExtendEmergencyPower"]];
    WebServiceParameter *parameter21 = [WebServiceParameter newWithKey:@"somatosensory" andValue:[defaults objectForKey:@"BodyFeelingAnswer"]];
    WebServiceParameter *parameter22 = [WebServiceParameter newWithKey:@"reportCallLocation" andValue:[defaults objectForKey:@"ReportCallsPosition"]];
    WebServiceParameter *parameter23 = [WebServiceParameter newWithKey:@"automaticAnswering" andValue:[defaults objectForKey:@"AutoAnswer"]];
    
    NSArray *parameter = @[parameter1, parameter2,parameter3,parameter4,parameter5,parameter6,parameter7,parameter8,parameter9,parameter10,parameter11,parameter12,parameter13,parameter14,parameter15,parameter16,parameter17,parameter18,parameter19,parameter20,parameter21,parameter22,parameter23];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"UpdateDeviceSetResult"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
//    defaults = [NSUserDefaults standardUserDefaults];
//
//    DataManager *manager = [DataManager shareInstance];
//
//    array =   [manager isSelectDeviceSetTable:[defaults objectForKey:@"binnumber"]];
//
//    model = [array objectAtIndex:0];
//
//    [defaults setObject:model.flowerNumber forKey:@"Flower_Num"];
    
}

- (void)setviewinfo
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)WebServiceGetCompleted:(id)theWebService{
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
                    [manager updataSQL:@"device_set" andType:@"flowerNumber" andValue:[defaults objectForKey:@"Flower_Num"] andBindle:[defaults objectForKey:@"binnumber"]];
                    [OMGToast showWithText:NSLocalizedString(@"flower_send_success_tips", nil) bottomOffset:50 duration:3];
                }else if(code == 2){
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
