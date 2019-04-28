//
//  WatchSetViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//
#import "Constants.h"
#import "CommUtil.h"
#import "DXAlertView.h"
#import "WatchSetViewController.h"
#import "WatchSetTableViewCell.h"
#import "WatchSetThreeTableViewCell.h"
#import "WatchSetTwoTableViewCell.h"
#import "SoundAndVibrationViewController.h"
#import "LightTimeViewController.h"
#import "GotoSchoolViewController.h"
#import "OpenAndCloseViewController.h"
#import "DataManager.h"
#import "DeviceSetModel.h"
#import "DeviceModel.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "OMGToast.h"
#import "WatchSetFourTableViewCell.h"
#import "LoginViewController.h"
#import "IQActionSheetPickerView.h"
#import "WatchSetAlarmViewController.h"
#import "OperateModeViewController.h"
#import "FlowersRewardViewController.h"
#import "SchoolGuardianViewController.h"
#import "EditHeadAndNameViewController.h"
#import "UserModel.h"

extern BOOL is_D8_show;

@interface WatchSetViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,IQActionSheetPickerViewDelegate>
{
    NSUserDefaults *defaults;
    NSArray *seciton1Array;
    NSArray *seciton2Array;
    NSArray *seciton3Array;
    NSArray *seciton4Array;
    DeviceSetModel *model;
    NSMutableArray *array;
    NSArray *setArray;
    NSMutableArray *deviceArray;
    DeviceModel *deviceModel;
    DataManager *manager ;
    NSString *str;
    BOOL isTuoluo;
    BOOL isGsensor;
    BOOL isOneShow;
    BOOL isFlower;
}
@end

@implementation WatchSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    defaults = [NSUserDefaults standardUserDefaults];
    array = [[NSMutableArray alloc ] init];
    deviceArray = [[NSMutableArray alloc] init];
    self.saveBtn.backgroundColor = MCN_buttonColor;
    [defaults setObject:@"0" forKey:@"showRight"];
    [defaults setObject:@"1" forKey:@"showLeft"];
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    self.saveBtn.backgroundColor = MCN_buttonColor;
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
    
    [self.saveBtn setTitle:NSLocalizedString(@"save", nil) forState:UIControlStateNormal];
    
    [self initDatas];
    [defaults setObject:model.BrightScreen forKey:@"lightTime"];
    
    if([[deviceModel.DeviceModelID substringFromIndex:deviceModel.DeviceModelID.length - 1] intValue] ==1)
    {
        isTuoluo = YES;
    }
    else{
        isTuoluo = NO;
    }
    
    if(([deviceModel.CurrentFirmware rangeOfString:@"D10_CHUANGMT"].location != NSNotFound)||([deviceModel.CurrentFirmware rangeOfString:@"D9_CHUANGMT"].location != NSNotFound)||([deviceModel.DeviceType isEqualToString:@"2"])||([deviceModel.CurrentFirmware rangeOfString:@"D9_TP_CHUANGMT"].location != NSNotFound)||([deviceModel.CurrentFirmware rangeOfString:@"D12_CHUANGMT"].location != NSNotFound))
    {
        isGsensor = NO;
    }
    else{
        isGsensor = YES;
    }
    
    if(([deviceModel.CurrentFirmware rangeOfString:@"D9_LED_CHUANGMT"].location != NSNotFound))
    {
        isFlower = NO;
    }
    else
    {
        isFlower = YES;
    }
    
    if([deviceModel.DeviceType isEqualToString:@"2"])
    {
        self.list_Label.text = NSLocalizedString(@"watch_setting_PS_d8", nil);
        seciton1Array = [[NSArray alloc] initWithObjects:NSLocalizedString(@"automatic_answer", nil),NSLocalizedString(@"report_call_location", nil),NSLocalizedString(@"somatosensory_answer", nil),NSLocalizedString(@"reserved_power", nil),NSLocalizedString(@"bright_time", nil),NSLocalizedString(@"sound_vibrate", nil), NSLocalizedString(@"refused_stranger", nil),NSLocalizedString(@"watch_off_alarm_d8", nil),nil];
    }
    else{
        self.list_Label.text = NSLocalizedString(@"watch_setting_PS", nil);
        seciton1Array = [[NSArray alloc] initWithObjects:NSLocalizedString(@"automatic_answer", nil),NSLocalizedString(@"report_call_location", nil),NSLocalizedString(@"somatosensory_answer", nil),NSLocalizedString(@"reserved_power", nil),NSLocalizedString(@"bright_time", nil),NSLocalizedString(@"sound_vibrate", nil), NSLocalizedString(@"refused_stranger", nil),NSLocalizedString(@"watch_off_alarm", nil),nil];
    }
    
    seciton2Array = [[NSArray alloc] initWithObjects:NSLocalizedString(@"only_receive_family_calls", nil),NSLocalizedString(@"working_days_list", nil),nil];
    seciton3Array = [[NSArray alloc] initWithObjects:NSLocalizedString(@"emergency_power", nil),NSLocalizedString(@"class_disabled", nil),NSLocalizedString(@"timing_starting", nil),nil];
    seciton4Array = [[NSArray alloc] initWithObjects:NSLocalizedString(@"clock_setting", nil),NSLocalizedString(@"operating_mode", nil),NSLocalizedString(@"red_flowers_reward", nil),nil];
    [self getDeviceSet];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController.navigationBar setHidden:NO];
    [self initDatas];
    [self.tableView reloadData];
    if([[defaults objectForKey:@"watchInmatVib"] intValue]  == model.WatchInformationShock.intValue && [[defaults objectForKey:@"watchInmatSound"] intValue]  == model.WatchInformationSound.intValue && [[defaults objectForKey:@"watchCallVib"] intValue]  == model.WatchCallVibrate.intValue && [[defaults objectForKey:@"watchCallSound"] intValue]  == model.WatchCallVoice.intValue && [[defaults objectForKey:@"WatchOffAlarm"] intValue]  == model.WatchOffAlarm.intValue && [[defaults objectForKey:@"RefusedStrangerCalls"] intValue]  == model.RefusedStrangerCalls.intValue && [[defaults objectForKey:@"TimeSwitchMachine"] intValue]  == model.TimeSwitchMachine.intValue && [[defaults objectForKey:@"ClassDisable"] intValue]  == model.ClassDisable.intValue && [[defaults objectForKey:@"ExtendEmergencyPower"] intValue]  == model.ExtendEmergencyPower.intValue && [[defaults objectForKey:@"BodyFeelingAnswer"] intValue]  == model.BodyFeelingAnswer.intValue&& [[defaults objectForKey:@"SosMsgswitch"] intValue]  == model.SosMsgswitch.intValue && [[defaults objectForKey:@"ReportCallsPosition"] intValue]  == model.ReportCallsPosition.intValue && [[defaults objectForKey:@"AutoAnswer"] intValue]  == model.AutoAnswer.intValue && [[defaults objectForKey:@"lightTime"] intValue] == model.BrightScreen.intValue&& [[defaults objectForKey:@"Dingwei_Time"] intValue] == model.locationTime.intValue&& [[defaults objectForKey:@"Flower_Num"] intValue] == model.flowerNumber.intValue&& [[defaults objectForKey:@"Dingwei_Mode"] intValue] == model.locationMode.intValue)
    {
        
        self.saveBtn.enabled = NO;
    }
    else
    {
        self.saveBtn.enabled = YES;
        
    }
}

-(void)initDatas{
    array = [manager isSelectDeviceSetTable:[defaults objectForKey:@"binnumber"]];
    model = [array objectAtIndex:0];
    
    deviceArray = [manager isSelect:[defaults objectForKey:@"binnumber"]];
    
    deviceModel = [deviceArray objectAtIndex:0];
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
    [defaults setObject:model.flowerNumber forKey:@"Flower_Num"];
    [defaults setObject:model.SosMsgswitch forKey:@"SosMsgswitch"];
    if(model.dialPad.length){
        [defaults setObject:model.dialPad forKey:@"dialPad"];
    }else{
        [defaults setObject:@"0" forKey:@"dialPad"];
    }
    
    if(model.locationMode.length == 0)
    {
        [defaults setObject:@"1" forKey:@"Dingwei_Mode"];
    }
    if(model.locationTime.length == 0)
    {
        [defaults setObject:@"0" forKey:@"Dingwei_Time"];
    }
    
    if(deviceModel.CurrentFirmware.length==0)
    {
        deviceModel.CurrentFirmware=@"00000000";
    }
    
    if(model.SosMsgswitch.length == 0)
    {
        [defaults setObject:@"0" forKey:@"SosMsgswitch"];
        model.SosMsgswitch=@"0";
    }
    
    [self.tableView reloadData];
}

-(void)getDeviceSet{
    WebService *webService = [WebService newWithWebServiceAction:@"GetDeviceSet" andDelegate:self];
    webService.tag = 1;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"GET" andValue:[NSString stringWithFormat:@"watchset/getDeviceSet/%@/%@",[defaults objectForKey:MAIN_USER_TOKEN],[defaults objectForKey:@"binnumber"]]];
    NSArray *parameter = @[parameter1];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"GetDeviceSetResult"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 6;
        //        if(isGsensor)
        //        {
        //            return 5;
        //        }
        //        else
        //        {
        //            return 4;
        //        }
    }
    else if(section == 1)
    {
        return 6;
        //        if(isTuoluo)
        //        {
        //            return 6;
        //        }
        //        else
        //        {
        //            if(is_D8_show)
        //            {
        //                return 4;
        //            }
        //            else{
        //                return 5;
        //            }
        //        }
    }
    else if(section == 2)
    {
        return 2;
        //        if(is_D8_show)
        //        {
        //            return 1;
        //        }
        //        else{
        //            return 2;
        //        }
    }
    else
    {
        return 2;
        //        if(is_D8_show)
        //        {
        //            return 4;
        //        }
        //        else if(isFlower==NO)
        //        {
        //            return 4;
        //        }
        //        else{
        //            return 5;
        //        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return NSLocalizedString(@"personal_talk", nil);
    }
    else if(section == 1)
    {
        return NSLocalizedString(@"remote_control", nil);
    }
    else if(section == 2)
    {
        return NSLocalizedString(@"sound_display", nil);
    }
    else
        return NSLocalizedString(@"grade_l", nil);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
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

- (void)setviewinfo
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        
        static  NSString *cell1 = @"watchSetOne";
        
        UINib *nib = [UINib nibWithNibName:@"WatchSetTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:cell1];
        
        WatchSetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell1];
        if (cell == nil) {
            cell = [[WatchSetTableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:cell1];
        }
        
        cell.titleLabel.text = [seciton1Array objectAtIndex:indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if(indexPath.row == 1){
            if([model.ReportCallsPosition isEqualToString:@"1"])
            {
                cell.OnOff.on = YES;
            }
            else
            {
                cell.OnOff.on = NO;
            }
            cell.OnOff.tag = 2;
            
        }else if(indexPath.row == 2){
            if([model.BodyFeelingAnswer isEqualToString:@"1"])
            {
                cell.OnOff.on = YES;
            }
            else
            {
                cell.OnOff.on = NO;
            }
            cell.OnOff.tag = 3;
            
        }else if(indexPath.row == 0){
            if([model.AutoAnswer isEqualToString:@"1"])
            {
                cell.OnOff.on = YES;
            }
            else
            {
                cell.OnOff.on = NO;
            }
            cell.OnOff.tag = 1;
        }else if(indexPath.row == 4){
            cell.titleLabel.text = [NSString stringWithFormat:@"%@",NSLocalizedString(@"Watch_set_sos", nil)];
            if([model.SosMsgswitch isEqualToString:@"0"])
            {
                cell.OnOff.on = NO;
            }
            else
            {
                cell.OnOff.on = YES;
            }
            cell.OnOff.tag = 9;
        }else if(indexPath.row == 5){
            cell.titleLabel.text = NSLocalizedString(@"watch_setting_keyboard", nil);
            if([model.dialPad isEqualToString:@"1"])
            {
                cell.OnOff.on = YES;
            }
            else
            {
                cell.OnOff.on = NO;
            }
            cell.OnOff.tag = 10;
        }else{
            if([model.ExtendEmergencyPower isEqualToString:@"1"])
            {
                cell.OnOff.on = YES;
            }
            else
            {
                cell.OnOff.on = NO;
            }
            cell.OnOff.tag = 4;
        }
        [cell.OnOff addTarget:self action:@selector(ONOFF:) forControlEvents:UIControlEventValueChanged];
        return cell;
        
        //        if(isGsensor)
        //        {
        //            cell.titleLabel.text = [seciton1Array objectAtIndex:indexPath.row];
        //            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //            if(indexPath.row == 1)
        //            {
        //                if([model.ReportCallsPosition isEqualToString:@"1"])
        //                {
        //                    cell.OnOff.on = YES;
        //                }
        //                else
        //                {
        //                    cell.OnOff.on = NO;
        //                }
        //                cell.OnOff.tag = 2;
        //
        //            }
        //            else if(indexPath.row == 2)
        //            {
        //                if([model.BodyFeelingAnswer isEqualToString:@"1"])
        //                {
        //                    cell.OnOff.on = YES;
        //                }
        //                else
        //                {
        //                    cell.OnOff.on = NO;
        //                }
        //                cell.OnOff.tag = 3;
        //
        //            }
        //            else if(indexPath.row == 0)
        //            {
        //                if([model.AutoAnswer isEqualToString:@"1"])
        //                {
        //                    cell.OnOff.on = YES;
        //                }
        //                else
        //                {
        //                    cell.OnOff.on = NO;
        //                }
        //                cell.OnOff.tag = 1;
        //            }
        //            else if(indexPath.row == 4)
        //            {
        //                cell.titleLabel.text = [NSString stringWithFormat:@"%@",NSLocalizedString(@"Watch_set_sos", nil)];
        //                if([model.SosMsgswitch isEqualToString:@"0"])
        //                {
        //                    cell.OnOff.on = NO;
        //                }
        //                else
        //                {
        //                    cell.OnOff.on = YES;
        //                }
        //                cell.OnOff.tag = 9;
        //            }
        //            else
        //            {
        //                if([model.ExtendEmergencyPower isEqualToString:@"1"])
        //                {
        //                    cell.OnOff.on = YES;
        //                }
        //                else
        //                {
        //                    cell.OnOff.on = NO;
        //                }
        //                cell.OnOff.tag = 4;
        //            }
        //            [cell.OnOff addTarget:self action:@selector(ONOFF:) forControlEvents:UIControlEventValueChanged];
        //            return cell;
        //        }
        //        else
        //        {
        //            cell.titleLabel.text = [NSString stringWithFormat:@"%@",NSLocalizedString(@"report_call_location", nil)];
        //            if(indexPath.row == 1)
        //            {
        //                if([model.ReportCallsPosition isEqualToString:@"1"])
        //                {
        //                    cell.OnOff.on = YES;
        //                }
        //                else
        //                {
        //                    cell.OnOff.on = NO;
        //                }
        //                cell.OnOff.tag = 2;
        //
        //            }
        //            else if(indexPath.row == 2)
        //            {
        //                cell.titleLabel.text = [NSString stringWithFormat:@"%@",NSLocalizedString(@"reserved_power", nil)];
        //                if([model.ExtendEmergencyPower isEqualToString:@"1"])
        //                {
        //                    cell.OnOff.on = YES;
        //                }
        //                else
        //                {
        //                    cell.OnOff.on = NO;
        //                }
        //                cell.OnOff.tag = 4;
        //            }
        //            else if(indexPath.row == 3)
        //            {
        //                cell.titleLabel.text = [NSString stringWithFormat:@"%@",NSLocalizedString(@"Watch_set_sos", nil)];
        //                if([model.SosMsgswitch isEqualToString:@"0"])
        //                {
        //                    cell.OnOff.on = NO;
        //                }
        //                else
        //                {
        //                    cell.OnOff.on = YES;
        //                }
        //                cell.OnOff.tag = 9;
        //            }
        //            else
        //            {
        //                cell.titleLabel.text = [NSString stringWithFormat:@"%@",NSLocalizedString(@"automatic_answer", nil)];
        //                if([model.AutoAnswer isEqualToString:@"1"])
        //                {
        //                    cell.OnOff.on = YES;
        //                }
        //                else
        //                {
        //                    cell.OnOff.on = NO;
        //                }
        //                cell.OnOff.tag = 1;
        //            }
        //            [cell.OnOff addTarget:self action:@selector(ONOFF:) forControlEvents:UIControlEventValueChanged];
        //            return cell;
        //        }
    }else if(indexPath.section == 1){
        if(indexPath.row == 0 || indexPath.row == 1){
            static  NSString *cell2 = @"watchSetTwo";
            UINib *nib = [UINib nibWithNibName:@"WatchSetTwoTableViewCell" bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:cell2];
            
            WatchSetTwoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell2];
            if (cell == nil) {
                cell = [[WatchSetTwoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell2];
            }
            cell.titleLabel.text = [seciton3Array objectAtIndex:indexPath.row + 1];
            [cell.buuton addTarget:self action:@selector(buutn:) forControlEvents:UIControlEventTouchUpInside];
            cell.buuton.tag = 10 + indexPath.row;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if(indexPath.row == 1){
                cell.listLabel.text = [NSString stringWithFormat:@"%@:%@ %@:%@",NSLocalizedString(@"turn_on_watch", nil),model.TimerOpen,NSLocalizedString(@"turn_off_watch", nil),model.TimerClose];
                if([model.TimeSwitchMachine isEqualToString:@"1"])
                {
                    cell.OnOff.on = YES;
                }
                else
                {
                    cell.OnOff.on = NO;
                }
                cell.OnOff.tag = 6;
                
            }
            else
            {
                cell.listLabel.text = [NSString stringWithFormat:@"%@~%@ %@~%@",model.ClassDisabled1,model.ClassDisabled2,model.ClassDisabled3,model.ClassDisabled4];
                
                if([model.ClassDisable isEqualToString:@"1"])
                {
                    cell.OnOff.on = YES;
                }
                else
                {
                    cell.OnOff.on = NO;
                }
                cell.OnOff.tag = 5;
                
            }
            [cell.OnOff addTarget:self action:@selector(ONOFF:) forControlEvents:UIControlEventValueChanged];
            return cell;
        }else if(indexPath.row == 2){
            static  NSString *cell1 = @"watchSetOne";
            
            UINib *nib = [UINib nibWithNibName:@"WatchSetTableViewCell" bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:cell1];
            
            WatchSetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell1];
            if (cell == nil) {
                cell = [[WatchSetTableViewCell alloc]
                        initWithStyle:UITableViewCellStyleDefault
                        reuseIdentifier:cell1];
            }
            if([model.RefusedStrangerCalls isEqualToString:@"1"])
            {
                cell.OnOff.on = YES;
            }
            else
            {
                cell.OnOff.on = NO;
            }
            cell.OnOff.tag = 7;
            cell.titleLabel.text = [seciton1Array objectAtIndex:6];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            [cell.OnOff addTarget:self action:@selector(ONOFF:) forControlEvents:UIControlEventValueChanged];
            return cell;
        }else{
            static  NSString *cell1 = @"watchSetyyyy";
            UINib *nib = [UINib nibWithNibName:@"WatchSetFourTableViewCell" bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:cell1];
            
            WatchSetFourTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell1];
            if (cell == nil) {
                cell = [[WatchSetFourTableViewCell alloc]
                        initWithStyle:UITableViewCellStyleDefault
                        reuseIdentifier:cell1];
            }
            if(indexPath.row == 3){
                cell.textLabel.text = NSLocalizedString(@"remote_monitoring", nil);
            }else if(indexPath.row == 4){
                cell.textLabel.text = NSLocalizedString(@"watch_setting_school_monitoring", nil);
            }else{
                cell.textLabel.text = NSLocalizedString(@"remote_shutdown", nil);
            }
            return cell;
        }
        //        if(is_D8_show)
        //        {
        //            if(indexPath.row == 0)
        //            {
        //                static  NSString *cell2 = @"watchSetTwo";
        //
        //                UINib *nib = [UINib nibWithNibName:@"WatchSetTwoTableViewCell" bundle:nil];
        //                [tableView registerNib:nib forCellReuseIdentifier:cell2];
        //
        //                WatchSetTwoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell2];
        //                if (cell == nil) {
        //                    cell = [[WatchSetTwoTableViewCell alloc]
        //                            initWithStyle:UITableViewCellStyleDefault
        //                            reuseIdentifier:cell2];
        //                }
        //                cell.titleLabel.text = [NSString stringWithFormat:@"%@",NSLocalizedString(@"timing_starting", nil)];
        //                [cell.buuton addTarget:self action:@selector(buutn:) forControlEvents:UIControlEventTouchUpInside];
        //                cell.buuton.tag = 10 + indexPath.row;
        //                cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //
        //                cell.listLabel.text = [NSString stringWithFormat:@"%@:%@ %@:%@",NSLocalizedString(@"turn_on_watch", nil),model.TimerOpen,NSLocalizedString(@"turn_off_watch", nil),model.TimerClose];
        //
        //                if([model.TimeSwitchMachine isEqualToString:@"1"])
        //                {
        //                    cell.OnOff.on = YES;
        //                }
        //                else
        //                {
        //                    cell.OnOff.on = NO;
        //                }
        //                cell.OnOff.tag = 6;
        //                cell.buuton.tag = 11;
        //
        //
        //                [cell.OnOff addTarget:self action:@selector(ONOFF:) forControlEvents:UIControlEventValueChanged];
        //
        //                return cell;
        //            }
        //            else if(indexPath.row == 1)
        //            {
        //                static  NSString *cell1 = @"watchSetOne";
        //
        //                UINib *nib = [UINib nibWithNibName:@"WatchSetTableViewCell" bundle:nil];
        //                [tableView registerNib:nib forCellReuseIdentifier:cell1];
        //
        //                WatchSetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell1];
        //                if (cell == nil) {
        //                    cell = [[WatchSetTableViewCell alloc]
        //                            initWithStyle:UITableViewCellStyleDefault
        //                            reuseIdentifier:cell1];
        //                }
        //                if([model.RefusedStrangerCalls isEqualToString:@"1"])
        //                {
        //                    cell.OnOff.on = YES;
        //                }
        //                else
        //                {
        //                    cell.OnOff.on = NO;
        //                }
        //                cell.OnOff.tag = 7;
        //                cell.titleLabel.text = [seciton1Array objectAtIndex:6];
        //
        //                cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //
        //                [cell.OnOff addTarget:self action:@selector(ONOFF:) forControlEvents:UIControlEventValueChanged];
        //                return cell;
        //            }
        //            else
        //            {
        //                static  NSString *cell1 = @"watchSetyyyy";
        //                UINib *nib = [UINib nibWithNibName:@"WatchSetFourTableViewCell" bundle:nil];
        //                [tableView registerNib:nib forCellReuseIdentifier:cell1];
        //
        //                WatchSetFourTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell1];
        //                if (cell == nil) {
        //                    cell = [[WatchSetFourTableViewCell alloc]
        //                            initWithStyle:UITableViewCellStyleDefault
        //                            reuseIdentifier:cell1];
        //                }
        //                if(indexPath.row == 2)
        //                {
        //                    cell.textLabel.text = NSLocalizedString(@"remote_monitoring", nil);
        //                }
        //                else if(indexPath.row == 3)
        //                {
        //                    cell.textLabel.text = NSLocalizedString(@"remote_shutdown", nil);
        //
        //                }
        //
        //                return cell;
        //            }
        //        }
        //        else
        //        {
        //            if(indexPath.row == 0 || indexPath.row == 1)
        //            {
        //                static  NSString *cell2 = @"watchSetTwo";
        //
        //                UINib *nib = [UINib nibWithNibName:@"WatchSetTwoTableViewCell" bundle:nil];
        //                [tableView registerNib:nib forCellReuseIdentifier:cell2];
        //
        //                WatchSetTwoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell2];
        //                if (cell == nil) {
        //                    cell = [[WatchSetTwoTableViewCell alloc]
        //                            initWithStyle:UITableViewCellStyleDefault
        //                            reuseIdentifier:cell2];
        //                }
        //                cell.titleLabel.text = [seciton3Array objectAtIndex:indexPath.row + 1];
        //                [cell.buuton addTarget:self action:@selector(buutn:) forControlEvents:UIControlEventTouchUpInside];
        //                cell.buuton.tag = 10 + indexPath.row;
        //                cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //
        //                if(indexPath.row == 1)
        //                {
        //                    cell.listLabel.text = [NSString stringWithFormat:@"%@:%@ %@:%@",NSLocalizedString(@"turn_on_watch", nil),model.TimerOpen,NSLocalizedString(@"turn_off_watch", nil),model.TimerClose];
        //                    if([model.TimeSwitchMachine isEqualToString:@"1"])
        //                    {
        //                        cell.OnOff.on = YES;
        //                    }
        //                    else
        //                    {
        //                        cell.OnOff.on = NO;
        //                    }
        //                    cell.OnOff.tag = 6;
        //
        //                }
        //                else
        //                {
        //                    cell.listLabel.text = [NSString stringWithFormat:@"%@~%@ %@~%@",model.ClassDisabled1,model.ClassDisabled2,model.ClassDisabled3,model.ClassDisabled4];
        //
        //                    if([model.ClassDisable isEqualToString:@"1"])
        //                    {
        //                        cell.OnOff.on = YES;
        //                    }
        //                    else
        //                    {
        //                        cell.OnOff.on = NO;
        //                    }
        //                    cell.OnOff.tag = 5;
        //
        //                }
        //                [cell.OnOff addTarget:self action:@selector(ONOFF:) forControlEvents:UIControlEventValueChanged];
        //
        //                return cell;
        //            }
        //            else if(indexPath.row == 2 || indexPath.row == 3)
        //            {
        //                if(isTuoluo)
        //                {
        //                    static  NSString *cell1 = @"watchSetOne";
        //
        //                    UINib *nib = [UINib nibWithNibName:@"WatchSetTableViewCell" bundle:nil];
        //                    [tableView registerNib:nib forCellReuseIdentifier:cell1];
        //
        //                    WatchSetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell1];
        //                    if (cell == nil) {
        //                        cell = [[WatchSetTableViewCell alloc]
        //                                initWithStyle:UITableViewCellStyleDefault
        //                                reuseIdentifier:cell1];
        //                    }
        //
        //                    if(indexPath.row == 2)
        //                    {
        //                        if([model.RefusedStrangerCalls isEqualToString:@"1"])
        //                        {
        //                            cell.OnOff.on = YES;
        //                        }
        //                        else
        //                        {
        //                            cell.OnOff.on = NO;
        //                        }
        //                        cell.OnOff.tag = 7;
        //                        cell.titleLabel.text = [seciton1Array objectAtIndex:6];
        //
        //                    }
        //                    else if(indexPath.row == 3)
        //                    {
        //                        if([model.WatchOffAlarm isEqualToString:@"1"])
        //                        {
        //                            cell.OnOff.on = YES;
        //                        }
        //                        else
        //                        {
        //                            cell.OnOff.on = NO;
        //                        }
        //                        cell.OnOff.tag = 8;
        //                        cell.titleLabel.text = [seciton1Array objectAtIndex:7];
        //
        //                    }
        //                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //
        //                    [cell.OnOff addTarget:self action:@selector(ONOFF:) forControlEvents:UIControlEventValueChanged];
        //                    return cell;
        //
        //
        //                }
        //                else
        //                {
        //                    if(indexPath.row == 2)
        //                    {
        //                        static  NSString *cell1 = @"watchSetOne";
        //
        //                        UINib *nib = [UINib nibWithNibName:@"WatchSetTableViewCell" bundle:nil];
        //                        [tableView registerNib:nib forCellReuseIdentifier:cell1];
        //
        //                        WatchSetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell1];
        //                        if (cell == nil) {
        //                            cell = [[WatchSetTableViewCell alloc]
        //                                    initWithStyle:UITableViewCellStyleDefault
        //                                    reuseIdentifier:cell1];
        //                        }
        //                        if([model.RefusedStrangerCalls isEqualToString:@"1"])
        //                        {
        //                            cell.OnOff.on = YES;
        //                        }
        //                        else
        //                        {
        //                            cell.OnOff.on = NO;
        //                        }
        //                        cell.OnOff.tag = 7;
        //                        cell.titleLabel.text = [seciton1Array objectAtIndex:6];
        //
        //                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //
        //                        [cell.OnOff addTarget:self action:@selector(ONOFF:) forControlEvents:UIControlEventValueChanged];
        //                        return cell;
        //                    }
        //                    else
        //                    {
        //                        static  NSString *cell1 = @"watchSetyyyy";
        //
        //                        UINib *nib = [UINib nibWithNibName:@"WatchSetFourTableViewCell" bundle:nil];
        //                        [tableView registerNib:nib forCellReuseIdentifier:cell1];
        //
        //                        WatchSetFourTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell1];
        //                        if (cell == nil) {
        //                            cell = [[WatchSetFourTableViewCell alloc]
        //                                    initWithStyle:UITableViewCellStyleDefault
        //                                    reuseIdentifier:cell1];
        //                        }
        //                        cell.textLabel.text = NSLocalizedString(@"remote_monitoring", nil);
        //                        return cell;
        //                    }
        //                }
        //            }
        //            else
        //            {
        //                if(isTuoluo)
        //                {
        //                    static  NSString *cell1 = @"watchSetyyyy";
        //                    UINib *nib = [UINib nibWithNibName:@"WatchSetFourTableViewCell" bundle:nil];
        //                    [tableView registerNib:nib forCellReuseIdentifier:cell1];
        //
        //                    WatchSetFourTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell1];
        //                    if (cell == nil) {
        //                        cell = [[WatchSetFourTableViewCell alloc]
        //                                initWithStyle:UITableViewCellStyleDefault
        //                                reuseIdentifier:cell1];
        //                    }
        //                    if(indexPath.row == 4)
        //                    {
        //                        cell.textLabel.text = NSLocalizedString(@"remote_monitoring", nil);
        //                    }
        //                    else if(indexPath.row == 5)
        //                    {
        //                        cell.textLabel.text = NSLocalizedString(@"remote_shutdown", nil);
        //
        //                    }
        //
        //                    return cell;
        //
        //                }
        //                else
        //                {
        //                    static  NSString *cell1 = @"watchSetyyyy";
        //                    UINib *nib = [UINib nibWithNibName:@"WatchSetFourTableViewCell" bundle:nil];
        //                    [tableView registerNib:nib forCellReuseIdentifier:cell1];
        //
        //                    WatchSetFourTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell1];
        //                    if (cell == nil) {
        //                        cell = [[WatchSetFourTableViewCell alloc]
        //                                initWithStyle:UITableViewCellStyleDefault
        //                                reuseIdentifier:cell1];
        //                    }
        //
        //                    if(indexPath.row == 4)
        //                    {
        //                        cell.textLabel.text = NSLocalizedString(@"remote_shutdown", nil);
        //                    }
        //
        //                    return cell;
        //
        //                }
        //            }
        //        }
    }else if(indexPath.section == 2){
        static  NSString *cell3 = @"watchSetThree";
        UINib *nib = [UINib nibWithNibName:@"WatchSetThreeTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:cell3];
        
        WatchSetThreeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell3];
        if (cell == nil) {
            cell = [[WatchSetThreeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                     reuseIdentifier:cell3];
        }
        if(is_D8_show){
            cell.titleLabel.text = [seciton1Array objectAtIndex:indexPath.row + 5];
            cell.secondLabel.text = @"";
            return cell;
        }else{
            cell.titleLabel.text = [seciton1Array objectAtIndex:indexPath.row + 4];
            if(indexPath.row == 0){
                cell.secondLabel.text = [NSString stringWithFormat:@"%@%@",[defaults objectForKey:@"lightTime"],NSLocalizedString(@"second", nil)];
            }
            else
                cell.secondLabel.text = @"";
            return cell;
        }
    }else{
        static  NSString *cell3 = @"watchSetyyyy";
        UINib *nib = [UINib nibWithNibName:@"WatchSetFourTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:cell3];
        WatchSetFourTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell3];
        if (cell == nil) {
            cell = [[WatchSetFourTableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:cell3];
        }
        if(indexPath.row == 0){
            cell.textLabel.text = NSLocalizedString(@"remote_restart", nil);
        }else{
            cell.textLabel.text = NSLocalizedString(@"remote_restore", nil);
        }
        return cell;
        //        if(is_D8_show==YES||isFlower==NO){
        //            if(indexPath.row == 1){
        //                static  NSString *cell3 = @"watchSetThree";
        //                UINib *nib = [UINib nibWithNibName:@"WatchSetThreeTableViewCell" bundle:nil];
        //                [tableView registerNib:nib forCellReuseIdentifier:cell3];
        //
        //                WatchSetThreeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell3];
        //                if (cell == nil) {
        //                    cell = [[WatchSetThreeTableViewCell alloc]
        //                            initWithStyle:UITableViewCellStyleDefault
        //                            reuseIdentifier:cell3];
        //                }
        //
        //                cell.titleLabel.text = [NSString stringWithFormat:@"%@",NSLocalizedString(@"operating_mode", nil)];
        //                if([[defaults objectForKey:@"Dingwei_Time"] intValue] == 0)
        //                {
        //                    cell.secondLabel.text = [NSString stringWithFormat:@"%@",NSLocalizedString(@"operating_mode_intelligent", nil)];
        //                }
        //                else if([[defaults objectForKey:@"Dingwei_Time"] intValue] == 3){
        //                    cell.secondLabel.text = [NSString stringWithFormat:@"%@",NSLocalizedString(@"operating_mode_follow", nil)];
        //                }
        //                else if([[defaults objectForKey:@"Dingwei_Time"] intValue] == 10){
        //                    cell.secondLabel.text = [NSString stringWithFormat:@"%@",NSLocalizedString(@"operating_mode_normal", nil)];
        //                }
        //                else{
        //                    cell.secondLabel.text = [NSString stringWithFormat:@"%@",NSLocalizedString(@"operating_mode_savepower", nil)];
        //                }
        //
        //
        //                return cell;
        //            }
        //            else
        //            {
        //                static  NSString *cell1 = @"watchSetyyyy";
        //                UINib *nib = [UINib nibWithNibName:@"WatchSetFourTableViewCell" bundle:nil];
        //                [tableView registerNib:nib forCellReuseIdentifier:cell1];
        //
        //                WatchSetFourTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell1];
        //                if (cell == nil) {
        //                    cell = [[WatchSetFourTableViewCell alloc]
        //                            initWithStyle:UITableViewCellStyleDefault
        //                            reuseIdentifier:cell1];
        //                }
        //
        //                if(indexPath.row == 0)
        //                {
        //                    cell.textLabel.text = NSLocalizedString(@"clock_setting", nil);
        //
        //                }
        //                else if(indexPath.row == 2)
        //                {
        //                    cell.textLabel.text = NSLocalizedString(@"remote_restart", nil);
        //
        //                }
        //                else if(indexPath.row == 3)
        //                {
        //                    cell.textLabel.text = NSLocalizedString(@"remote_restore", nil);
        //
        //                }
        //
        //                return cell;
        //            }
        //        }
        //        else
        //        {
        //            if(indexPath.row == 1||indexPath.row == 2)
        //            {
        //                static  NSString *cell3 = @"watchSetThree";
        //
        //                UINib *nib = [UINib nibWithNibName:@"WatchSetThreeTableViewCell" bundle:nil];
        //                [tableView registerNib:nib forCellReuseIdentifier:cell3];
        //
        //                WatchSetThreeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell3];
        //                if (cell == nil) {
        //                    cell = [[WatchSetThreeTableViewCell alloc]
        //                            initWithStyle:UITableViewCellStyleDefault
        //                            reuseIdentifier:cell3];
        //                }
        //
        //                if(indexPath.row == 2)
        //                {
        //                    cell.titleLabel.text = [NSString stringWithFormat:@"%@",NSLocalizedString(@"operating_mode", nil)];
        //                    if([[defaults objectForKey:@"Dingwei_Time"] intValue] == 0)
        //                    {
        //                        cell.secondLabel.text = [NSString stringWithFormat:@"%@",NSLocalizedString(@"operating_mode_intelligent", nil)];
        //                    }
        //                    else if([[defaults objectForKey:@"Dingwei_Time"] intValue] == 3){
        //                        cell.secondLabel.text = [NSString stringWithFormat:@"%@",NSLocalizedString(@"operating_mode_follow", nil)];
        //                    }
        //                    else if([[defaults objectForKey:@"Dingwei_Time"] intValue] == 10){
        //                        cell.secondLabel.text = [NSString stringWithFormat:@"%@",NSLocalizedString(@"operating_mode_normal", nil)];
        //                    }
        //                    else{
        //                        cell.secondLabel.text = [NSString stringWithFormat:@"%@",NSLocalizedString(@"operating_mode_savepower", nil)];
        //                    }
        //                }
        //                else if(indexPath.row == 1)
        //                {
        //                    cell.titleLabel.text = [NSString stringWithFormat:@"%@",NSLocalizedString(@"red_flowers_reward", nil)];
        //                    if([[defaults objectForKey:@"Flower_Num"] intValue] == 0)
        //                    {
        //                        cell.secondLabel.text = [NSString stringWithFormat:@"0%@",NSLocalizedString(@"red_flowers_num", nil)];
        //                    }
        //                    else{
        //                        cell.secondLabel.text = [NSString stringWithFormat:@"%@%@",[defaults objectForKey:@"Flower_Num"],NSLocalizedString(@"red_flowers_num", nil)];
        //                    }
        //                }
        //                else
        //                    cell.secondLabel.text = @"";
        //
        //                return cell;
        //            }
        //            else
        //            {
        //                static  NSString *cell1 = @"watchSetyyyy";
        //                UINib *nib = [UINib nibWithNibName:@"WatchSetFourTableViewCell" bundle:nil];
        //                [tableView registerNib:nib forCellReuseIdentifier:cell1];
        //
        //                WatchSetFourTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell1];
        //                if (cell == nil) {
        //                    cell = [[WatchSetFourTableViewCell alloc]
        //                            initWithStyle:UITableViewCellStyleDefault
        //                            reuseIdentifier:cell1];
        //                }
        //
        //                if(indexPath.row == 0)
        //                {
        //                    cell.textLabel.text = NSLocalizedString(@"clock_setting", nil);
        //
        //                }
        //                else if(indexPath.row == 3)
        //                {
        //                    cell.textLabel.text = NSLocalizedString(@"remote_restart", nil);
        //
        //                }
        //                else if(indexPath.row == 4)
        //                {
        //                    cell.textLabel.text = NSLocalizedString(@"remote_restore", nil);
        //
        //                }
        //
        //                return cell;
        //            }
        //        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 2)
    {
        if(is_D8_show)
        {
            SoundAndVibrationViewController *vc = [[SoundAndVibrationViewController alloc] init];
            vc.title = NSLocalizedString(@"sound_vibrate", nil);
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            
            if(indexPath.row == 1)
            {
                SoundAndVibrationViewController *vc = [[SoundAndVibrationViewController alloc] init];
                vc.title = NSLocalizedString(@"sound_vibrate", nil);
                [self.navigationController pushViewController:vc animated:YES];
                
            }
            else
            {
                LightTimeViewController *vc = [[LightTimeViewController alloc] init];
                vc.title = NSLocalizedString(@"bright_time", nil);
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }else if(indexPath.section == 1){
        if(indexPath.row == 3){
            NSString* phoneNumber = [defaults objectForKey:MAIN_USER_PHONE];
            if ([CommUtil isNotBlank: phoneNumber] && ![phoneNumber isEqualToString:@"0"]){
                UIAlertView *alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"sure_remote_monitoring", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
                alerview.tag = 0;
                [alerview show];
            }else{
                DXAlertView *alert = [[DXAlertView alloc] initWithTitle:NSLocalizedString(@"prompt_Tip", nil) contentText:NSLocalizedString(@"point_to", nil) leftButtonTitle:NSLocalizedString(@"cancel", nil) rightButtonTitle:NSLocalizedString(@"OK", nil)];
                [alert.xButton removeFromSuperview];
                [alert show];
                alert.rightBlock = ^{
                    EditHeadAndNameViewController *vc = [[EditHeadAndNameViewController alloc] init];
                    [defaults setInteger:10 forKey:@"editWatch"];
                    [self.navigationController pushViewController:vc  animated:YES];
                    //                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showNext" object:self];
                };
            }
        }else if(indexPath.row == 4){
            SchoolGuardianViewController *vc = [[SchoolGuardianViewController alloc] init];
            vc.title = NSLocalizedString(@"school_defend", nil);
            [self.navigationController pushViewController:vc animated:YES];
        }else if(indexPath.row == 5){
            UIAlertView *alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"sure_remote_shutdown", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
            alerview.tag = 1;
            [alerview show];
        }
        //        if(isTuoluo)
        //        {
        //            if(indexPath.row == 4)
        //            {
        //                //                [defaults setObject:[object objectForKey:@"PhoneNumber"]
        //
        //                NSString* phoneNumber = [defaults objectForKey:MAIN_USER_PHONE_NUMBER];
        //                if ([CommUtil isNotBlank: phoneNumber])
        //                {
        //                    UIAlertView *alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"sure_remote_monitoring", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
        //                    alerview.tag = 0;
        //                    [alerview show];
        //                }else
        //                {
        //                    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:NSLocalizedString(@"prompt_Tip", nil) contentText:NSLocalizedString(@"point_to", nil) leftButtonTitle:NSLocalizedString(@"cancel", nil) rightButtonTitle:NSLocalizedString(@"OK", nil)];
        //                    [alert.xButton removeFromSuperview];
        //                    [alert show];
        //                    alert.rightBlock = ^{
        //                        [[NSNotificationCenter defaultCenter] postNotificationName:@"showNext" object:self];
        //                    };
        //                }
        //            }
        //            else if(indexPath.row == 5)
        //            {
        //                UIAlertView *alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"sure_remote_shutdown", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
        //                alerview.tag = 1;
        //                [alerview show];
        //            }
        //        }
        //        else
        //        {
        //            if(is_D8_show)
        //            {
        //                if(indexPath.row == 2)
        //                {
        //                    NSString* phoneNumber = [defaults objectForKey:MAIN_USER_PHONE_NUMBER];
        //                    if ([CommUtil isNotBlank: phoneNumber])
        //                    {
        //                        UIAlertView *alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"sure_remote_monitoring", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
        //                        alerview.tag = 0;
        //                        [alerview show];
        //                    }else
        //                    {
        //                        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:NSLocalizedString(@"prompt_Tip", nil) contentText:NSLocalizedString(@"point_to", nil) leftButtonTitle:NSLocalizedString(@"cancel", nil) rightButtonTitle:NSLocalizedString(@"OK", nil)];
        //                        [alert.xButton removeFromSuperview];
        //                        [alert show];
        //                        alert.rightBlock = ^{
        //                            [[NSNotificationCenter defaultCenter] postNotificationName:@"showNext" object:self];
        //                        };
        //                    }
        //                }
        //                else if(indexPath.row == 3)
        //                {
        //                    UIAlertView *alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"sure_remote_shutdown", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
        //                    alerview.tag = 1;
        //                    [alerview show];
        //                }
        //            }
        //            else
        //            {
        //                if(indexPath.row == 3)
        //                {
        //                    NSString* phoneNumber = [defaults objectForKey:MAIN_USER_PHONE_NUMBER];
        //                    NSString* bindNumber = [defaults objectForKey:MAIN_USER_BIND_NUMBER];
        //                    if ([CommUtil isNotBlank: phoneNumber])
        //                    {
        //                        UIAlertView *alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"sure_remote_monitoring", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
        //                        alerview.tag = 0;
        //                        [alerview show];
        //                    }else
        //                    {
        //                        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:NSLocalizedString(@"prompt_Tip", nil) contentText:NSLocalizedString(@"point_to", nil) leftButtonTitle:NSLocalizedString(@"cancel", nil) rightButtonTitle:NSLocalizedString(@"OK", nil)];
        //                        [alert.xButton removeFromSuperview];
        //                        [alert show];
        //                        alert.rightBlock = ^{
        //                            [[NSNotificationCenter defaultCenter] postNotificationName:@"showNext" object:bindNumber];
        //                        };
        //                    }
        //
        //
        //                }
        //                else if(indexPath.row == 4)
        //                {
        //                    UIAlertView *alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"sure_remote_shutdown", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
        //                    alerview.tag = 1;
        //                    [alerview show];
        //                }
        //            }
        //        }
    }else if(indexPath.section == 3){
        if(indexPath.row == 0){
            UIAlertView *alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"sure_remote_restart", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
            alerview.tag = 2;
            [alerview show];
        }else if(indexPath.row == 1){
            UIAlertView *alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"sure_remote_restore", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
            alerview.tag = 3;
            [alerview show];
        }
        //        if(is_D8_show==YES||isFlower==NO)
        //        {
        //            if(indexPath.row == 0)
        //            {
        //                WatchSetAlarmViewController *vc = [[WatchSetAlarmViewController alloc] init];
        //                vc.title = NSLocalizedString(@"clock_setting", nil);
        //                [self.navigationController pushViewController:vc animated:YES];
        //
        //            }
        //            else if(indexPath.row == 1)
        //            {
        //                OperateModeViewController *vc = [[OperateModeViewController alloc] init];
        //                vc.title = NSLocalizedString(@"operating_mode", nil);
        //                [self.navigationController pushViewController:vc animated:YES];
        //
        //            }
        //            else if(indexPath.row == 2)
        //            {
        //                UIAlertView *alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"sure_remote_restart", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
        //                alerview.tag = 2;
        //                [alerview show];
        //            }
        //            else if(indexPath.row == 3)
        //            {
        //                UIAlertView *alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"sure_remote_restore", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
        //                alerview.tag = 3;
        //                [alerview show];
        //            }
        //        }
        //        else
        //        {
        //            if(indexPath.row == 0)
        //            {
        //                WatchSetAlarmViewController *vc = [[WatchSetAlarmViewController alloc] init];
        //                vc.title = NSLocalizedString(@"clock_setting", nil);
        //                [self.navigationController pushViewController:vc animated:YES];
        //
        //            }
        //            else if(indexPath.row == 1)
        //            {
        //                FlowersRewardViewController *vc = [[FlowersRewardViewController alloc] init];
        //                vc.title = NSLocalizedString(@"red_flowers_reward", nil);
        //                [self.navigationController pushViewController:vc animated:YES];
        //            }
        //            else if(indexPath.row == 2)
        //            {
        //                OperateModeViewController *vc = [[OperateModeViewController alloc] init];
        //                vc.title = NSLocalizedString(@"operating_mode", nil);
        //                [self.navigationController pushViewController:vc animated:YES];
        //
        //            }
        //            else if(indexPath.row == 3)
        //            {
        //                UIAlertView *alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"sure_remote_restart", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
        //                alerview.tag = 2;
        //                [alerview show];
        //            }
        //            else if(indexPath.row == 4)
        //            {
        //                UIAlertView *alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"sure_remote_restore", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
        //                alerview.tag = 3;
        //                [alerview show];
        //            }
        //        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            WebService *webService = [WebService newWithWebServiceAction:@"SendDeviceCommand" andDelegate:self];
            webService.tag = 3;
            WebServiceParameter *parameter1;
            if(alertView.tag == 0){
                parameter1 = [WebServiceParameter newWithKey:@"GET" andValue:[NSString stringWithFormat:@"controllerDevice/moniotr/%@/%@/%@",[defaults objectForKey:MAIN_USER_TOKEN],[defaults objectForKey:@"binnumber"],[defaults objectForKey:MAIN_USER_PHONE]]];
            }else if(alertView.tag == 1){
                parameter1 = [WebServiceParameter newWithKey:@"GET" andValue:[NSString stringWithFormat:@"controllerDevice/poweroff/%@/%@",[defaults objectForKey:MAIN_USER_TOKEN],[defaults objectForKey:@"binnumber"]]];
            }else if(alertView.tag == 2){
                parameter1 = [WebServiceParameter newWithKey:@"GET" andValue:[NSString stringWithFormat:@"watchuser/reset/%@/%@",[defaults objectForKey:MAIN_USER_TOKEN],[defaults objectForKey:@"binnumber"]]];
            }else{
                webService.tag = 4;
                parameter1 = [WebServiceParameter newWithKey:@"GET" andValue:[NSString stringWithFormat:@"watchuser/factory/%@/%@",[defaults objectForKey:MAIN_USER_TOKEN],[defaults objectForKey:@"binnumber"]]];
            }
            NSArray *parameter = @[parameter1];
            
            // webservice请求并获得结
            
            webService.webServiceParameter = parameter;
            [webService getWebServiceResult:@"SendDeviceCommandResult"];
        });
    }
}


- (IBAction)saveButton:(id)sender {
    
    manager = [DataManager shareInstance];
    
    array =   [manager isSelectDeviceSetTable:[defaults objectForKey:@"binnumber"]];
    
    deviceModel = [[manager isSelect:[defaults objectForKey:@"binnumber"]] objectAtIndex:0];
    
    model = [array objectAtIndex:0];
    
    str = [NSString stringWithFormat:@"%@-%@-%@-%@-%@-%@-%@-%@-%@-%@-%@-%@",[defaults objectForKey:@"watchInmatVib"],[defaults objectForKey:@"watchInmatSound"],[defaults objectForKey:@"watchCallVib"],[defaults objectForKey:@"watchCallSound"],[defaults objectForKey:@"WatchOffAlarm"],[defaults objectForKey:@"RefusedStrangerCalls"],[defaults objectForKey:@"TimeSwitchMachine"],[defaults objectForKey:@"ClassDisable"],[defaults objectForKey:@"ExtendEmergencyPower"],[defaults objectForKey:@"BodyFeelingAnswer"],[defaults objectForKey:@"ReportCallsPosition"],[defaults objectForKey:@"AutoAnswer"]];
    if([[defaults objectForKey:@"watchInmatVib"] intValue]  == model.WatchInformationShock.intValue && [[defaults objectForKey:@"watchInmatSound"] intValue]  == model.WatchInformationSound.intValue && [[defaults objectForKey:@"watchCallVib"] intValue]  == model.WatchCallVibrate.intValue && [[defaults objectForKey:@"watchCallSound"] intValue]  == model.WatchCallVoice.intValue && [[defaults objectForKey:@"WatchOffAlarm"] intValue]  == model.WatchOffAlarm.intValue && [[defaults objectForKey:@"RefusedStrangerCalls"] intValue]  == model.RefusedStrangerCalls.intValue && [[defaults objectForKey:@"TimeSwitchMachine"] intValue]  == model.TimeSwitchMachine.intValue && [[defaults objectForKey:@"ClassDisable"] intValue]  == model.ClassDisable.intValue && [[defaults objectForKey:@"ExtendEmergencyPower"] intValue]  == model.ExtendEmergencyPower.intValue && [[defaults objectForKey:@"BodyFeelingAnswer"] intValue]  == model.BodyFeelingAnswer.intValue && [[defaults objectForKey:@"ReportCallsPosition"] intValue]  == model.ReportCallsPosition.intValue && [[defaults objectForKey:@"AutoAnswer"] intValue]  == model.AutoAnswer.intValue && [[defaults objectForKey:@"lightTime"] intValue] == model.BrightScreen.intValue&& [[defaults objectForKey:@"Dingwei_Mode"] intValue] == model.locationMode.intValue&& [[defaults objectForKey:@"Dingwei_Time"] intValue] == model.locationTime.intValue&& [[defaults objectForKey:@"Flower_Num"] intValue] == model.flowerNumber.intValue&& [[defaults objectForKey:@"SosMsgswitch"] intValue]  == model.SosMsgswitch.intValue)
    {
        
        return;
    }
    else
    {
        self.saveBtn.enabled = NO;
        
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
            if(ws.tag == 1){
                if(code == 1 && 0){
                    NSArray *setinfo = [[object objectForKey:@"SetInfo"] componentsSeparatedByString:@"-"];
                    [manager updataSQL:@"device_set" andType:@"AutoAnswer" andValue:setinfo[11] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"ReportCallsPosition" andValue:setinfo[10] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"BodyFeelingAnswer" andValue:setinfo[9] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"ExtendEmergencyPower" andValue:setinfo[8] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"ClassDisable" andValue:setinfo[7] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"TimeSwitchMachine" andValue:setinfo[6] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"RefusedStrangerCalls" andValue:setinfo[5] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"WatchOffAlarm" andValue:[setinfo objectAtIndex:4] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"WatchCallVoice" andValue:[setinfo objectAtIndex:3] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"WatchCallVibrate" andValue:[setinfo objectAtIndex:2] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"WatchInformationSound" andValue:setinfo[1] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"WatchInformationShock" andValue:setinfo[0] andBindle:[defaults objectForKey:@"binnumber"]];
                    
                    NSArray *class1 = [[object objectForKey:@"ClassDisabled1"] componentsSeparatedByString:@"-"];
                    
                    NSArray *class2 = [[object objectForKey:@"ClassDisabled2"] componentsSeparatedByString:@"-"];
                    
                    [manager updataSQL:@"device_set" andType:@"ClassDisabled1" andValue:class1[0] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"ClassDisabled2" andValue:class1[1] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"ClassDisabled3" andValue:class2[0] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"ClassDisabled4" andValue:class2[1] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"WeekDisabled" andValue:[object objectForKey:@"WeekDisabled"] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"TimerOpen" andValue:[object objectForKey:@"TimerOpen"] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"TimerClose" andValue:[object objectForKey:@"TimerClose"] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"BrightScreen" andValue:[object objectForKey:@"BrightScreen"] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"WeekAlarm1" andValue:[object objectForKey:@"WeekAlarm1"] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"WeekAlarm2" andValue:[object objectForKey:@"WeekAlarm2"] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"WeekAlarm3" andValue:[object objectForKey:@"WeekAlarm3"] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"Alarm1" andValue:[object objectForKey:@"Alarm1"] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"Alarm2" andValue:[object objectForKey:@"Alarm2"] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"Alarm3" andValue:[object objectForKey:@"Alarm3"] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"LocationMode" andValue:[object objectForKey:@"LocationMode"] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"LocationTime" andValue:[object objectForKey:@"LocationTime"] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"FlowerNumber" andValue:[object objectForKey:@"FlowerNumber"] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"StepCalculate" andValue:[object objectForKey:@"StepCalculate"] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"SleepCalculate" andValue:[object objectForKey:@"SleepCalculate"] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"HrCalculate" andValue:[object objectForKey:@"HrCalculate"] andBindle:[defaults objectForKey:@"binnumber"]];
                    NSString* sosMagswitch;
                    if ([[object objectForKey:@"SosMsgswitch"] isEqualToString:@"0"]) {
                        sosMagswitch = @"1";
                    }else
                    {
                        sosMagswitch = @"0";
                        
                    }
                    [manager updataSQL:@"device_set" andType:@"SosMsgswitch" andValue:sosMagswitch andBindle:[defaults objectForKey:@"binnumber"]];
                    
                    DLog(@"%@",sosMagswitch);
                    [manager updataSQL:@"device_set" andType:@"TimeZone" andValue:@"" andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"Language" andValue:@"" andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"dialPad" andValue:[object objectForKey:@"dialPad"] andBindle:[defaults objectForKey:@"binnumber"]];
                    [self initDatas];
                    [self.tableView reloadData];
                }
            }else if(ws.tag == 0){
                self.saveBtn.enabled = YES;
                if(code == 1){
                    [manager updataSQL:@"device_set" andType:@"AutoAnswer" andValue:[defaults objectForKey:@"AutoAnswer"] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"ReportCallsPosition" andValue:[defaults objectForKey:@"ReportCallsPosition"] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"BodyFeelingAnswer" andValue:[defaults objectForKey:@"BodyFeelingAnswer"] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"ExtendEmergencyPower" andValue:[defaults objectForKey:@"ExtendEmergencyPower"] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"ClassDisable" andValue:[defaults objectForKey:@"ClassDisable"] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"TimeSwitchMachine" andValue:[defaults objectForKey:@"TimeSwitchMachine"] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"RefusedStrangerCalls" andValue:[defaults objectForKey:@"RefusedStrangerCalls"] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"WatchCallVoice" andValue:[defaults objectForKey:@"watchCallSound"] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"WatchCallVibrate" andValue:[defaults objectForKey:@"watchCallVib"] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"WatchOffAlarm" andValue:[defaults objectForKey:@"WatchOffAlarm"] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"WatchInformationSound" andValue:[defaults objectForKey:@"watchInmatSound"] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"WatchInformationShock" andValue:[defaults objectForKey:@"watchInmatVib"] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"BrightScreen" andValue:[defaults objectForKey:@"lightTime"] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"locationMode" andValue:[defaults objectForKey:@"Dingwei_Mode"] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"locationTime" andValue:[defaults objectForKey:@"Dingwei_Time"] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"flowerNumber" andValue:[defaults objectForKey:@"Flower_Num"] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"device_set" andType:@"sosMsgswitch" andValue:[defaults objectForKey:@"SosMsgswitch"] andBindle:[defaults objectForKey:@"binnumber"]];
                    
                    [OMGToast showWithText:NSLocalizedString(@"save_suc", nil) bottomOffset:50 duration:2];
                    [self.navigationController popViewControllerAnimated:YES];
                }else if(code == 2){
                    [OMGToast showWithText:NSLocalizedString(@"send_error_from_device_offline_tips", nil) bottomOffset:50 duration:3];
                }else{
                    [OMGToast showWithText:NSLocalizedString(@"check_device_online_tips", nil) bottomOffset:50 duration:3];
                }
            }else if(ws.tag == 2){
                if(code == 1){
                    [manager updataSQL:@"device_set" andType:@"dialPad" andValue:[defaults objectForKey:@"dialPad"] andBindle:[defaults objectForKey:@"binnumber"]];
                    [OMGToast showWithText:NSLocalizedString(@"save_suc", nil) bottomOffset:50 duration:2];
                }else if(code == 2){
                    [OMGToast showWithText:NSLocalizedString(@"send_error_from_device_offline_tips", nil) bottomOffset:50 duration:3];
                }else{
                    [OMGToast showWithText:NSLocalizedString(@"check_device_online_tips", nil) bottomOffset:50 duration:3];
                }
            }else if(ws.tag == 3){
                if(code == 1){
                    [OMGToast showWithText:NSLocalizedString(@"send_success", nil) bottomOffset:50 duration:2];
                }else if(code == 2){
                    [OMGToast showWithText:NSLocalizedString(@"send_error_from_device_offline_tips", nil) bottomOffset:50 duration:3];
                }else{
                    [OMGToast showWithText:NSLocalizedString(@"check_device_online_tips", nil) bottomOffset:50 duration:3];
                }
            }else if(ws.tag == 4){
                if(code == 1){
                    [OMGToast showWithText:NSLocalizedString(@"send_success", nil) bottomOffset:50 duration:2];
//                    [manager removeFavourite:[defaults objectForKey:@"binnumber"]];
//                    [manager deleDeviceSetItem:[defaults objectForKey:@"binnumber"]];
//                    [manager removeContactTable:[defaults objectForKey:@"binnumber"]];
//                    
//                    NSMutableArray *allArray  = [manager getAllFavourie];
//                    if(allArray.count == 0){
//                        [[NSNotificationCenter defaultCenter] postNotificationName:@"threadExit" object:self];
//                        [defaults setObject:@"0" forKey:@"DMloginScaleKey"];
//                        [defaults setObject:@"1" forKey:@"goSowMain"];
//                        [defaults setObject:@"" forKey:@"binnumber"];
//                    }else{
//                        DeviceModel *deviceModel = [[manager getAllFavourie] objectAtIndex:0];
//                        [defaults setObject:deviceModel.BindNumber forKey:@"binnumber"];
//                    }
//                    UIWindow *window = [UIApplication sharedApplication].keyWindow;
//                    if ([window.rootViewController isKindOfClass:[UINavigationController class]]) {
//                        UINavigationController *nav = window.rootViewController;
//                        for(UIViewController *controller in nav.viewControllers){
//                            if([controller isKindOfClass:[LoginViewController class]]){
//                                return;
//                            }
//                        }
//                    }
//                    LoginViewController *vc = [[LoginViewController alloc] init];
//                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
//                    [window setRootViewController:nav];
//                    [window makeKeyAndVisible];
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
    self.saveBtn.enabled = YES;
    [OMGToast showWithText:NSLocalizedString(@"waring_internet_error", nil) bottomOffset:50 duration:3];
}

- (void)buutn:(UIButton *)btn
{
    if(btn.tag == 0)
    {
        NSLog(@"000");
    }
    else if(btn.tag == 10)
    {
        GotoSchoolViewController *vc = [[GotoSchoolViewController alloc] init];
        vc.title = NSLocalizedString(@"schooltime", nil);
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    else if(btn.tag == 11)
    {
        OpenAndCloseViewController *vc = [[OpenAndCloseViewController alloc] init];
        if([deviceModel.DeviceType isEqualToString:@"2"])
        {
            vc.title = NSLocalizedString(@"time_turn_watch_d8", nil);
        }
        else{
            vc.title = NSLocalizedString(@"time_turn_watch", nil);
        }
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)ONOFF:(UISwitch *)sw
{
    
    UISwitch *swi = sw;
    if(swi.tag == 10){
        if(swi.isOn){
            [defaults setObject:@"1" forKey:@"dialPad"];
        }else{
            [defaults setObject:@"0" forKey:@"dialPad"];
        }
        WebService *webService = [WebService newWithWebServiceAction:@"SetDialPad" andDelegate:self];
        webService.tag = 2;
        WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"GET" andValue:[NSString stringWithFormat:@"app/setdialpad/%@/%@/%@",[defaults objectForKey:MAIN_USER_TOKEN],[defaults objectForKey:@"binnumber"],[defaults objectForKey:@"dialPad"]]];
        NSArray *parameter = @[parameter1];
        // webservice请求并获得结果
        webService.webServiceParameter = parameter;
        [webService getWebServiceResult:@"SetDialPadResult"];
        return;
    }else if(swi.tag == 1)
    {
        if(swi.isOn == YES)
        {
            [defaults setObject:@"1" forKey:@"AutoAnswer"];
        }
        else
        {
            [defaults setObject:@"0" forKey:@"AutoAnswer"];
            
        }
    }
    else if(swi.tag == 2)
    {
        if(swi.isOn == YES)
        {
            [defaults setObject:@"1" forKey:@"ReportCallsPosition"];
        }
        else
        {
            [defaults setObject:@"0" forKey:@"ReportCallsPosition"];
        }
        
    }
    else if(swi.tag == 3)
    {
        if(swi.isOn == YES)
        {
            [defaults setObject:@"1" forKey:@"BodyFeelingAnswer"];
        }
        else
        {
            [defaults setObject:@"0" forKey:@"BodyFeelingAnswer"];
        }
        
    }
    else if(swi.tag == 4)
    {
        if(swi.isOn == YES)
        {
            [defaults setObject:@"1" forKey:@"ExtendEmergencyPower"];
        }
        else
        {
            [defaults setObject:@"0" forKey:@"ExtendEmergencyPower"];
        }
    }
    else if(swi.tag == 5)
    {
        if(swi.isOn == YES)
        {
            [defaults setObject:@"1" forKey:@"ClassDisable"];
        }
        else
        {
            [defaults setObject:@"0" forKey:@"ClassDisable"];
        }
    }
    else if(swi.tag == 6)
    {
        if(swi.isOn == YES)
        {
            [defaults setObject:@"1" forKey:@"TimeSwitchMachine"];
        }
        else
        {
            [defaults setObject:@"0" forKey:@"TimeSwitchMachine"];
        }
    }
    else if(swi.tag == 7)
    {
        if(swi.isOn == YES)
        {
            [defaults setObject:@"1" forKey:@"RefusedStrangerCalls"];
        }
        else
        {
            [defaults setObject:@"0" forKey:@"RefusedStrangerCalls"];
        }
    }
    else if(swi.tag == 8)
    {
        if(swi.isOn == YES)
        {
            [defaults setObject:@"1" forKey:@"WatchOffAlarm"];
        }
        else
        {
            [defaults setObject:@"0" forKey:@"WatchOffAlarm"];
        }
    }
    else if(swi.tag == 9)
    {
        if(swi.isOn == YES)
        {
            [defaults setObject:@"1" forKey:@"SosMsgswitch"];
            
            [defaults setObject:@"0" forKey:@"SosMsgswitch_type"];
        }
        else
        {
            [defaults setObject:@"0" forKey:@"SosMsgswitch"];
            
            [defaults setObject:@"1" forKey:@"SosMsgswitch_type"];
        }
    }
    
    if([[defaults objectForKey:@"RefusedStrangerCalls"] intValue]  == model.RefusedStrangerCalls.intValue && [[defaults objectForKey:@"TimeSwitchMachine"] intValue]  == model.TimeSwitchMachine.intValue && [[defaults objectForKey:@"ClassDisable"] intValue]  == model.ClassDisable.intValue && [[defaults objectForKey:@"ExtendEmergencyPower"] intValue]  == model.ExtendEmergencyPower.intValue && [[defaults objectForKey:@"SosMsgswitch"] intValue]  == model.SosMsgswitch.intValue && [[defaults objectForKey:@"BodyFeelingAnswer"] intValue]  == model.BodyFeelingAnswer.intValue && [[defaults objectForKey:@"ReportCallsPosition"] intValue]  == model.ReportCallsPosition.intValue && [[defaults objectForKey:@"AutoAnswer"] intValue]  == model.AutoAnswer.intValue && [[defaults objectForKey:@"lightTime"] intValue] == model.BrightScreen.intValue && [[defaults objectForKey:@"WatchOffAlarm"] intValue]  == model.WatchOffAlarm.intValue&& [[defaults objectForKey:@"Dingwei_Mode"] intValue]  == model.locationMode.intValue&& [[defaults objectForKey:@"Dingwei_Time"] intValue]  == model.locationTime.intValue&& [[defaults objectForKey:@"Flower_Num"] intValue]  == model.flowerNumber.intValue)
    {
        self.saveBtn.enabled = NO;
        
    }
    else
    {
        self.saveBtn.enabled = YES;
    }
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
