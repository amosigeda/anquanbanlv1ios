//
//  HealthViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "HealthViewController.h"
#import "HealthTableViewCell.h"
#import "StepViewController.h"
#import "SleepViewController.h"
#import "heartViewController.h"
#import "DataManager.h"
#import "DeviceModel.h"
#import "DeviceSetModel.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "OMGToast.h"
#import "WatchSetFourTableViewCell.h"
#import "LoginViewController.h"
#import "IQActionSheetPickerView.h"
#import "STAlertView.h"
#import "DXAlertView.h"
#import "WatchSetFourTableViewCell.h"
#import "LocationModel.h"

NSString *str_stepnum;
NSString *str_sleepnum;
NSString *str_heartnum;
extern NSString *str_sleep_set;
NSString *str_sleep;
NSString *str_sleep_onoff;

@interface HealthViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,IQActionSheetPickerViewDelegate,WebServiceProtocol>
{
    NSUserDefaults *defaults;
    LocationModel *model;
    DeviceSetModel *modelset;
    NSMutableArray *array;
    NSArray *setArray;
    NSMutableArray *deviceArray;
    DeviceModel *deviceModel;
    DataManager *manager ;
    NSString *str;
    BOOL isXinlv;
    BOOL isGsensor;
    BOOL isStepOn;
    BOOL isSleepOn;
    
    NSString *str_step_onoff;
    NSString *str_heart_onoff;
}

@end

@implementation HealthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    defaults = [NSUserDefaults standardUserDefaults];
    array = [[NSMutableArray alloc ] init];
    deviceArray = [[NSMutableArray alloc] init];
    
    setArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"watch_step", nil),NSLocalizedString(@"watch_sleep", nil),NSLocalizedString(@"watch_heart", nil),nil];
    
    [defaults setObject:@"0" forKey:@"showRight"];
    [defaults setObject:@"1" forKey:@"showLeft"];
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
    deviceArray =  [manager isSelect:[defaults objectForKey:@"binnumber"]];
    deviceModel = [deviceArray objectAtIndex:0];
    array = [manager isSelectLocationTable:deviceModel.DeviceID];
    
    LocationModel *Locmodel = [array objectAtIndex:0];
    [defaults setObject:Locmodel.Step  forKey:@"Step"];
    [defaults setObject:Locmodel.Health forKey:@"Health"];
    
    if(Locmodel.Step.length==0)
    {
        Locmodel.Step=@"0";
    }
    if(Locmodel.Health.length==0)
    {
        Locmodel.Health=@"0:0";
    }
    str_stepnum = Locmodel.Step;
    str_sleepnum = [Locmodel.Health substringWithRange:NSMakeRange(0, 1)];
    str_heartnum = [Locmodel.Health substringWithRange:NSMakeRange(1,[Locmodel.Health length] - 1)];
    //    str_heartnum = [str_heartnum substringWithRange:NSMakeRange(1,[str_heartnum length]-1)];
    
    //if([[deviceModel.DeviceModelID substringFromIndex:deviceModel.DeviceModelID.length - 1] intValue] ==1)
    if(deviceModel.CurrentFirmware.length==0)
    {
        deviceModel.CurrentFirmware=@"00000000";
    }
    
    if([deviceModel.CurrentFirmware rangeOfString:@"1895"].location != NSNotFound)//心率
    {
        isXinlv = YES;
    }
    else{
        isXinlv = NO;
    }
    
    if(([deviceModel.CurrentFirmware rangeOfString:@"D10_CHUANGMT_V0.1"].location != NSNotFound)||([deviceModel.CurrentFirmware rangeOfString:@"D9_CHUANGMT_V0.1"].location != NSNotFound)||([deviceModel.CurrentFirmware rangeOfString:@"D9_CHUANGMT_V0.3"].location != NSNotFound)||([deviceModel.CurrentFirmware rangeOfString:@"D9_TP_CHUANGMT"].location != NSNotFound)||([deviceModel.CurrentFirmware rangeOfString:@"D12_CHUANGMT"].location != NSNotFound)||([deviceModel.CurrentFirmware rangeOfString:@"YDB_S3_C1_CHUANGMT"].location != NSNotFound))//易多宝去除睡眠监测（GSensor）
    {
        isGsensor = NO;
    }
    else{
        isGsensor = YES;
    }
    
    if([deviceModel.DeviceType isEqualToString:@"2"])
    {
        self.list_Label.text = NSLocalizedString(@"watch_setting_PS_d8", nil);
    }
    else{
        self.list_Label.text = NSLocalizedString(@"watch_setting_PS", nil);
    }
    
    [self.tableView reloadData];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController.navigationBar setHidden:NO];
    
    manager = [DataManager shareInstance];
    
    array =   [manager isSelectDeviceSetTable:[defaults objectForKey:@"binnumber"]];
    
    deviceModel = [[manager isSelect:[defaults objectForKey:@"binnumber"]] objectAtIndex:0];
    
    modelset = [array objectAtIndex:0];
    
    [defaults setObject:modelset.StepCalculate forKey:@"StepCalculate"];
    [defaults setObject:modelset.SleepCalculate forKey:@"SleepCalculate"];
    [defaults setObject:modelset.HrCalculate forKey:@"HrCalculate"];
    
    if(modelset.StepCalculate.length==0)
    {
        modelset.StepCalculate=@"0";
    }
    str_step_onoff=modelset.StepCalculate;
    
    if(modelset.SleepCalculate.length==0||([modelset.SleepCalculate rangeOfString:@"null"].location != NSNotFound))
    {
        modelset.SleepCalculate=@"00:00-08:00|13:00-14:00";
    }
    str_sleep_set=[modelset.SleepCalculate substringWithRange:NSMakeRange(2,[modelset.SleepCalculate length]-2)];
    str_sleep_onoff=[modelset.SleepCalculate substringWithRange:NSMakeRange(0,1)];
    str_sleep=[NSString stringWithFormat:@"%@|%@",str_sleep_onoff,str_sleep_set];
    
    if(modelset.HrCalculate.length==0||([modelset.HrCalculate rangeOfString:@"null"].location != NSNotFound))
    {
        modelset.HrCalculate=@"0";
    }
    str_heart_onoff = modelset.HrCalculate;
    [self.tableView reloadData];
}

-(void)updateHeadlth{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        WebService *webService = [WebService newWithWebServiceAction:@"UpdateDeviceSet" andDelegate:self];
        webService.tag = 0;
        WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"POST" andValue:@"bloodOxygen/heath"];
        WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"token" andValue:[defaults objectForKey:MAIN_USER_TOKEN]];
        WebServiceParameter *parameter3 = [WebServiceParameter newWithKey:@"imei" andValue:[defaults objectForKey:@"binnumber"]];
        WebServiceParameter *parameter4 = [WebServiceParameter newWithKey:@"deviceId" andValue:[defaults objectForKey:@"binnumber"]];
        WebServiceParameter *parameter5 = [WebServiceParameter newWithKey:@"stepCalculate" andValue:str_step_onoff];
        WebServiceParameter *parameter6 = [WebServiceParameter newWithKey:@"sleepCalculate" andValue:str_sleep];
        WebServiceParameter *parameter7 = [WebServiceParameter newWithKey:@"hrCalculate" andValue:str_heart_onoff];
        NSArray *parameter = @[parameter1,parameter2,parameter3,parameter4,parameter5,parameter6,parameter7];
        // webservice请求并获得结果
        webService.webServiceParameter = parameter;
        [webService getWebServiceResult:@"UpdateDeviceSetResult"];
    });
}

//每个分组下边预留的空白高度
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0.1;
    
}

- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([deviceModel.CurrentFirmware rangeOfString:@"YDB_S3_C1_CHUANGMT"].location != NSNotFound) //易多宝健康管理项目清空
    {
        return 0;
    }
    if(isGsensor)
    {
        if(isXinlv)
        {
            return 3;
        }
        else
        {
            return 2;
        }
    }
    else
    {
        if(isXinlv)
        {
            return 2;
        }
        else
        {
            return 1;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)ONOFF:(UISwitch *)sw
{
    UISwitch *swi = sw;
    
    manager = [DataManager shareInstance];
    array =   [manager isSelectDeviceSetTable:[defaults objectForKey:@"binnumber"]];
    deviceModel = [[manager isSelect:[defaults objectForKey:@"binnumber"]] objectAtIndex:0];
    model = [array objectAtIndex:0];
    
    if(swi.tag == 1){
        if(swi.isOn == YES){
            UIAlertView *alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"watch_step_alerview", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
            alerview.tag = 1;
            [alerview show];
            
            str_step_onoff=@"1";
            [defaults setObject:@"1" forKey:@"step_set"];
        }else{
            isStepOn=NO;
            str_step_onoff=@"0";
            [defaults setObject:@"0" forKey:@"step_set"];
            str_stepnum=@"0";
            
            [self updateHeadlth];
        }
    }else if(swi.tag == 2){
        if(swi.isOn == YES){
            UIAlertView *alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"watch_sleep_alerview", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
            alerview.tag = 2;
            [alerview show];
            
            str_sleep_onoff=@"1";
            [defaults setObject:@"1" forKey:@"sleep_set"];
        }else{
            isSleepOn=NO;
            [defaults setObject:@"0" forKey:@"sleep_set"];
            str_sleepnum=@"0";
            str_sleep_onoff=@"0";
            str_sleep=[NSString stringWithFormat:@"%@|%@",str_sleep_onoff,str_sleep_set];
            
            [self updateHeadlth];
        }
        
    }else if(swi.tag == 3){
        if(swi.isOn == YES){
            UIAlertView *alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"watch_heart_alerview", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
            alerview.tag = 3;
            [alerview show];
            
            str_heart_onoff=@"1";
            [defaults setObject:@"1" forKey:@"Heartrate_set"];
        }else{
            str_heart_onoff=@"0";
            [defaults setObject:@"0" forKey:@"Heartrate_set"];
            
            [self updateHeadlth];
        }
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static  NSString *cell2 = @"HealthCell";
    
    UINib *nib = [UINib nibWithNibName:@"HealthTableViewCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:cell2];
    
    HealthTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell2];
    if (cell == nil) {
        cell = [[HealthTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cell2];
    }
    
    cell.titleLabel.text = [setArray objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if(indexPath.row == 0)
    {
        cell.listLabel.hidden = NO;
        cell.listLabel.text = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"watch_step_num", nil),str_stepnum];
        if([modelset.StepCalculate isEqualToString:@"1"])
        {
            cell.OnOff.on = YES;
        }
        else
        {
            cell.OnOff.on = NO;
        }
        cell.OnOff.tag = 1;
        
    }
    else if(indexPath.row == 1)
    {
        cell.listLabel.hidden = NO;
        cell.listLabel.text = [NSString stringWithFormat:@"%@",str_sleep_set];
        
        if([str_sleep_onoff isEqualToString:@"1"])
        {
            cell.OnOff.on = YES;
        }
        else
        {
            cell.OnOff.on = NO;
        }
        cell.OnOff.tag = 2;
        
    }
    else if(indexPath.row == 2)
    {
        cell.listLabel.hidden = NO;
        cell.listLabel.text = [NSString stringWithFormat:@"%@ %@",str_heartnum,NSLocalizedString(@"watch_heart_mon", nil)];
        if([modelset.HrCalculate isEqualToString:@"1"])
        {
            cell.OnOff.on = YES;
        }
        else
        {
            cell.OnOff.on = NO;
        }
        cell.OnOff.tag = 3;
        
    }
    
    [cell.OnOff addTarget:self action:@selector(ONOFF:) forControlEvents:UIControlEventValueChanged];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        StepViewController *vc = [[StepViewController alloc] init];
        vc.title = NSLocalizedString(@"watch_step", nil);
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(indexPath.row == 1)
    {
        SleepViewController *vc = [[SleepViewController alloc] init];
        vc.title = NSLocalizedString(@"watch_sleep", nil);
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(indexPath.row == 2)
    {
        heartViewController *vc = [[heartViewController alloc] init];
        vc.title = NSLocalizedString(@"watch_heart", nil);
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //if(buttonIndex == 1)
    {
        manager = [DataManager shareInstance];
        
        array =   [manager isSelectDeviceSetTable:[defaults objectForKey:@"binnumber"]];
        
        deviceModel = [[manager isSelect:[defaults objectForKey:@"binnumber"]] objectAtIndex:0];
        
        modelset = [array objectAtIndex:0];
        
        str = [NSString stringWithFormat:@"%@-%@-%@",[defaults objectForKey:@"step_set"],[defaults objectForKey:@"sleep_set"],[defaults objectForKey:@"Heartrate_set"]];
        
        if([[defaults objectForKey:@"step_set"] intValue]  == modelset.StepCalculate.intValue && [[defaults objectForKey:@"sleep_set"] intValue]  == modelset.SleepCalculate.intValue && [[defaults objectForKey:@"Heartrate_set"] intValue]  == modelset.HrCalculate.intValue )
        {
            
            return;
        }
        else
        {
            
            [self updateHeadlth];
        }
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
            
            if(code == 1){
                [OMGToast showWithText:NSLocalizedString(@"save_suc", nil) bottomOffset:50 duration:3];
                [manager updataSQL:@"device_set" andType:@"stepCalculate" andValue:str_step_onoff andBindle:[defaults objectForKey:@"binnumber"]];
                [manager updataSQL:@"device_set" andType:@"sleepCalculate" andValue:str_sleep andBindle:[defaults objectForKey:@"binnumber"]];
                [manager updataSQL:@"device_set" andType:@"hrCalculate" andValue:str_heart_onoff andBindle:[defaults objectForKey:@"binnumber"]];
            }else{
                [OMGToast showWithText:NSLocalizedString(@"save_fail", nil) bottomOffset:50 duration:3];
            }
        }
    }
}

- (void)WebServiceGetError:(id)theWebService error:(NSString *)theError{
    [OMGToast showWithText:NSLocalizedString(@"waring_internet_error", nil) bottomOffset:50 duration:3];
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
