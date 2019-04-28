//
//  SoundAndVibrationViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//
#import "SoundAndVibrationViewController.h"
#import "WatchSetTableViewCell.h"
#import "DataManager.h"
#import "DeviceSetModel.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "Constants.h"
#import "JSON.h"
#import "OMGToast.h"

extern BOOL is_D8_show;
@interface SoundAndVibrationViewController ()<UITableViewDataSource,UITableViewDelegate,WebServiceProtocol>
{
    DataManager *manager;
    NSUserDefaults *defaults;
    NSArray *seciton1Array;
    DeviceSetModel *model;
    NSMutableArray *array;
}
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@end

@implementation SoundAndVibrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    self.saveBtn.backgroundColor = MCN_buttonColor;
    seciton1Array = [[NSArray alloc] initWithObjects:NSLocalizedString(@"sound", nil),NSLocalizedString(@"vibrate", nil),nil];
    
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableHeaderView.hidden = YES;
    self.tableView.tableFooterView = [UIView new];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    manager = [DataManager shareInstance];
    
    array =   [manager isSelectDeviceSetTable:[defaults objectForKey:@"binnumber"]];
    
    model = [array objectAtIndex:0];
    
    [defaults setObject:model.WatchCallVoice forKey:@"watchCallSound"];
    [defaults setObject:model.WatchCallVibrate forKey:@"watchCallVib"];
    [defaults setObject:model.WatchInformationSound forKey:@"watchInmatSound"];
    [defaults setObject:model.WatchInformationShock forKey:@"watchInmatVib"];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(1)
    {
        return 1;

    }
    else{
        return 2;
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(is_D8_show==YES)
    {
        if(section == 0)
        {
            return NSLocalizedString(@"watch_call_d8", nil);
        }
        
        else
            return NSLocalizedString(@"watch_msg_d8", nil);
    }
    else{
        if(section == 0)
        {
            return NSLocalizedString(@"watch_call", nil);
        }
        
        else
            return NSLocalizedString(@"watch_msg", nil);
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
//每个分组上边预留的空白高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return 28;
    }
    else
        return 15;
}
//每个分组下边预留的空白高度
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static  NSString *cell1 = @"watchSet";
    
    UINib *nib = [UINib nibWithNibName:@"WatchSetTableViewCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:cell1];
    
    WatchSetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell1];
    if (cell == nil) {
        cell = [[WatchSetTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cell1];
    }
    if (indexPath.section == 0) {
        if(indexPath.row == 0)
        {
            if([model.WatchCallVoice isEqualToString:@"1"])
            {
                cell.OnOff.on = YES;
            }
            else
            {
                cell.OnOff.on = NO;
            }
            cell.OnOff.tag = 8;
            
        }
        else if(indexPath.row == 1)
        {
            if([model.WatchCallVibrate isEqualToString:@"1"])
            {
                cell.OnOff.on = YES;
            }
            else
            {
                cell.OnOff.on = NO;
            }
            cell.OnOff.tag = 9;
        }
    }
    else
    {
        if(indexPath.row == 0)
        {
            if([model.WatchInformationSound isEqualToString:@"1"])
            {
                cell.OnOff.on = YES;
            }
            else
            {
                cell.OnOff.on = NO;
            }
            cell.OnOff.tag = 15;
        }
        else
        {
            if([model.WatchInformationShock isEqualToString:@"1"])
            {
                cell.OnOff.on = YES;
            }
            else
            {
                cell.OnOff.on = NO;
            }
            cell.OnOff.tag = 16;

        }
    }
    [cell.OnOff addTarget:self action:@selector(ONOFF:) forControlEvents:UIControlEventValueChanged];
    
    cell.titleLabel.text = [seciton1Array objectAtIndex:indexPath.row];
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)ONOFF:(UISwitch *)sw
{
    UISwitch *swi = sw;
    if(swi.tag == 8)
    {
        if(swi.isOn == YES)
        {
            [defaults setObject:@"1" forKey:@"watchCallSound"];
        }
        else
        {
            [defaults setObject:@"0" forKey:@"watchCallSound"];

        }
    }
    else if(swi.tag == 9)
    {
        if(swi.isOn == YES)
        {
            [defaults setObject:@"1" forKey:@"watchCallVib"];
        }
        else
        {
            [defaults setObject:@"0" forKey:@"watchCallVib"];
        }

    }
    else if(swi.tag == 15)
    {
        if(swi.isOn == YES)
        {
            [defaults setObject:@"1" forKey:@"watchInmatSound"];
        }
        else
        {
            [defaults setObject:@"0" forKey:@"watchInmatSound"];
        }
        
    }
    else if(swi.tag == 16)
    {
        if(swi.isOn == YES)
        {
            [defaults setObject:@"1" forKey:@"watchInmatVib"];
        }
        else
        {
            [defaults setObject:@"0" forKey:@"watchInmatVib"];
        }
    }
}

- (void)setviewinfo{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:NO];
    
  }

- (IBAction)saveButn:(id)sender {
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
    WebServiceParameter *parameter8 = [WebServiceParameter newWithKey:@"flowerNumber" andValue:[defaults objectForKey:@"Flower_Num"]];
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
                    [manager updataSQL:@"device_set" andType:@"WatchCallVoice" andValue:[defaults objectForKey:@"watchCallSound"] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"WatchCallVibrate" andValue:[defaults objectForKey:@"watchCallVib"] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"WatchInformationSound" andValue:[defaults objectForKey:@"watchInmatSound"] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"WatchInformationShock" andValue:[defaults objectForKey:@"watchInmatVib"] andBindle:[defaults objectForKey:@"binnumber"]];
                    [OMGToast showWithText:NSLocalizedString(@"save_suc", nil) bottomOffset:50 duration:3];
                    [self.navigationController popViewControllerAnimated:YES];
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
