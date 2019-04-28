//
//  SleepViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "SleepViewController.h"
#import "StepTableViewCell.h"
#import "DataManager.h"
#import "DeviceSetModel.h"
#import "DeviceModel.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "EditHeadAndNameViewController.h"
#import "STAlertView.h"
#import "DXAlertView.h"
#import "LoginViewController.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "WatchFirmwareViewController.h"
#import "JSON.h"
#import "OMGToast.h"
#import "LocationModel.h"

extern NSString *str_sleepnum;
extern NSString *str_sleep;
extern NSString *str_sleep_onoff;
NSString *str_sleep_set;
NSString *SleepDisabled1;
NSString *SleepDisabled2;
NSString *SleepDisabled3;
NSString *SleepDisabled4;

@interface SleepViewController ()<UIPickerViewDataSource,UIPickerViewDelegate,WebServiceProtocol>
{
    BOOL isSelect;
    NSUserDefaults *defaults;
    
    NSMutableArray *hourArray;
    NSMutableArray *minArray;
    NSMutableArray *array;
    NSMutableArray *deviceArray;
    LocationModel *model;
    DeviceModel *deviceModel;
    DataManager *manager ;

}
@end


@implementation SleepViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isSelect = NO;
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
    
    hourArray = [[NSMutableArray alloc] init];
    for(int i = 0;i < 24;i++)
    {
        if(i >= 0 && i <= 9)
        {
            [hourArray addObject:[NSString stringWithFormat:@"0%d",i]];
        }
        else
        {
            [hourArray addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    
    minArray = [[NSMutableArray alloc] init];
    for(int i = 0;i <= 59;i++)
    {
        if(i >= 0 && i <= 9)
        {
            [minArray addObject:[NSString stringWithFormat:@"0%d",i]];
        }
        else
        {
            [minArray addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    
    self.pickView.delegate = self;
    self.pickView.dataSource = self;
    self.bgView.hidden = YES;
    
    self.timeLabel.text = NSLocalizedString(@"watch_sleep_title", nil);
    self.period1Label.text = NSLocalizedString(@"watch_sleep_time1", nil);
    self.period2Label.text = NSLocalizedString(@"watch_sleep_time2", nil);
    [self.cancelBtn setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [self.confirmBtn setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
    [self.saveBtn setTitle:NSLocalizedString(@"save", nil) forState:UIControlStateNormal];
   
    if(str_sleepnum.length==0)
    {
        str_sleepnum=@"1";
    }
    double sleep_zhiliang = [str_sleepnum doubleValue];
    
    if(sleep_zhiliang==1){
        self.jieguo2Label.text = NSLocalizedString(@"sleep_jieguo1", nil);
    }
    else if(sleep_zhiliang==2){
        self.jieguo2Label.text = NSLocalizedString(@"sleep_jieguo2", nil);
    }
    else if(sleep_zhiliang==3){
        self.jieguo2Label.text = NSLocalizedString(@"sleep_jieguo3", nil);
    }
    else{
        self.jieguo2Label.text = NSLocalizedString(@"sleep_jieguo1", nil);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    defaults = [NSUserDefaults standardUserDefaults];
    manager = [DataManager shareInstance];
    
    array =   [manager isSelectDeviceSetTable:[defaults objectForKey:@"binnumber"]];
    
    model = [array objectAtIndex:0];
    
    deviceArray = [manager isSelect:[defaults objectForKey:@"binnumber"]];
    
    deviceModel = [deviceArray objectAtIndex:0];
    
    if(str_sleep_set.length!=0&&([str_sleep_set rangeOfString:@"null"].location == NSNotFound))
    {
        SleepDisabled1=[str_sleep_set substringWithRange:NSMakeRange(0,5)];
        SleepDisabled2=[str_sleep_set substringWithRange:NSMakeRange(6,[str_sleep_set length]-18)];
        SleepDisabled3=[str_sleep_set substringWithRange:NSMakeRange(12,[str_sleep_set length]-18)];
        SleepDisabled4=[str_sleep_set substringWithRange:NSMakeRange(18,[str_sleep_set length]-18)];
    }
    [self.morningStarBtn setTitle:SleepDisabled1 forState:UIControlStateNormal];
    [self.morningEndBtn setTitle:SleepDisabled2 forState:UIControlStateNormal];
    [self.afternoonStarBtn setTitle:SleepDisabled3 forState:UIControlStateNormal];
    [self.afternoonEndBtn setTitle:SleepDisabled4 forState:UIControlStateNormal];
    
    
    if(SleepDisabled1 == 0)
    {
        [self.morningStarBtn setTitle:@"00:00" forState:UIControlStateNormal];
        SleepDisabled1=@"00:00";
    }
    else
    {
        [self.morningStarBtn setTitle:SleepDisabled1 forState:UIControlStateNormal];
    }
    
    if(SleepDisabled2.length == 0)
    {
        [self.morningEndBtn setTitle:@"08:00" forState:UIControlStateNormal];
        SleepDisabled2=@"08:00";
    }
    else
    {
        [self.morningEndBtn setTitle:SleepDisabled2 forState:UIControlStateNormal];
        
    }
    
    if(SleepDisabled3.length == 0)
    {
        [self.afternoonStarBtn setTitle:@"13:00" forState:UIControlStateNormal];
        SleepDisabled3=@"13:00";
    }
    else
    {
        [self.afternoonStarBtn setTitle:SleepDisabled3 forState:UIControlStateNormal];
    }
    
    if(SleepDisabled4.length == 0)
    {
        [self.afternoonEndBtn setTitle:@"14:00" forState:UIControlStateNormal];
        SleepDisabled4=@"14:00";
    }
    else
    {
        [self.afternoonEndBtn setTitle:SleepDisabled4 forState:UIControlStateNormal];
        
    }
    
}

- (IBAction)timeSelectBtn:(id)sender {
    UIButton *btn = sender;
    self.bgView.hidden = NO;
    self.sleepLabel.hidden = YES;
    self.jieguo2Label.hidden = YES;
    self.ImageView.hidden = YES;
    
    if(btn.tag == 1)
    {
        self.pickView.tag = 1;
        [self.pickView selectRow:[[[SleepDisabled1 componentsSeparatedByString:@":"] objectAtIndex:0] intValue] inComponent:0 animated:NO];
        [self.pickView selectRow:[[[SleepDisabled1 componentsSeparatedByString:@":"] objectAtIndex:1] intValue] inComponent:1 animated:NO];
    }
    else if(btn.tag == 2)
    {
        self.pickView.tag = 2;
        [self.pickView selectRow:[[[SleepDisabled2 componentsSeparatedByString:@":"] objectAtIndex:0] intValue] inComponent:0 animated:NO];
        [self.pickView selectRow:[[[SleepDisabled2 componentsSeparatedByString:@":"] objectAtIndex:1] intValue] inComponent:1 animated:NO];
    }
    else if(btn.tag == 3)
    {
        self.pickView.tag =3;
        [self.pickView selectRow:[[[SleepDisabled3 componentsSeparatedByString:@":"] objectAtIndex:0] intValue] inComponent:0 animated:NO];
        [self.pickView selectRow:[[[SleepDisabled3 componentsSeparatedByString:@":"] objectAtIndex:1] intValue] inComponent:1 animated:NO];
    }
    else if(btn.tag == 4)
    {
        self.pickView.tag = 4;
        [self.pickView selectRow:[[[SleepDisabled4 componentsSeparatedByString:@":"] objectAtIndex:0] intValue] inComponent:0 animated:NO];
        [self.pickView selectRow:[[[SleepDisabled4 componentsSeparatedByString:@":"] objectAtIndex:1] intValue] inComponent:1 animated:NO];
    }
    
}

- (IBAction)saveBtn:(id)sender {
    SleepDisabled1 =[NSString stringWithFormat:@"%@:%@",[[self.morningStarBtn.titleLabel.text componentsSeparatedByString:@":"] objectAtIndex:0],[[self.morningStarBtn.titleLabel.text componentsSeparatedByString:@":"] objectAtIndex:1]];
    SleepDisabled2 =[NSString stringWithFormat:@"%@:%@",[[self.morningEndBtn.titleLabel.text  componentsSeparatedByString:@":"] objectAtIndex:0],[[self.morningEndBtn.titleLabel.text componentsSeparatedByString:@":"] objectAtIndex:1]];
    SleepDisabled3 =[NSString stringWithFormat:@"%@:%@",[[self.afternoonStarBtn.titleLabel.text componentsSeparatedByString:@":"] objectAtIndex:0],[[self.afternoonStarBtn.titleLabel.text componentsSeparatedByString:@":"] objectAtIndex:1]];
    SleepDisabled4 =[NSString stringWithFormat:@"%@:%@",[[self.afternoonEndBtn.titleLabel.text componentsSeparatedByString:@":"] objectAtIndex:0],[[self.afternoonEndBtn.titleLabel.text componentsSeparatedByString:@":"] objectAtIndex:1]];
    
    str_sleep_set=[NSString stringWithFormat:@"%@-%@|%@-%@",SleepDisabled1,SleepDisabled2,SleepDisabled3,SleepDisabled4];
    str_sleep=[NSString stringWithFormat:@"%@|%@",str_sleep_onoff,str_sleep_set];
    /*
    if(SleepDisabled1.intValue > SleepDisabled2.intValue)
    {
        [OMGToast showWithText:NSLocalizedString(@"select_sleep_time", nil) bottomOffset:50 duration:3];
        return;
    }
    
    if(SleepDisabled3.intValue > SleepDisabled4.intValue)
    {
        [OMGToast showWithText:NSLocalizedString(@"select_sleep_time", nil) bottomOffset:50 duration:3];
        return;
        
    }
    if(SleepDisabled2.intValue > SleepDisabled3.intValue)
    {
        [OMGToast showWithText:NSLocalizedString(@"select_sleep_time", nil) bottomOffset:50 duration:3];
        return;
    }
     */
    
    WebService *webService = [WebService newWithWebServiceAction:@"UpdateDeviceSet" andDelegate:self];
    webService.tag = 0;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"GET" andValue:[NSString stringWithFormat:@"school/updateSleepCalculate/%@/%@/%@",[defaults objectForKey:MAIN_USER_TOKEN],[defaults objectForKey:@"binnumber"],str_sleep]];
    NSArray *parameter = @[parameter1];
    // webservice请求并获得结
    
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"UpdateDeviceSetResult"];
}


- (void)WebServiceGetCompleted:(id)theWebService
{
    if ([[theWebService soapResults] length] > 0) {
        
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        // 解析成json数据
        id object = [parser objectWithString:[theWebService soapResults] error:&error];
        
        if (!error && object) {
            // 获得状态
            int code = [[object objectForKey:@"Code"] intValue];
            if(code == 1){
                [manager updataSQL:@"device_set" andType:@"sleepCalculate" andValue:str_sleep andBindle:[defaults objectForKey:@"binnumber"]];
                [OMGToast showWithText:NSLocalizedString(@"edit_suc", nil) bottomOffset:50 duration:1];
                [self.navigationController popViewControllerAnimated:YES];
                
            }else{
                [OMGToast showWithText:NSLocalizedString(@"edit_fail", nil) bottomOffset:50 duration:1];
            }
        }
    }
}

- (void)WebServiceGetError:(id)theWebService error:(NSString *)theError{
    [OMGToast showWithText:NSLocalizedString(@"waring_internet_error", nil) bottomOffset:50 duration:3];
}

- (IBAction)cancelBtn:(id)sender {
    
    self.bgView.hidden = YES;
    self.sleepLabel.hidden = NO;
    self.jieguo2Label.hidden = NO;
    self.ImageView.hidden = NO;
    
}

- (IBAction)confirmBtn:(id)sender {
    
    self.sleepLabel.hidden = NO;
    self.jieguo2Label.hidden = NO;
    self.ImageView.hidden = NO;
    
    if(self.pickView.tag == 1)
    {
        [self.morningStarBtn setTitle:[NSString stringWithFormat:@"%@:%@",[hourArray objectAtIndex:[self.pickView selectedRowInComponent:0]],[minArray objectAtIndex:[self.pickView selectedRowInComponent:1]]] forState:UIControlStateNormal];
        
    }
    else if(self.pickView.tag == 2)
    {
        [self.morningEndBtn setTitle:[NSString stringWithFormat:@"%@:%@",[hourArray objectAtIndex:[self.pickView selectedRowInComponent:0]],[minArray objectAtIndex:[self.pickView selectedRowInComponent:1]]] forState:UIControlStateNormal];
        
    }
    else if(self.pickView.tag == 3)
    {
        [self.afternoonStarBtn setTitle:[NSString stringWithFormat:@"%@:%@",[hourArray objectAtIndex:[self.pickView selectedRowInComponent:0]],[minArray objectAtIndex:[self.pickView selectedRowInComponent:1]]] forState:UIControlStateNormal];
        
    }
    else if(self.pickView.tag == 4)
    {
        [self.afternoonEndBtn setTitle:[NSString stringWithFormat:@"%@:%@",[hourArray objectAtIndex:[self.pickView selectedRowInComponent:0]],[minArray objectAtIndex:[self.pickView selectedRowInComponent:1]]] forState:UIControlStateNormal];
    }
    
    self.bgView.hidden = YES;
    
}

// pickerView 列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

// pickerView 每列个数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return [hourArray count];
    }
    
    return [minArray count];
}

// 每列宽度
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    
    return 60;
}
// 返回选中的行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
}

//返回当前行的内容,此处是将数组中数值添加到滚动的那个显示栏上
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0) {
        return [hourArray objectAtIndex:row];
    } else {
        return [minArray objectAtIndex:row];
        
    }
}


- (void)setviewinfo
{
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
