//
//  XiaoquSetViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "XiaoquSetViewController.h"
#import "HomeViewController.h"
#import "DataManager.h"
#import "DeviceSetModel.h"
#import "ScoolMapViewController.h"
#import "DeviceModel.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "OMGToast.h"
#import "LoginViewController.h"


@interface XiaoquSetViewController ()<UIPickerViewDataSource,UIPickerViewDelegate>
{
    NSMutableArray *hourArray;
    NSMutableArray *minArray;
    NSMutableArray *deviceArray;
    NSMutableArray *array;
    DeviceSetModel *model;
    DeviceModel *deviceModel;
    NSUserDefaults *defaults;
    DataManager *manager;
}
@end

@implementation XiaoquSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.block = ^(NSString *homeText) {
        deviceModel.HomeAddress = homeText;
    };
    defaults = [NSUserDefaults standardUserDefaults];
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
    
    self.timeLabel.text = NSLocalizedString(@"latest_home_time", nil);
    [self.cancelBtn setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [self.confirmBtn setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
    [self.saveBtn setTitle:NSLocalizedString(@"save", nil) forState:UIControlStateNormal];


}

- (void)viewWillAppear:(BOOL)animated
{
    manager = [DataManager shareInstance];
    
    array =   [manager isSelectDeviceSetTable:[defaults objectForKey:@"binnumber"]];
    
    model = [array objectAtIndex:0];
    
    deviceArray = [manager isSelect:[defaults objectForKey:@"binnumber"]];
    deviceModel = [deviceArray objectAtIndex:0];
    if(manager.homeText == nil)
    {
        if (deviceModel.HomeLng.doubleValue>0&&deviceModel.HomeLat.doubleValue>0) {
            self.addressLabel.text  = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"adress", nil),deviceModel.HomeAddress];
        }else
        {
            self.addressLabel.text = @"暂无地址信息";
        }
    }else{
        self.addressLabel.text  = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"adress", nil),manager.homeText];
    }
    [self.timeBtn setTitle:deviceModel.LatestTime forState:UIControlStateNormal];
}

- (void)setviewinfo
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)timeBtn:(id)sender {
    
    self.bgView.hidden = NO;
    if(deviceModel.LatestTime.length == 0 || [deviceModel.LatestTime isEqualToString:@"(null)"])
    {
        [self.pickView selectRow:0 inComponent:0 animated:NO];
        [self.pickView selectRow:0 inComponent:1 animated:NO];
    }
    else
    {
        [self.pickView selectRow:[[[deviceModel.LatestTime componentsSeparatedByString:@":"] objectAtIndex:0] intValue] inComponent:0 animated:NO];
        [self.pickView selectRow:[[[deviceModel.LatestTime componentsSeparatedByString:@":"] objectAtIndex:1] intValue] inComponent:1 animated:NO];
    }
}

- (IBAction)cancelBtn:(id)sender {
    
    self.bgView.hidden = YES;
}

- (IBAction)confirmBtn:(id)sender {
    
    [self.timeBtn setTitle:[NSString stringWithFormat:@"%@:%@",[hourArray objectAtIndex:[self.pickView selectedRowInComponent:0]],[minArray objectAtIndex:[self.pickView selectedRowInComponent:1]]] forState:UIControlStateNormal];
    
    self.bgView.hidden = YES;
}

- (IBAction)saveBtn:(id)sender {
    
    manager = [DataManager shareInstance];
    
    array =   [manager isSelectDeviceSetTable:[defaults objectForKey:@"binnumber"]];
    
    model = [array objectAtIndex:0];
    
    deviceArray = [manager isSelect:[defaults objectForKey:@"binnumber"]];
    
    deviceModel = [deviceArray objectAtIndex:0];
    
    if(self.timeBtn.titleLabel.text.length == 0){
        [OMGToast showWithText:NSLocalizedString(@"set_time", nil) bottomOffset:50 duration:3];
        return;
    }
    
    NSString *str1 =[NSString stringWithFormat:@"%@%@",[[model.ClassDisabled4 componentsSeparatedByString:@":"] objectAtIndex:0],[[model.ClassDisabled4 componentsSeparatedByString:@":"] objectAtIndex:1]];
    NSString *str2 =[NSString stringWithFormat:@"%@%@",[[self.timeBtn.titleLabel.text componentsSeparatedByString:@":"] objectAtIndex:0],[[self.timeBtn.titleLabel.text componentsSeparatedByString:@":"] objectAtIndex:1]];
    
    if(str1.intValue > str2.intValue){
        [OMGToast showWithText:NSLocalizedString(@"lasttime_early_classover", nil) bottomOffset:50 duration:3];
        return;
    }
    NSString* address = self.addressLabel.text;
    address = [address stringByReplacingOccurrencesOfString:NSLocalizedString(@"adress", nil) withString:@""];
    
    if([self.timeBtn.titleLabel.text isEqualToString:deviceModel.LatestTime] &&[ address isEqualToString:deviceModel.HomeAddress])
    {
        [OMGToast showWithText:NSLocalizedString(@"edit_suc", nil) bottomOffset:50 duration:2];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        WebService *webService = [WebService newWithWebServiceAction:@"UpdateDevice" andDelegate:self];
        webService.tag = 0;
        WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"POST" andValue:@"watchinfo/updateHomeAndFamily"];
        WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"token" andValue:[defaults objectForKey:MAIN_USER_TOKEN]];
        WebServiceParameter *parameter3 = [WebServiceParameter newWithKey:@"imei" andValue:[defaults objectForKey:@"binnumber"]];
        WebServiceParameter *parameter4 = [WebServiceParameter newWithKey:@"id" andValue:[defaults objectForKey:@"binnumber"]];
        WebServiceParameter *parameter5 = [WebServiceParameter newWithKey:@"homeAddress" andValue:address];
        WebServiceParameter *parameter6 = [WebServiceParameter newWithKey:@"homeLat" andValue:deviceModel.HomeLat];
        WebServiceParameter *parameter7 = [WebServiceParameter newWithKey:@"homeLng" andValue:deviceModel.HomeLng];
        WebServiceParameter *parameter8 = [WebServiceParameter newWithKey:@"schoolAddress" andValue:deviceModel.SchoolAddress];
        WebServiceParameter *parameter9 = [WebServiceParameter newWithKey:@"schoolLat" andValue:deviceModel.SchoolLat];
        WebServiceParameter *parameter10 = [WebServiceParameter newWithKey:@"schoolLng" andValue:deviceModel.SchoolLng];
        WebServiceParameter *parameter11;
        if(model.ClassDisabled1.length && model.ClassDisabled2.length){
            parameter11 = [WebServiceParameter newWithKey:@"classDisable1" andValue:[NSString stringWithFormat:@"%@-%@",model.ClassDisabled1,model.ClassDisabled2]];
        }else{
            parameter11 = [WebServiceParameter newWithKey:@"classDisable1" andValue:@"00:00"];
        }
        WebServiceParameter *parameter12;
        if(model.ClassDisabled3.length && model.ClassDisabled4.length){
            parameter12 = [WebServiceParameter newWithKey:@"classDisable2" andValue:[NSString stringWithFormat:@"%@-%@",model.ClassDisabled3,model.ClassDisabled4]];
        }else{
            parameter12 = [WebServiceParameter newWithKey:@"classDisable2" andValue:@"00:00"];
        }
        WebServiceParameter *parameter13 = [WebServiceParameter newWithKey:@"weekDisable" andValue:model.WeekDisabled];
        WebServiceParameter *parameter14 = [WebServiceParameter newWithKey:@"latestTime" andValue:self.timeBtn.titleLabel.text];
        
        NSArray *parameter = @[parameter1, parameter2,parameter3,parameter4,parameter5,parameter6,parameter7,parameter8,parameter9,parameter10,parameter11,parameter12,parameter13,parameter14];
        // webservice请求并获得结果
        webService.webServiceParameter = parameter;
        self.saveBtn.enabled = NO;
        [webService getWebServiceResult:@"UpdateDeviceResult"];
    }
}

- (void)WebServiceGetCompleted:(id)theWebService
{
    self.saveBtn.enabled = YES;

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
                [defaults setObject:@"0" forKey:@"pop"];

                [manager updataSQL:@"favourite_info" andType:@"LatestTime" andValue:self.timeBtn.titleLabel.text andBindle:[defaults objectForKey:@"binnumber"]];
                
                [OMGToast showWithText:NSLocalizedString(@"edit_suc", nil) bottomOffset:50 duration:1];
                [self.navigationController popViewControllerAnimated:YES];
            }else
            {
                [OMGToast showWithText:NSLocalizedString(@"edit_fail", nil) bottomOffset:50 duration:1];
            }
        }
    }
}

- (void)WebServiceGetError:(id)theWebService error:(NSString *)theError{
    self.saveBtn.enabled = YES;
    [OMGToast showWithText:NSLocalizedString(@"waring_internet_error", nil) bottomOffset:50 duration:3];
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

- (IBAction)xiaoquBtn:(id)sender {
    
    HomeViewController *vc =[[ HomeViewController alloc] init];
    vc.title = NSLocalizedString(@"set_home_location", nil);
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
