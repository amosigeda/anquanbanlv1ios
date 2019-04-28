//
//  WatchSetAlarmViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "WatchSetAlarmViewController.h"
#import "WatchSetTwoTableViewCell.h"
#import "AlarmSetViewController.h"
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
#import "STAlertView.h"
#import "DXAlertView.h"

int alarm_pick;
int button_pick1;
int button_pick2;
int button_pick3;
extern NSString *str_week1;
extern NSString *str_week2;
extern NSString *str_week3;
extern NSString *str_alarm1;
extern NSString *str_alarm2;
extern NSString *str_alarm3;
extern NSString *str_weekalarm1;
extern NSString *str_weekalarm2;
extern NSString *str_weekalarm3;
NSString *model_alarm1;
NSString *model_alarm2;
NSString *model_alarm3;

@interface WatchSetAlarmViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,IQActionSheetPickerViewDelegate>
{
    NSUserDefaults *defaults;
    DeviceSetModel *model;
    NSMutableArray *array;
    NSArray *setArray;
    NSMutableArray *deviceArray;
    DeviceModel *deviceModel;
    DataManager *manager ;
    NSString *str;
    BOOL isWatchSetAlarm;
    BOOL alarmweek1;
    BOOL alarmweek2;
    BOOL alarmweek3;
}
@end

@implementation WatchSetAlarmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isWatchSetAlarm = YES;
    defaults = [NSUserDefaults standardUserDefaults];
    array = [[NSMutableArray alloc ] init];
    deviceArray = [[NSMutableArray alloc] init];
    
    [defaults setObject:@"0" forKey:@"showRight"];
    [defaults setObject:@"1" forKey:@"showLeft"];
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    self.saveBtn.backgroundColor = MCN_buttonColor;
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
    self.tableView.tableFooterView.hidden = YES;
    self.tableView.rowHeight = 50;
    self.tableView.tableFooterView = [UIView new];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    manager = [DataManager shareInstance];
    
    array =   [manager isSelectDeviceSetTable:[defaults objectForKey:@"binnumber"]];
    
    model = [array objectAtIndex:0];
    WatchModel* watchModel1 = [[WatchModel alloc]init];
    watchModel1.alarm = model.alarm1;
    if ([model.alarm1 isEqualToString:@""]) {
        watchModel1.alarm = @"00:00";
    }
    if (![model.weekAlarm1 isEqualToString:@""]) {
        watchModel1.weekAlarm = [model.weekAlarm1 substringWithRange:NSMakeRange(0,1)];
    }
    if (model.weekAlarm1.length) {
        watchModel1.weekAlarm = [model.weekAlarm1 substringWithRange:NSMakeRange(0,1)];
        watchModel1.week = [model.weekAlarm1 substringWithRange:NSMakeRange(2,[model.weekAlarm1 length]-2)];
    }else{
        watchModel1.weekAlarm = @"0";
        watchModel1.week = @"0";
    }
    
    
    
    WatchModel* watchModel2 = [[WatchModel alloc]init];
    watchModel2.alarm = model.alarm2;
    if ([model.alarm2 isEqualToString:@""]) {
        watchModel2.alarm = @"00:00";
    }
    if (model.weekAlarm2.length) {
        watchModel2.weekAlarm = [model.weekAlarm2 substringWithRange:NSMakeRange(0,1)];
        watchModel2.week = [model.weekAlarm2 substringWithRange:NSMakeRange(2,[model.weekAlarm2 length]-2)];
    }else{
        watchModel2.weekAlarm = @"0";
        watchModel2.week = @"0";
    }
    WatchModel* watchModel3 = [[WatchModel alloc]init];
    watchModel3.alarm = model.alarm3;
    if ([model.alarm3 isEqualToString:@""]) {
        watchModel3.alarm = @"00:00";
    }
    if (model.weekAlarm3.length) {
        watchModel3.weekAlarm = [model.weekAlarm3 substringWithRange:NSMakeRange(0,1)];
        watchModel3.week = [model.weekAlarm3 substringWithRange:NSMakeRange(2,[model.weekAlarm3 length]-2)];
    }else{
        watchModel3.weekAlarm = @"0";
        watchModel3.week = @"0";
    }
    NSMutableArray* muArr = [[NSMutableArray alloc]init];
    [muArr addObject:watchModel1];
    [muArr addObject:watchModel2];
    [muArr addObject:watchModel3];
    _watchModelArr = muArr.copy;
    deviceArray = [manager isSelect:[defaults objectForKey:@"binnumber"]];
    
    deviceModel = [deviceArray objectAtIndex:0];
    
    //    [defaults setObject:model.alarm1 forKey:@"Alarm1"];
    //    [defaults setObject:model.alarm2 forKey:@"Alarm2"];
    //    [defaults setObject:model.alarm3 forKey:@"Alarm3"];
    //    [defaults setObject:model.weekAlarm1 forKey:@"WeekAlarm1"];
    //    [defaults setObject:model.weekAlarm2 forKey:@"WeekAlarm2"];
    //    [defaults setObject:model.weekAlarm3 forKey:@"WeekAlarm3"];
    
    self.list_Label.text = NSLocalizedString(@"clock_setting", nil);
    [self.saveBtn setTitle:NSLocalizedString(@"save", nil) forState:UIControlStateNormal];
    
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    //    [self.navigationController.navigationBar setHidden:NO];
    //    manager = [DataManager shareInstance];
    //
    //    array =   [manager isSelectDeviceSetTable:[defaults objectForKey:@"binnumber"]];
    //
    //    deviceModel = [[manager isSelect:[defaults objectForKey:@"binnumber"]] objectAtIndex:0];
    //    model = [array objectAtIndex:0];
    //
    //    [defaults setObject:model.alarm1 forKey:@"Alarm1"];
    //    [defaults setObject:model.alarm2 forKey:@"Alarm2"];
    //    [defaults setObject:model.alarm3 forKey:@"Alarm3"];
    //    [defaults setObject:model.weekAlarm1 forKey:@"WeekAlarm1"];
    //    [defaults setObject:model.weekAlarm2 forKey:@"WeekAlarm2"];
    //    [defaults setObject:model.weekAlarm3 forKey:@"WeekAlarm3"];
    
    //    model_alarm1=model.alarm1;
    //    model_alarm2=model.alarm2;
    //    model_alarm3=model.alarm3;
    //
    //    if([str_alarm1 isEqualToString:model_alarm1])
    //    {
    //        [defaults setObject:model_alarm1 forKey:@"Alarm1"];
    //    }
    //    else
    //    {
    //        [defaults setObject:str_alarm1 forKey:@"Alarm1"];
    //
    //    }
    //
    //    if([str_alarm2 isEqualToString:model_alarm2])
    //    {
    //        [defaults setObject:model_alarm2 forKey:@"Alarm2"];
    //    }
    //    else
    //    {
    //        [defaults setObject:str_alarm2 forKey:@"Alarm2"];
    //
    //    }
    //
    //    if([str_alarm3 isEqualToString:model_alarm3])
    //    {
    //        [defaults setObject:model_alarm3 forKey:@"Alarm3"];
    //    }
    //    else
    //    {
    //        [defaults setObject:str_alarm3 forKey:@"Alarm3"];
    //
    //    }
    //
    if(model.weekAlarm1.length == 0)
    {
        model.weekAlarm1=@"0:0";
    }
    if(model.weekAlarm2.length == 0)
    {
        model.weekAlarm2=@"0:0";
    }
    if(model.weekAlarm3.length == 0)
    {
        model.weekAlarm3=@"0:0";
    }
    //
    [self.tableView reloadData];
    
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

- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (void)ONOFF:(UISwitch *)sw
{
    UISwitch *swi = sw;
    WatchModel* watchModel = _watchModelArr[swi.tag-1];
    if(swi.isOn == YES)
    {
        //model.weekAlarm1 = [NSString stringWithFormat:@"1:%@",str_weekalarm1];
        watchModel.weekAlarm=@"1";
    }
    else
    {
        //model.weekAlarm1=[NSString stringWithFormat:@"0:%@",str_weekalarm1];
        watchModel.weekAlarm=@"0";
    }
    //    if(swi.tag == 1)
    //    {
    //
    //
    //    }
    //    else if(swi.tag == 2)
    //    {
    //        if(swi.isOn == YES)
    //        {
    //            //model.weekAlarm2 = [NSString stringWithFormat:@"1:%@",str_weekalarm2];
    //            alarmweek2=YES;
    //        }
    //        else
    //        {
    //            //model.weekAlarm2=[NSString stringWithFormat:@"0:%@",str_weekalarm2];
    //            alarmweek2=NO;
    //        }
    //
    //    }
    //    else if(swi.tag == 3)
    //    {
    //        if(swi.isOn == YES)
    //        {
    //            //model.weekAlarm3 = [NSString stringWithFormat:@"1:%@",str_weekalarm3];
    //            alarmweek3=YES;
    //        }
    //        else
    //        {
    //            //model.weekAlarm3=[NSString stringWithFormat:@"0:%@",str_weekalarm3];
    //            alarmweek3=NO;
    //        }
    //
    //    }
    
    /*
     if([[defaults objectForKey:@"WeekAlarm1"] intValue] == 0)
     {
     self.saveBtn.enabled = NO;
     
     }
     else
     {
     self.saveBtn.enabled = YES;
     }
     */
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static  NSString *cell2 = @"watchSetTwo";
    static  NSString *str_setweek1=@"";
    static  NSString *str_setweek2=@"";
    static  NSString *str_setweek3=@"";
    WatchModel* watchModel = _watchModelArr[indexPath.row];
    //    [defaults ]
    UINib *nib = [UINib nibWithNibName:@"WatchSetTwoTableViewCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:cell2];
    
    WatchSetTwoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell2];
    if (cell == nil) {
        cell = [[WatchSetTwoTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cell2];
    }
    
    [cell.buuton addTarget:self action:@selector(buutn:) forControlEvents:UIControlEventTouchUpInside];
    cell.buuton.tag = indexPath.row;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    cell.titleLabel.text=watchModel.alarm;
    NSString* weekStr = [self getWeekString:watchModel.week];
    
    if ([weekStr isEqualToString:@""]|| weekStr == nil)
    {
        weekStr = NSLocalizedString(@"custom", nil);
    }
    
    cell.listLabel.text = weekStr;
    
    //    if(indexPath.row == 0)
    //    {
    //
    //    }
    //    if(indexPath.row == 1)
    //    {
    //        str_setweek2 = [self getWeekString:watchModel.week];
    //    }
    //    if(indexPath.row == 2)
    //    {
    //        str_setweek3 = [self getWeekString:watchModel.week];
    //    }
    if(watchModel.weekAlarm.integerValue ==0)
    {
        cell.OnOff.on = NO;
        alarmweek1=NO;
    }
    else
    {
        cell.OnOff.on = YES;
        alarmweek1=YES;
    }
    cell.OnOff.tag = indexPath.row+1;
    [cell.OnOff addTarget:self action:@selector(ONOFF:) forControlEvents:UIControlEventValueChanged];
    //    if(indexPath.row == 0)
    //    {
    //        if(str_alarm1.length != 0)
    //        {
    //
    //
    //        }
    //        else if(model.alarm1.length == 0||([model.alarm1 rangeOfString:@"null"].location != NSNotFound))
    //        {
    //            cell.titleLabel.text=[NSString stringWithFormat:@"00:00"];
    //        }
    //        else if ([str_alarm1 isEqualToString:model_alarm1])
    //        {
    //            cell.titleLabel.text=[NSString stringWithFormat:@"%@",model_alarm1];
    //        }
    //        else{
    //            cell.titleLabel.text=[NSString stringWithFormat:@"%@",model_alarm1];
    //        }
    //
    //        if (button_pick1==1)
    //        {
    //            //button_pick1=0;
    //            cell.listLabel.text=[NSString stringWithFormat:@"%@",str_week1];
    //        }
    //        else if([model.weekAlarm1 rangeOfString:@"0:0"].location !=NSNotFound)
    //        {
    //            cell.listLabel.text=NSLocalizedString(@"custom", nil);
    //        }
    //        else if(str_setweek1.length!=0)
    //        {
    //            cell.listLabel.text=[NSString stringWithFormat:@"%@",str_setweek1];
    //        }
    //        else
    //        {
    //            cell.listLabel.text=[NSString stringWithFormat:@"%@",str_week1];
    //        }
    //
    //
    //
    //        cell.OnOff.tag = 1;
    //
    //    }
    //    else if(indexPath.row == 1)
    //    {
    //        if(str_alarm2.length != 0)
    //        {
    //            cell.titleLabel.text=[NSString stringWithFormat:@"%@",str_alarm2];
    //
    //        }
    //        else if(model.alarm2.length == 0||([model.alarm2 rangeOfString:@"null"].location != NSNotFound))
    //        {
    //            cell.titleLabel.text=[NSString stringWithFormat:@"00:00"];
    //        }
    //        else if ([str_alarm2 isEqualToString:model_alarm2])
    //        {
    //            cell.titleLabel.text=[NSString stringWithFormat:@"%@",model_alarm2];
    //        }
    //        else{
    //            cell.titleLabel.text=[NSString stringWithFormat:@"%@",model_alarm2];
    //        }
    //
    //
    //        if (button_pick2==1)
    //        {
    //            //button_pick2=0;
    //            cell.listLabel.text=[NSString stringWithFormat:@"%@",str_week2];
    //        }
    //        else if([model.weekAlarm2 rangeOfString:@"0:0"].location !=NSNotFound)
    //        {
    //            cell.listLabel.text=NSLocalizedString(@"custom", nil);
    //        }
    //        else if(str_setweek2.length!=0)
    //        {
    //            cell.listLabel.text=[NSString stringWithFormat:@"%@",str_setweek2];
    //        }
    //        else
    //        {
    //            cell.listLabel.text=[NSString stringWithFormat:@"%@",str_week2];
    //        }
    //
    //        if([[model.weekAlarm2 substringWithRange:NSMakeRange(0,1)] intValue] ==0)
    //        {
    //            cell.OnOff.on = NO;
    //            alarmweek2=NO;
    //        }
    //        else
    //        {
    //            cell.OnOff.on = YES;
    //            alarmweek2=YES;
    //        }
    //
    //
    //
    //    }
    //    else
    //    {
    //        if(str_alarm3.length != 0)
    //        {
    //            cell.titleLabel.text=[NSString stringWithFormat:@"%@",str_alarm3];
    //
    //        }
    //        else if(model.alarm3.length == 0||([model.alarm3 rangeOfString:@"null"].location != NSNotFound))
    //        {
    //            cell.titleLabel.text=[NSString stringWithFormat:@"00:00"];
    //        }
    //        else if ([str_alarm3 isEqualToString:model_alarm3])
    //        {
    //            cell.titleLabel.text=[NSString stringWithFormat:@"%@",model_alarm3];
    //        }
    //        else{
    //            cell.titleLabel.text=[NSString stringWithFormat:@"%@",model_alarm3];
    //        }
    //
    //
    //        if (button_pick3==1)
    //        {
    //            //button_pick3=0;
    //            cell.listLabel.text=[NSString stringWithFormat:@"%@",str_week3];
    //        }
    //        else if([model.weekAlarm3 rangeOfString:@"0:0"].location !=NSNotFound)
    //        {
    //            cell.listLabel.text=NSLocalizedString(@"custom", nil);;
    //        }
    //        else if(str_setweek3.length!=0)
    //        {
    //            cell.listLabel.text=[NSString stringWithFormat:@"%@",str_setweek3];
    //        }
    //        else
    //        {
    //            cell.listLabel.text=[NSString stringWithFormat:@"%@",str_week3];
    //        }
    //
    //        if([[model.weekAlarm3 substringWithRange:NSMakeRange(0,1)] intValue] ==0)
    //        {
    //            cell.OnOff.on = NO;
    //            alarmweek3=NO;
    //        }
    //        else
    //        {
    //            cell.OnOff.on = YES;
    //            alarmweek3=YES;
    //        }
    //
    //        cell.OnOff.tag = 3;
    //
    //    }
    
    
    return cell;
    
}

- (void)buutn:(UIButton *)btn{
    isWatchSetAlarm = NO;
    //    [self saveButton:nil];
    AlarmSetViewController *vc = [[AlarmSetViewController alloc] init];
    vc.title = NSLocalizedString(@"watch_alarm_edit", nil);
    vc.watchModel = _watchModelArr[btn.tag];
    alarm_pick=btn.tag+1;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)saveButton:(id)sender {
    //    model.weekAlarm1 = [NSString stringWithFormat:@"%@:%@",alarmweek1 == YES?@"1":@"0",str_weekalarm1];
    //    model.weekAlarm2 = [NSString stringWithFormat:@"%@:%@",alarmweek2 == YES?@"1":@"0",str_weekalarm2];
    //    model.weekAlarm3 = [NSString stringWithFormat:@"%@:%@",alarmweek3 == YES?@"1":@"0",str_weekalarm3];
    
    if((str_alarm1.length == 0)||([str_alarm1 rangeOfString:@"null"].location !=NSNotFound))
    {
        str_alarm1=@"00:00";
    }
    if((str_alarm2.length == 0)||([str_alarm2 rangeOfString:@"null"].location !=NSNotFound))
    {
        str_alarm2=@"00:00";
    }
    if((str_alarm3.length == 0)||([str_alarm3 rangeOfString:@"null"].location !=NSNotFound))
    {
        str_alarm3=@"00:00";
    }
    
    if(0)
        //if([[defaults objectForKey:@"Alarm1"] intValue]  == model.alarm1.intValue && [[defaults objectForKey:@"Alarm2"] intValue]  == model.alarm2.intValue && [[defaults objectForKey:@"Alarm3"] intValue]  == model.alarm3.intValue)
    {
        
        return;
    }
    else
    {
        WatchModel* watchModel1 = _watchModelArr[0];
        WatchModel* watchModel2 = _watchModelArr[1];
        WatchModel* watchModel3 = _watchModelArr[2];
        NSString* strWeekAlarm1 = [NSString stringWithFormat:@"%@:%@",watchModel1.weekAlarm,watchModel1.week];
        NSString* strWeekAlarm2 = [NSString stringWithFormat:@"%@:%@",watchModel2.weekAlarm,watchModel2.week];
        NSString* strWeekAlarm3 = [NSString stringWithFormat:@"%@:%@",watchModel3.weekAlarm,watchModel3.week];
        WebService *webService = [WebService newWithWebServiceAction:@"UpdateDeviceSet" andDelegate:self];
        webService.tag = 0;
        
        WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"POST" andValue:@"watchinfo/updateAlarm"];
        WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"token" andValue:[defaults objectForKey:MAIN_USER_TOKEN]];
        WebServiceParameter *parameter3 = [WebServiceParameter newWithKey:@"imei" andValue:[defaults objectForKey:@"binnumber"]];
        WebServiceParameter *parameter4 = [WebServiceParameter newWithKey:@"weekAlarm1" andValue:strWeekAlarm1];
        WebServiceParameter *parameter5 = [WebServiceParameter newWithKey:@"weekAlarm2" andValue:strWeekAlarm2];
        WebServiceParameter *parameter6 = [WebServiceParameter newWithKey:@"weekAlarm3" andValue:strWeekAlarm3];
        WebServiceParameter *parameter7 = [WebServiceParameter newWithKey:@"alarm1" andValue:watchModel1.alarm];
        WebServiceParameter *parameter8 = [WebServiceParameter newWithKey:@"alarm2" andValue:watchModel2.alarm];
        WebServiceParameter *parameter9 = [WebServiceParameter newWithKey:@"alarm3" andValue:watchModel3.alarm];
        NSArray *parameter = @[parameter1, parameter2,parameter3,parameter4,parameter5,parameter6,parameter7,parameter8,parameter9];
        // webservice请求并获得结果
        webService.webServiceParameter = parameter;
        [webService getWebServiceResult:@"UpdateDeviceSetResult"];
        
        //[self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)WebServiceGetCompleted:(id)theWebService
{
    WatchModel* watchModel1 = _watchModelArr[0];
    WatchModel* watchModel2 = _watchModelArr[1];
    WatchModel* watchModel3 = _watchModelArr[2];
    NSString* strWeekAlarm1 = [NSString stringWithFormat:@"%@:%@",watchModel1.weekAlarm,watchModel1.week];
    NSString* strWeekAlarm2 = [NSString stringWithFormat:@"%@:%@",watchModel2.weekAlarm,watchModel2.week];
    NSString* strWeekAlarm3 = [NSString stringWithFormat:@"%@:%@",watchModel3.weekAlarm,watchModel3.week];
    WebService *ws = theWebService;
    
    if ([[theWebService soapResults] length] > 0) {
        
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        // 解析成json数据
        id object = [parser objectWithString:[theWebService soapResults] error:&error];
        
        if (!error && object) {
            // 获得状态
            int code = [[object objectForKey:@"Code"] intValue];
            //self.saveBtn.enabled = YES;
            
            if(code == 1)
            {
                [manager updataSQL:@"device_set" andType:@"weekAlarm1" andValue:strWeekAlarm1 andBindle:[defaults objectForKey:@"binnumber"]];
                [manager updataSQL:@"device_set" andType:@"weekAlarm2" andValue:strWeekAlarm2 andBindle:[defaults objectForKey:@"binnumber"]];
                [manager updataSQL:@"device_set" andType:@"weekAlarm3" andValue:strWeekAlarm3 andBindle:[defaults objectForKey:@"binnumber"]];
                [manager updataSQL:@"device_set" andType:@"alarm1" andValue:watchModel1.alarm andBindle:[defaults objectForKey:@"binnumber"]];
                [manager updataSQL:@"device_set" andType:@"alarm2" andValue:watchModel2.alarm andBindle:[defaults objectForKey:@"binnumber"]];
                [manager updataSQL:@"device_set" andType:@"alarm3" andValue:watchModel3.alarm andBindle:[defaults objectForKey:@"binnumber"]];
                
                
                //                if (isWatchSetAlarm)
                //                {
                //                    isWatchSetAlarm = YES;
                [self.navigationController popViewControllerAnimated:YES];
                [OMGToast showWithText:NSLocalizedString(@"save_suc", nil) bottomOffset:50 duration:2];
                //                }
                
            }else if(code == 2){
                [OMGToast showWithText:NSLocalizedString(@"send_error_from_device_offline_tips", nil) bottomOffset:50 duration:3];
            }else{
                [OMGToast showWithText:NSLocalizedString(@"check_device_online_tips", nil) bottomOffset:50 duration:3];
            }
            
            //            [OMGToast showWithText:NSLocalizedString([object objectForKey:@"Message"], nil)  bottomOffset:50 duration:2];
            
        }
    }
}

- (void)WebServiceGetError:(id)theWebService error:(NSString *)theError{
    [OMGToast showWithText:NSLocalizedString(@"waring_internet_error", nil) bottomOffset:50 duration:3];
}

- (void)setviewinfo
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString*)getWeekString:(NSString*)week
{
    NSMutableString* strWeek = @"";
    
    for(int i = 0; i < week.length;i++)
    {
        NSString* index = [week substringWithRange:NSMakeRange(i, 1)];
        if(index.intValue == 1)
        {
            strWeek=[strWeek stringByAppendingString:NSLocalizedString(@"Monday", nil)];
        }
        else if(index.intValue == 2)
        {
            strWeek=[strWeek stringByAppendingString:NSLocalizedString(@"Tuesday", nil)];
        }
        else if(index.intValue == 3)
        {
            strWeek=[strWeek stringByAppendingString:NSLocalizedString(@"Wednesday", nil)];
        }
        else if(index.intValue == 4)
        {
            strWeek=[strWeek stringByAppendingString:NSLocalizedString(@"Thursday", nil)];
        }
        else if(index.intValue == 5)
        {
            strWeek=[strWeek stringByAppendingString:NSLocalizedString(@"Friday", nil)];
        }
        else if(index.intValue == 6)
        {
            strWeek=[strWeek stringByAppendingString:NSLocalizedString(@"Saturday", nil)];
        }
        else if(index.intValue == 7)
        {
            strWeek=[strWeek stringByAppendingString:NSLocalizedString(@"Weekday", nil)];
        }
    }
    
    return strWeek.copy;
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
