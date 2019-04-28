//
//  SchoolListViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "SchoolListViewController.h"
#import "ZHPickView.h"
#import "DataManager.h"
#import "DeviceSetModel.h"
#import "ScoolMapViewController.h"
#import "DeviceModel.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "DataManager.h"
#import "DeviceModel.h"
#import "OMGToast.h"
#import "LoginViewController.h"


@interface SchoolListViewController ()<UIPickerViewDataSource,UIPickerViewDelegate>

{
    BOOL isSelect;
    NSMutableArray *hourArray;
    NSMutableArray *deviceArray;
    NSMutableArray *minArray;
    NSMutableArray *array;
    DeviceSetModel *model;
    DeviceModel *deviceModel;
    BOOL mon;
    BOOL tue;
    BOOL thr;
    BOOL thur;
    BOOL fri;
    BOOL sat;
    BOOL sun;
    DataManager *manager;
    NSString *str;
}
@end

@implementation SchoolListViewController
{
    NSUserDefaults *defaults;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    isSelect = NO;
    defaults = [NSUserDefaults standardUserDefaults];
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    self.savebutton.backgroundColor = MCN_buttonColor;
    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];
    
    if([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self.monBuoon setTitle:NSLocalizedString(@"monday", nil) forState:UIControlStateNormal];
    [self.tueButton setTitle:NSLocalizedString(@"thesday", nil) forState:UIControlStateNormal];
    [self.thrButton setTitle:NSLocalizedString(@"wednesday", nil) forState:UIControlStateNormal];
    [self.thurButton setTitle:NSLocalizedString(@"thursday", nil) forState:UIControlStateNormal];
    [self.friButton setTitle:NSLocalizedString(@"friday", nil) forState:UIControlStateNormal];
    [self.satButton setTitle:NSLocalizedString(@"saturday", nil) forState:UIControlStateNormal];
    [self.sunButton setTitle:NSLocalizedString(@"sunday", nil) forState:UIControlStateNormal];
    
    mon = NO;
    tue = NO;
    thr = NO;
    thur = NO;
    fri = NO;
    sat = NO;
    sun = NO;
    
    [self.monBuoon setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.tueButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.thrButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.thurButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.friButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.satButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.sunButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [self.monBuoon setBackgroundImage:nil forState:UIControlStateNormal];
    [self.tueButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.thrButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.thurButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.friButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.satButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.sunButton setBackgroundImage:nil forState:UIControlStateNormal];
    
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
    
    self.classTimeLabel.text = NSLocalizedString(@"schooltime", nil);
    self.morningLabel.text = NSLocalizedString(@"morning", nil);
    self.afternoonLabel.text = NSLocalizedString(@"afternoon", nil);
    self.weedLabel.text = NSLocalizedString(@"week", nil);
    [self.cancelBtn setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [self.confirmBtn setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
    [self.savebutton setTitle:NSLocalizedString(@"save", nil) forState:UIControlStateNormal];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    manager = [DataManager shareInstance];
    
    array =   [manager isSelectDeviceSetTable:[defaults objectForKey:@"binnumber"]];
    
    model = [array objectAtIndex:0];
    
    deviceArray = [manager isSelect:[defaults objectForKey:@"binnumber"]];
    
    deviceModel = [deviceArray objectAtIndex:0];
    
    [self.morningStarButton setTitle:model.ClassDisabled1 forState:UIControlStateNormal];
    [self.morningEndButton setTitle:model.ClassDisabled2 forState:UIControlStateNormal];
    [self.afternoonStarButton setTitle:model.ClassDisabled3 forState:UIControlStateNormal];
    [self.afternoonEndButton setTitle:model.ClassDisabled4 forState:UIControlStateNormal];
    
    self.addressLabel.text  = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"adress", nil),deviceModel.SchoolAddress];
    if(model.WeekDisabled.length != 0)
    {
        for(int i = 0; i < model.WeekDisabled.length;i++)
        {
            str = [model.WeekDisabled substringWithRange:NSMakeRange(i, 1)];
            if(str.intValue == 1)
            {
                [self.monBuoon setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                //                [self.monBuoon setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
                self.monBuoon.backgroundColor = MCN_buttonColor;
                mon = YES;
            }
            else if(str.intValue == 2)
            {
                [self.tueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                //                [self.tueButton setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
                self.tueButton.backgroundColor = MCN_buttonColor;
                tue = YES;
            }
            else if(str.intValue == 3)
            {
                [self.thrButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                //                [self.thrButton setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
                self.thrButton.backgroundColor = MCN_buttonColor;
                thr = YES;
            }
            else if(str.intValue == 4)
            {
                [self.thurButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                //                [self.thurButton setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
                self.thurButton.backgroundColor = MCN_buttonColor;
                thur = YES;
            }
            else if(str.intValue == 5)
            {
                [self.friButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                //                [self.friButton setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
                self.friButton.backgroundColor = MCN_buttonColor;
                fri = YES;
            }
            else if(str.intValue == 6)
            {
                [self.satButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                //                [self.satButton setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
                self.satButton.backgroundColor = MCN_buttonColor;
                sat = YES;
            }
            else if(str.intValue == 7)
            {
                [self.sunButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                //                [self.sunButton setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
                self.sunButton.backgroundColor = MCN_buttonColor;;
                sun = YES;
            }
            
        }
    }
    
    if(model.ClassDisabled1.length == 0)
    {
        [self.morningStarButton setTitle:@"00:00" forState:UIControlStateNormal];
    }
    if(model.ClassDisabled2.length == 0)
    {
        [self.morningEndButton setTitle:@"00:00" forState:UIControlStateNormal];
        
    }
    if(model.ClassDisabled3.length == 0)
    {
        [self.afternoonStarButton setTitle:@"00:00" forState:UIControlStateNormal];
        
    }
    if(model.ClassDisabled4.length == 0)
    {
        [self.afternoonEndButton setTitle:@"00:00" forState:UIControlStateNormal];
    }
    
}


- (void)setviewinfo
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)timeSelect:(id)sender {
    UIButton *btn = sender;
    self.bgView.hidden = NO;
    
    if(btn.tag == 1)
    {
        self.pickView.tag = 1;
        
        if(model.ClassDisabled1.length == 0)
        {
            [self.pickView selectRow:0 inComponent:0 animated:NO];
            [self.pickView selectRow:0 inComponent:1 animated:NO];
            
        }
        else
        {
            [self.pickView selectRow:[[[model.ClassDisabled1 componentsSeparatedByString:@":"] objectAtIndex:0] intValue] inComponent:0 animated:NO];
            [self.pickView selectRow:[[[model.ClassDisabled1 componentsSeparatedByString:@":"] objectAtIndex:1] intValue] inComponent:1 animated:NO];
        }
    }
    else if(btn.tag == 2)
    {
        self.pickView.tag = 2;
        
        if(model.ClassDisabled2.length == 0)
        {
            [self.pickView selectRow:0 inComponent:0 animated:NO];
            [self.pickView selectRow:0 inComponent:1 animated:NO];
            
        }
        else
        {
            [self.pickView selectRow:[[[model.ClassDisabled2 componentsSeparatedByString:@":"] objectAtIndex:0] intValue] inComponent:0 animated:NO];
            [self.pickView selectRow:[[[model.ClassDisabled2 componentsSeparatedByString:@":"] objectAtIndex:1] intValue] inComponent:1 animated:NO];
        }
    }
    else if(btn.tag == 3)
    {
        self.pickView.tag =3;
        if(model.ClassDisabled3.length == 0)
        {
            [self.pickView selectRow:0 inComponent:0 animated:NO];
            [self.pickView selectRow:0 inComponent:1 animated:NO];
            
        }
        else
        {
            [self.pickView selectRow:[[[model.ClassDisabled3 componentsSeparatedByString:@":"] objectAtIndex:0] intValue] inComponent:0 animated:NO];
            [self.pickView selectRow:[[[model.ClassDisabled3 componentsSeparatedByString:@":"] objectAtIndex:1] intValue] inComponent:1 animated:NO];
        }
    }
    else if(btn.tag == 4)
    {
        self.pickView.tag = 4;
        if(model.ClassDisabled4.length == 0)
        {
            [self.pickView selectRow:0 inComponent:0 animated:NO];
            [self.pickView selectRow:0 inComponent:1 animated:NO];
            
        }
        else
        {
            [self.pickView selectRow:[[[model.ClassDisabled4 componentsSeparatedByString:@":"] objectAtIndex:0] intValue] inComponent:0 animated:NO];
            [self.pickView selectRow:[[[model.ClassDisabled4 componentsSeparatedByString:@":"] objectAtIndex:1] intValue] inComponent:1 animated:NO];
        }
    }
}

- (IBAction)confirmBtn:(id)sender {
    if(self.pickView.tag == 1)
    {
        [self.morningStarButton setTitle:[NSString stringWithFormat:@"%@:%@",[hourArray objectAtIndex:[self.pickView selectedRowInComponent:0]],[minArray objectAtIndex:[self.pickView selectedRowInComponent:1]]] forState:UIControlStateNormal];
        
    }
    else if(self.pickView.tag == 2)
    {
        [self.morningEndButton setTitle:[NSString stringWithFormat:@"%@:%@",[hourArray objectAtIndex:[self.pickView selectedRowInComponent:0]],[minArray objectAtIndex:[self.pickView selectedRowInComponent:1]]] forState:UIControlStateNormal];
        
    }
    else if(self.pickView.tag == 3)
    {
        [self.afternoonStarButton setTitle:[NSString stringWithFormat:@"%@:%@",[hourArray objectAtIndex:[self.pickView selectedRowInComponent:0]],[minArray objectAtIndex:[self.pickView selectedRowInComponent:1]]] forState:UIControlStateNormal];
        
    }
    else if(self.pickView.tag == 4)
    {
        [self.afternoonEndButton setTitle:[NSString stringWithFormat:@"%@:%@",[hourArray objectAtIndex:[self.pickView selectedRowInComponent:0]],[minArray objectAtIndex:[self.pickView selectedRowInComponent:1]]] forState:UIControlStateNormal];
    }
    
    self.bgView.hidden = YES;
    
}

- (IBAction)cancelBtn:(id)sender {
    self.bgView.hidden = YES;
}

- (IBAction)daySelect:(id)sender {
    
    UIButton *btn = sender;
    if(btn.tag == 11)
    {
        if(mon ==  YES)
        {
            [self.monBuoon setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            //            [self.monBuoon setBackgroundImage:nil forState:UIControlStateNormal];
            self.monBuoon.backgroundColor = [UIColor clearColor];
            mon = NO;
        }
        else
        {
            [self.monBuoon setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            //            [self.monBuoon setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
            self.monBuoon.backgroundColor = MCN_buttonColor;
            mon = YES;
            
        }
    }
    else if(btn.tag == 12)
    {
        if(tue ==  YES)
        {
            [self.tueButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            //            [self.tueButton setBackgroundImage:nil forState:UIControlStateNormal];
            self.tueButton.backgroundColor = [UIColor clearColor];
            tue = NO;
        }
        else
        {
            [self.tueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            //            [self.tueButton setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
            self.tueButton.backgroundColor = MCN_buttonColor;
            tue = YES;
            
        }
    }
    else if(btn.tag == 13)
    {
        if(thr ==  YES)
        {
            [self.thrButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            //            [self.thrButton setBackgroundImage:nil forState:UIControlStateNormal];
            self.thrButton.backgroundColor = [UIColor clearColor];
            thr = NO;
        }
        else
        {
            [self.thrButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            //            [self.thrButton setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
            self.thrButton.backgroundColor = MCN_buttonColor;
            thr = YES;
            
        }
    }
    else if(btn.tag == 14)
    {
        if(thur ==  YES)
        {
            [self.thurButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            //            [self.thurButton setBackgroundImage:nil forState:UIControlStateNormal];
            self.thurButton.backgroundColor = [UIColor clearColor];
            thur = NO;
        }
        else
        {
            [self.thurButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            //            [self.thurButton setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
            self.thurButton.backgroundColor = MCN_buttonColor;
            thur = YES;
            
        }
    }
    else if(btn.tag == 15)
    {
        if(fri ==  YES)
        {
            [self.friButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            //            [self.friButton setBackgroundImage:nil forState:UIControlStateNormal];
            self.friButton.backgroundColor = [UIColor clearColor];
            fri = NO;
        }
        else
        {
            [self.friButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            //            [self.friButton setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
            self.friButton.backgroundColor = MCN_buttonColor;
            fri = YES;
            
        }
    }
    else if(btn.tag == 16)
    {
        if(sat ==  YES)
        {
            [self.satButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            //            [self.satButton setBackgroundImage:nil forState:UIControlStateNormal];
            self.satButton.backgroundColor = [UIColor clearColor];
            sat = NO;
        }
        else
        {
            [self.satButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            //            [self.satButton setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
            self.satButton.backgroundColor = MCN_buttonColor;;
            sat = YES;
            
        }
    }
    else if(btn.tag == 17)
    {
        if(sun ==  YES)
        {
            [self.sunButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            //            [self.sunButton setBackgroundImage:nil forState:UIControlStateNormal];
            self.sunButton.backgroundColor = [UIColor clearColor];
            sun = NO;
        }
        else
        {
            [self.sunButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            //            [self.sunButton setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
            self.sunButton.backgroundColor = MCN_buttonColor;
            sun = YES;
        }
    }
}

- (IBAction)saveButton:(id)sender {
    
    manager = [DataManager shareInstance];
    
    array =   [manager isSelectDeviceSetTable:[defaults objectForKey:@"binnumber"]];
    
    model = [array objectAtIndex:0];
    
    deviceArray = [manager isSelect:[defaults objectForKey:@"binnumber"]];
    
    deviceModel = [deviceArray objectAtIndex:0];
    
    NSString *str1 =[NSString stringWithFormat:@"%@%@",[[self.morningStarButton.titleLabel.text componentsSeparatedByString:@":"] objectAtIndex:0],[[self.morningStarButton.titleLabel.text componentsSeparatedByString:@":"] objectAtIndex:1]];
    NSString *str2 =[NSString stringWithFormat:@"%@%@",[[self.morningEndButton.titleLabel.text  componentsSeparatedByString:@":"] objectAtIndex:0],[[self.morningEndButton.titleLabel.text componentsSeparatedByString:@":"] objectAtIndex:1]];
    NSString *str3 =[NSString stringWithFormat:@"%@%@",[[self.afternoonStarButton.titleLabel.text componentsSeparatedByString:@":"] objectAtIndex:0],[[self.afternoonStarButton.titleLabel.text componentsSeparatedByString:@":"] objectAtIndex:1]];
    NSString *str4 =[NSString stringWithFormat:@"%@%@",[[self.afternoonEndButton.titleLabel.text componentsSeparatedByString:@":"] objectAtIndex:0],[[self.afternoonEndButton.titleLabel.text componentsSeparatedByString:@":"] objectAtIndex:1]];
    
    NSString *str5 =[NSString stringWithFormat:@"%@%@",[[deviceModel.LatestTime componentsSeparatedByString:@":"] objectAtIndex:0],[[deviceModel.LatestTime componentsSeparatedByString:@":"] objectAtIndex:1]];
    if(str1.intValue > str2.intValue)
    {
        [OMGToast showWithText:NSLocalizedString(@"select_right_time", nil) bottomOffset:50 duration:3];
        return;
    }
    if(str3.intValue > str4.intValue)
    {
        [OMGToast showWithText:NSLocalizedString(@"select_right_time", nil) bottomOffset:50 duration:3];
        return;
        
    }
    if(str4.intValue > str5.intValue)
    {
        [OMGToast showWithText:NSLocalizedString(@"select_right_time", nil) bottomOffset:50 duration:3];
        return;
    }
    if(str1.intValue > str5.intValue)
    {
        [OMGToast showWithText:NSLocalizedString(@"select_right_time", nil) bottomOffset:50 duration:3];
        return;
    }  if(str2.intValue > str5.intValue)
    {
        [OMGToast showWithText:NSLocalizedString(@"select_right_time", nil) bottomOffset:50 duration:3];
        return;
    }  if(str3.intValue > str5.intValue)
    {
        [OMGToast showWithText:NSLocalizedString(@"select_right_time", nil) bottomOffset:50 duration:3];
        return;
    }
    
    str = [NSString stringWithFormat:@"%@%@%@%@%@%@%@",mon == YES?@"1":@"",tue == YES?@"2":@"",thr == YES?@"3":@"",thur == YES?@"4":@"",fri == YES?@"5":@"",sat == YES?@"6":@"",sun == YES?@"7":@""];
    
    //    if([self.morningStarButton.titleLabel.text isEqualToString:model.ClassDisabled1] && [self.morningEndButton.titleLabel.text isEqualToString:model.ClassDisabled2] && [self.afternoonStarButton.titleLabel.text isEqualToString:model.ClassDisabled3] && [self.afternoonEndButton.titleLabel.text isEqualToString:model.ClassDisabled4] && [str isEqualToString:model.WeekDisabled])
    //    {
    //        [OMGToast showWithText:NSLocalizedString(@"edit_not", nil) bottomOffset:50 duration:2];
    //    }
    //else
    //{
    WebService *webService = [WebService newWithWebServiceAction:@"UpdateDeviceSet" andDelegate:self];
    webService.tag = 0;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"POST" andValue:@"watchinfo/updateHomeAndFamily"];
    WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"token" andValue:[defaults objectForKey:MAIN_USER_TOKEN]];
    WebServiceParameter *parameter3 = [WebServiceParameter newWithKey:@"imei" andValue:[defaults objectForKey:@"binnumber"]];
    WebServiceParameter *parameter4 = [WebServiceParameter newWithKey:@"id" andValue:[defaults objectForKey:@"binnumber"]];
    WebServiceParameter *parameter5 = [WebServiceParameter newWithKey:@"homeAddress" andValue:deviceModel.HomeAddress];
    WebServiceParameter *parameter6 = [WebServiceParameter newWithKey:@"homeLat" andValue:deviceModel.HomeLat];
    WebServiceParameter *parameter7 = [WebServiceParameter newWithKey:@"homeLng" andValue:deviceModel.HomeLng];
    WebServiceParameter *parameter8 = [WebServiceParameter newWithKey:@"schoolAddress" andValue:deviceModel.SchoolAddress];
    WebServiceParameter *parameter9 = [WebServiceParameter newWithKey:@"schoolLat" andValue:deviceModel.SchoolLat];
    WebServiceParameter *parameter10 = [WebServiceParameter newWithKey:@"schoolLng" andValue:deviceModel.SchoolLng];
    WebServiceParameter *parameter11 = [WebServiceParameter newWithKey:@"classDisable1" andValue:[NSString stringWithFormat:@"%@-%@",self.morningStarButton.titleLabel.text,self.morningEndButton.titleLabel.text]];
    WebServiceParameter *parameter12 = [WebServiceParameter newWithKey:@"classDisable2" andValue:[NSString stringWithFormat:@"%@-%@",self.afternoonStarButton.titleLabel.text,self.afternoonEndButton.titleLabel.text]];
    WebServiceParameter *parameter13 = [WebServiceParameter newWithKey:@"weekDisable" andValue:str];
    WebServiceParameter *parameter14 = [WebServiceParameter newWithKey:@"latestTime" andValue:deviceModel.LatestTime];
    
    NSArray *parameter = @[parameter1, parameter2,parameter3,parameter4,parameter5,parameter6,parameter7,parameter8,parameter9,parameter10,parameter11,parameter12,parameter13,parameter14];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    self.savebutton.enabled = NO;
    [webService getWebServiceResult:@"UpdateDeviceSetResult"];
    //}
}

- (void)WebServiceGetCompleted:(id)theWebService
{
    self.savebutton.enabled = YES;
    
    if ([[theWebService soapResults] length] > 0) {
        
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        // 解析成json数据
        id object = [parser objectWithString:[theWebService soapResults] error:&error];
        self.savebutton.enabled = YES;
        
        if (!error && object) {
            // 获得状态
            int code = [[object objectForKey:@"Code"] intValue];
            if(code == 1)
            {
                [defaults setObject:@"0" forKey:@"pop"];
                [manager updataSQL:@"device_set" andType:@"ClassDisabled1" andValue:self.morningStarButton.titleLabel.text andBindle:[defaults objectForKey:@"binnumber"]];
                [manager updataSQL:@"device_set" andType:@"ClassDisabled2" andValue:self.morningEndButton.titleLabel.text andBindle:[defaults objectForKey:@"binnumber"]];
                [manager updataSQL:@"device_set" andType:@"ClassDisabled3" andValue:self.afternoonStarButton.titleLabel.text andBindle:[defaults objectForKey:@"binnumber"]];
                [manager updataSQL:@"device_set" andType:@"ClassDisabled4" andValue:self.afternoonEndButton.titleLabel.text andBindle:[defaults objectForKey:@"binnumber"]];
                [manager updataSQL:@"device_set" andType:@"WeekDisabled" andValue:str andBindle:[defaults objectForKey:@"binnumber"]];
                
                [OMGToast showWithText:NSLocalizedString(@"edit_suc", nil) bottomOffset:50 duration:1];
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                [OMGToast showWithText:NSLocalizedString(@"edit_fail", nil) bottomOffset:50 duration:1];
            }
        }
    }
}

- (void)WebServiceGetError:(id)theWebService error:(NSString *)theError{
    self.savebutton.enabled = YES;
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


- (IBAction)schoolMap:(id)sender {
    
    ScoolMapViewController *vc = [[ScoolMapViewController alloc] init];
    vc.title = NSLocalizedString(@"set_school_location", nil);
    [defaults setObject:@"0" forKey:@"schoolMapType"];
    [self.navigationController pushViewController:vc animated:YES];
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
