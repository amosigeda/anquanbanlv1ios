//
//  OpenAndCloseViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "OpenAndCloseViewController.h"
#import "DataManager.h"
#import "DeviceSetModel.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "OMGToast.h"
#import "DeviceModel.h"
#import "LoginViewController.h"

extern BOOL is_D8_show;
@interface OpenAndCloseViewController ()<UIPickerViewDataSource,UIPickerViewDelegate>
{
    NSMutableArray *hourArray;
    NSMutableArray *minArray;
    NSMutableArray *array;
    DeviceSetModel *model;
    NSUserDefaults *defaults;
    NSMutableArray *deviceArray;
    DeviceModel *deviceModel;
    DataManager *manager ;
}
@end

@implementation OpenAndCloseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    self.saveButton.backgroundColor = MCN_buttonColor;
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
    
    if(is_D8_show==YES)
    {
        self.openTimeLabel.text = NSLocalizedString(@"turn_on_time_d8", nil);
        self.closeTimeLabel.text = NSLocalizedString(@"turn_off_time_d8", nil);
    }
    else{
        self.openTimeLabel.text = NSLocalizedString(@"turn_on_time", nil);
        self.closeTimeLabel.text = NSLocalizedString(@"turn_off_time", nil);
    }
    [self.cancelBtn setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [self.confirmBtn setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
    [self.saveButton setTitle:NSLocalizedString(@"save", nil) forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated
{
    defaults = [NSUserDefaults standardUserDefaults];
    
    manager = [DataManager shareInstance];
    
    array =   [manager isSelectDeviceSetTable:[defaults objectForKey:@"binnumber"]];
    
    model = [array objectAtIndex:0];
    
    deviceArray = [manager isSelect:[defaults objectForKey:@"binnumber"]];
    
    deviceModel = [deviceArray objectAtIndex:0];

    
    self.openTime.text = model.TimerOpen;
    self.closeTime.text = model.TimerClose;
    if(model.TimerOpen.length == 0)
    {
        [defaults setObject:@"06:00" forKey:@"TimeOpen"];
        
    }
    else
    {
        [defaults setObject:self.openTime.text forKey:@"TimeOpen"];
        
    }
    
    if(model.TimerClose.length == 0)
    {
        [defaults setObject:@"22:00" forKey:@"TimeClose"];
        
    }
    else
    {
        [defaults setObject:self.closeTime.text forKey:@"TimeOpen"];
        
    }

}

- (void)setviewinfo
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)openAction:(id)sender {
    
    self.bgView.hidden = NO;
    self.pickView.tag = 1;
    
    if([model.TimerOpen isEqualToString:@""] || [model.TimerOpen isEqualToString:@"(null)"])
    {
        [self.pickView selectRow:6 inComponent:0 animated:NO];
        [self.pickView selectRow:0 inComponent:1 animated:NO];

    }
    else
    {
        [self.pickView selectRow:[[[model.TimerOpen  componentsSeparatedByString:@":"] objectAtIndex:0] intValue]inComponent:0 animated:NO];
         [self.pickView selectRow:[[[model.TimerOpen  componentsSeparatedByString:@":"] objectAtIndex:1] intValue]inComponent:1 animated:NO];
    }

}

- (IBAction)closeAction:(id)sender {
    
    self.bgView.hidden = NO;
    self.pickView.tag = 2;
    
    if([model.TimerClose isEqualToString:@""] || [model.TimerClose isEqualToString:@"(null)"] )
    {
        [self.pickView selectRow:6 inComponent:0 animated:NO];
        [self.pickView selectRow:0 inComponent:1 animated:NO];

    }
    else
    {
        [self.pickView selectRow:[[[model.TimerClose  componentsSeparatedByString:@":"] objectAtIndex:0] intValue]inComponent:0 animated:NO];
        [self.pickView selectRow:[[[model.TimerClose  componentsSeparatedByString:@":"] objectAtIndex:1] intValue]inComponent:1 animated:NO];
    }
}

- (IBAction)cancelBtn:(id)sender {
    
    self.bgView.hidden = YES;
}

- (IBAction)confirmBtn:(id)sender {
    
    if(self.pickView.tag == 1)
    {
         self.openTime.text = [NSString stringWithFormat:@"%@:%@",[hourArray objectAtIndex:[self.pickView selectedRowInComponent:0]],[minArray objectAtIndex:[self.pickView selectedRowInComponent:1]]];
        [defaults setObject:self.openTime.text forKey:@"TimeOpen"];
    }
    else
    {
        self.closeTime.text = [NSString stringWithFormat:@"%@:%@",[hourArray objectAtIndex:[self.pickView selectedRowInComponent:0]],[minArray objectAtIndex:[self.pickView selectedRowInComponent:1]]];
        [defaults setObject:self.closeTime.text forKey:@"TimeClose"];

    }
    self.bgView.hidden = YES;
   
}

- (IBAction)saveBtn:(id)sender {
    
//    NSString *str1 =[NSString stringWithFormat:@"%@%@",[[[defaults objectForKey:@"TimeOpen"] componentsSeparatedByString:@":"] objectAtIndex:0],[[[defaults objectForKey:@"TimeOpen"] componentsSeparatedByString:@":"] objectAtIndex:1]];
//    NSString *str2 =[NSString stringWithFormat:@"%@%@",[[[defaults objectForKey:@"TimeClose"] componentsSeparatedByString:@":"] objectAtIndex:0],[[[defaults objectForKey:@"TimeClose"] componentsSeparatedByString:@":"] objectAtIndex:1]];
//    
//    if(str1.intValue > str2.intValue)
//    {
//        [OMGToast showWithText:@"开机时间不能超过关机时间" bottomOffset:50 duration:3];
//        return;
//    }
    
    WebService *webService = [WebService newWithWebServiceAction:@"UpdateDeviceSet" andDelegate:self];
    webService.tag = 0;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"POST" andValue:@"school/timeSwitch"];
    WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"token" andValue:[defaults objectForKey:MAIN_USER_TOKEN]];
    WebServiceParameter *parameter3 = [WebServiceParameter newWithKey:@"imei" andValue:[defaults objectForKey:@"binnumber"]];
    WebServiceParameter *parameter4 = [WebServiceParameter newWithKey:@"timeClose" andValue: self.closeTime.text];
    WebServiceParameter *parameter5 = [WebServiceParameter newWithKey:@"timeOpen" andValue:self.openTime.text];

    NSArray *parameter = @[parameter1, parameter2,parameter3, parameter4,parameter5];
    // webservice请求并获得结果
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
                [manager updataSQL:@"device_set" andType:@"TimerClose" andValue:self.closeTime.text andBindle:[defaults objectForKey:@"binnumber"]];
                [manager updataSQL:@"device_set" andType:@"TimerOpen" andValue:self.openTime.text andBindle:[defaults objectForKey:@"binnumber"]];
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
