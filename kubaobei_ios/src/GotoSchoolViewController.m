//
//  GotoSchoolViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//
/**
 ******     下面注释的地方是对图标的修改
 修改的是星期背景图标        ******
 */
#import "GotoSchoolViewController.h"
#import "DataManager.h"
#import "DeviceSetModel.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "OMGToast.h"
#import "DeviceModel.h"
#import "LoginViewController.h"

@interface GotoSchoolViewController ()<UIPickerViewDataSource,UIPickerViewDelegate,WebServiceProtocol>
{
    BOOL isSelect;
    NSUserDefaults *defaults;
    
    NSMutableArray *hourArray;
    NSMutableArray *minArray;
    NSMutableArray *array;
    NSMutableArray *deviceArray;
    DeviceSetModel *model;
    DeviceModel *deviceModel;
    DataManager *manager ;
    
    BOOL mon;
    BOOL tue;
    BOOL thr;
    BOOL thur;
    BOOL fri;
    BOOL sat;
    BOOL sun;
    NSString *str;
}
@end

@implementation GotoSchoolViewController

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
    
    [self.monBtn setTitle:NSLocalizedString(@"monday", nil) forState:UIControlStateNormal];
    [self.tueBtn setTitle:NSLocalizedString(@"thesday", nil) forState:UIControlStateNormal];
    [self.thrBtn setTitle:NSLocalizedString(@"wednesday", nil) forState:UIControlStateNormal];
    [self.thurBtn setTitle:NSLocalizedString(@"thursday", nil) forState:UIControlStateNormal];
    [self.friBtn setTitle:NSLocalizedString(@"friday", nil) forState:UIControlStateNormal];
    [self.satBtn setTitle:NSLocalizedString(@"saturday", nil) forState:UIControlStateNormal];
    [self.sunBtn setTitle:NSLocalizedString(@"sunday", nil) forState:UIControlStateNormal];
    
    mon = NO;
    tue = NO;
    thr = NO;
    thur = NO;
    fri = NO;
    sat = NO;
    sun = NO;
    
    [self.monBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.tueBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.thrBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.thurBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.friBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.satBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.sunBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [self.monBtn setBackgroundImage:nil forState:UIControlStateNormal];
    [self.tueBtn setBackgroundImage:nil forState:UIControlStateNormal];
    [self.thrBtn setBackgroundImage:nil forState:UIControlStateNormal];
    [self.thurBtn setBackgroundImage:nil forState:UIControlStateNormal];
    [self.friBtn setBackgroundImage:nil forState:UIControlStateNormal];
    [self.satBtn setBackgroundImage:nil forState:UIControlStateNormal];
    [self.sunBtn setBackgroundImage:nil forState:UIControlStateNormal];
    
    
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
    
    self.timeLabel.text = NSLocalizedString(@"schooltime", nil);
    self.weekLabel.text = NSLocalizedString(@"week", nil);
    self.morningLabel.text = NSLocalizedString(@"morning", nil);
    self.afternoonLabel.text = NSLocalizedString(@"afternoon", nil);
    [self.cancelBtn setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [self.confirmBtn setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
    [self.saveBtn setTitle:NSLocalizedString(@"save", nil) forState:UIControlStateNormal];
    
}

- (void)setviewinfo
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    defaults = [NSUserDefaults standardUserDefaults];
    manager = [DataManager shareInstance];
    
    array =   [manager isSelectDeviceSetTable:[defaults objectForKey:@"binnumber"]];
    
    model = [array objectAtIndex:0];
    
    deviceArray = [manager isSelect:[defaults objectForKey:@"binnumber"]];
    
    deviceModel = [deviceArray objectAtIndex:0];
    
    
    [self.morningStarBtn setTitle:model.ClassDisabled1 forState:UIControlStateNormal];
    [self.morningEndBtn setTitle:model.ClassDisabled2 forState:UIControlStateNormal];
    [self.afternoonStarBtn setTitle:model.ClassDisabled3 forState:UIControlStateNormal];
    [self.afternoonEndBtn setTitle:model.ClassDisabled4 forState:UIControlStateNormal];
    
    if(model.WeekDisabled.length != 0)
    {
        for(int i = 0; i < model.WeekDisabled.length;i++)
        {
            str = [model.WeekDisabled substringWithRange:NSMakeRange(i, 1)];
            if(str.intValue == 1)
            {
                [self.monBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                //                [self.monBtn setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
                self.monBtn.backgroundColor = MCN_buttonColor;
                mon = YES;
            }
            else if(str.intValue == 2)
            {
                [self.tueBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                //                [self.tueBtn setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
                self.tueBtn.backgroundColor = MCN_buttonColor;
                tue = YES;
            }
            else if(str.intValue == 3)
            {
                [self.thrBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                //                [self.thrBtn setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
                self.thrBtn.backgroundColor = MCN_buttonColor;
                thr = YES;
            }
            else if(str.intValue == 4)
            {
                [self.thurBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                //                [self.thurBtn setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
                self.thurBtn.backgroundColor = MCN_buttonColor;
                thur = YES;
            }
            else if(str.intValue == 5)
            {
                [self.friBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                //                [self.friBtn setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
                self.friBtn.backgroundColor = MCN_buttonColor;
                fri = YES;
            }
            else if(str.intValue == 6)
            {
                [self.satBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                //                [self.satBtn setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
                self.satBtn.backgroundColor = MCN_buttonColor;
                sat = YES;
            }
            else if(str.intValue == 7)
            {
                [self.sunBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                //                [self.sunBtn setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
                self.sunBtn.backgroundColor = MCN_buttonColor;
                sun = YES;
            }
            
        }
    }
    
    if(model.ClassDisabled1.length == 0)
    {
        [self.morningStarBtn setTitle:@"00:00" forState:UIControlStateNormal];
    }
    else
    {
        [self.morningStarBtn setTitle:model.ClassDisabled1 forState:UIControlStateNormal];
    }
    
    if(model.ClassDisabled2.length == 0)
    {
        [self.morningEndBtn setTitle:@"00:00" forState:UIControlStateNormal];
    }
    else
    {
        [self.morningEndBtn setTitle:model.ClassDisabled2 forState:UIControlStateNormal];
        
    }
    
    if(model.ClassDisabled3.length == 0)
    {
        [self.afternoonStarBtn setTitle:@"00:00" forState:UIControlStateNormal];
    }
    else
    {
        [self.afternoonStarBtn setTitle:model.ClassDisabled3 forState:UIControlStateNormal];
    }
    
    if(model.ClassDisabled4.length == 0)
    {
        [self.afternoonEndBtn setTitle:@"00:00" forState:UIControlStateNormal];
    }
    else
    {
        [self.afternoonEndBtn setTitle:model.ClassDisabled4 forState:UIControlStateNormal];
        
    }
    
}

- (IBAction)timeSelectBtn:(id)sender {
    UIButton *btn = sender;
    self.bgView.hidden = NO;
    
    if(btn.tag == 1)
    {
        self.pickView.tag = 1;
        [self.pickView selectRow:[[[model.ClassDisabled1 componentsSeparatedByString:@":"] objectAtIndex:0] intValue] inComponent:0 animated:NO];
        [self.pickView selectRow:[[[model.ClassDisabled1 componentsSeparatedByString:@":"] objectAtIndex:1] intValue] inComponent:1 animated:NO];
    }
    else if(btn.tag == 2)
    {
        self.pickView.tag = 2;
        [self.pickView selectRow:[[[model.ClassDisabled2 componentsSeparatedByString:@":"] objectAtIndex:0] intValue] inComponent:0 animated:NO];
        [self.pickView selectRow:[[[model.ClassDisabled2 componentsSeparatedByString:@":"] objectAtIndex:1] intValue] inComponent:1 animated:NO];
    }
    else if(btn.tag == 3)
    {
        self.pickView.tag =3;
        [self.pickView selectRow:[[[model.ClassDisabled3 componentsSeparatedByString:@":"] objectAtIndex:0] intValue] inComponent:0 animated:NO];
        [self.pickView selectRow:[[[model.ClassDisabled3 componentsSeparatedByString:@":"] objectAtIndex:1] intValue] inComponent:1 animated:NO];
    }
    else if(btn.tag == 4)
    {
        self.pickView.tag = 4;
        [self.pickView selectRow:[[[model.ClassDisabled4 componentsSeparatedByString:@":"] objectAtIndex:0] intValue] inComponent:0 animated:NO];
        [self.pickView selectRow:[[[model.ClassDisabled4 componentsSeparatedByString:@":"] objectAtIndex:1] intValue] inComponent:1 animated:NO];
    }
    
}

- (IBAction)daySelectBtn:(id)sender {
    
    UIButton *btn = sender;
    if(btn.tag == 101)
    {
        if(mon ==  YES)
        {
            [self.monBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            //            [self.monBtn setBackgroundImage:nil forState:UIControlStateNormal];
            self.monBtn.backgroundColor = [UIColor clearColor];
            mon = NO;
        }
        else
        {
            [self.monBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            //            [self.monBtn setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
            self.monBtn.backgroundColor = MCN_buttonColor;
            mon = YES;
            
        }
    }
    else if(btn.tag == 102)
    {
        if(tue ==  YES)
        {
            [self.tueBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            //            [self.tueBtn setBackgroundImage:nil forState:UIControlStateNormal];
            self.tueBtn.backgroundColor = [UIColor clearColor];
            tue = NO;
        }
        else
        {
            [self.tueBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            //            [self.tueBtn setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
            self.tueBtn.backgroundColor = MCN_buttonColor;
            tue = YES;
            
        }
    }
    else if(btn.tag == 103)
    {
        if(thr ==  YES)
        {
            [self.thrBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            //            [self.thrBtn setBackgroundImage:nil forState:UIControlStateNormal];
            self.thrBtn.backgroundColor = [UIColor clearColor];
            thr = NO;
        }
        else
        {
            [self.thrBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            //            [self.thrBtn setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
            self.thrBtn.backgroundColor = MCN_buttonColor;
            thr = YES;
            
        }
    }
    else if(btn.tag == 104)
    {
        if(thur ==  YES)
        {
            [self.thurBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            //            [self.thurBtn setBackgroundImage:nil forState:UIControlStateNormal];
            self.thurBtn.backgroundColor = [UIColor clearColor];
            thur = NO;
        }
        else
        {
            [self.thurBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            //            [self.thurBtn setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
            self.thurBtn.backgroundColor = MCN_buttonColor;
            thur = YES;
            
        }
    }
    else if(btn.tag == 105)
    {
        if(fri ==  YES)
        {
            [self.friBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            //            [self.friBtn setBackgroundImage:nil forState:UIControlStateNormal];
            self.friBtn.backgroundColor = [UIColor clearColor];
            fri = NO;
        }
        else
        {
            [self.friBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            //            [self.friBtn setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
            self.friBtn.backgroundColor = MCN_buttonColor;
            fri = YES;
            
        }
    }
    else if(btn.tag == 106)
    {
        if(sat ==  YES)
        {
            [self.satBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            //            [self.satBtn setBackgroundImage:nil forState:UIControlStateNormal];
            self.satBtn.backgroundColor = [UIColor clearColor];
            sat = NO;
        }
        else
        {
            [self.satBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            //            [self.satBtn setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
            self.satBtn.backgroundColor = MCN_buttonColor;
            sat = YES;
            
        }
    }
    else if(btn.tag == 107)
    {
        if(sun ==  YES)
        {
            [self.sunBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            //            [self.sunBtn setBackgroundImage:nil forState:UIControlStateNormal];
            self.sunBtn.backgroundColor = [UIColor clearColor];
            sun = NO;
        }
        else
        {
            [self.sunBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            //            [self.sunBtn setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
            self.sunBtn.backgroundColor = MCN_buttonColor;
            sun = YES;
        }
    }
}

- (IBAction)saveBtn:(id)sender {
    NSString *str1 =[NSString stringWithFormat:@"%@%@",[[self.morningStarBtn.titleLabel.text componentsSeparatedByString:@":"] objectAtIndex:0],[[self.morningStarBtn.titleLabel.text componentsSeparatedByString:@":"] objectAtIndex:1]];
    NSString *str2 =[NSString stringWithFormat:@"%@%@",[[self.morningEndBtn.titleLabel.text  componentsSeparatedByString:@":"] objectAtIndex:0],[[self.morningEndBtn.titleLabel.text componentsSeparatedByString:@":"] objectAtIndex:1]];
    NSString *str3 =[NSString stringWithFormat:@"%@%@",[[self.afternoonStarBtn.titleLabel.text componentsSeparatedByString:@":"] objectAtIndex:0],[[self.afternoonStarBtn.titleLabel.text componentsSeparatedByString:@":"] objectAtIndex:1]];
    NSString *str4 =[NSString stringWithFormat:@"%@%@",[[self.afternoonEndBtn.titleLabel.text componentsSeparatedByString:@":"] objectAtIndex:0],[[self.afternoonEndBtn.titleLabel.text componentsSeparatedByString:@":"] objectAtIndex:1]];
    
    //    if (deviceModel.LatestTime == nil || [deviceModel.LatestTime isEqualToString:@""]) {
    //        deviceModel.LatestTime = @"24:00";
    //    }
    //    deviceModel.LatestTime = @"";
//    if (![deviceModel.LatestTime isEqualToString:@""])
//    {
//        NSString *str5 =[NSString stringWithFormat:@"%@%@",[[deviceModel.LatestTime componentsSeparatedByString:@":"] objectAtIndex:0],[[deviceModel.LatestTime componentsSeparatedByString:@":"] objectAtIndex:1]];
//        if(str4.intValue > str5.intValue)
//        {
//            [OMGToast showWithText:NSLocalizedString(@"select_right_time", nil) bottomOffset:50 duration:3];
//            return;
//        }
//        if(str1.intValue > str5.intValue)
//        {
//            [OMGToast showWithText:NSLocalizedString(@"select_right_time", nil) bottomOffset:50 duration:3];
//            return;
//        }  if(str2.intValue > str5.intValue)
//        {
//            [OMGToast showWithText:NSLocalizedString(@"select_right_time", nil) bottomOffset:50 duration:3];
//            return;
//        }  if(str3.intValue > str5.intValue)
//        {
//            [OMGToast showWithText:NSLocalizedString(@"select_right_time", nil) bottomOffset:50 duration:3];
//            return;
//        }
//    }
    
    /**
    if(str2.intValue > 1200)
    {
        [OMGToast showWithText:NSLocalizedString(@"select_morning_time", nil) bottomOffset:50 duration:3];
        return;
    }
    if(str3.intValue < 1200)
    {
        [OMGToast showWithText:NSLocalizedString(@"select_afternoon_time", nil) bottomOffset:50 duration:3];
        return;
    }
    **/
    
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
    if(str2.intValue > str3.intValue)
    {
        [OMGToast showWithText:NSLocalizedString(@"select_right_time", nil) bottomOffset:50 duration:3];
        return;
    }
    
    
    
    str = [NSString stringWithFormat:@"%@%@%@%@%@%@%@",mon == YES?@"1":@"",tue == YES?@"2":@"",thr == YES?@"3":@"",thur == YES?@"4":@"",fri == YES?@"5":@"",sat == YES?@"6":@"",sun == YES?@"7":@""];
    array =   [manager isSelectDeviceSetTable:[defaults objectForKey:@"binnumber"]];
    
    model = [array objectAtIndex:0];
    
    deviceArray = [manager isSelect:[defaults objectForKey:@"binnumber"]];
    
    deviceModel = [deviceArray objectAtIndex:0];
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
    WebServiceParameter *parameter11 = [WebServiceParameter newWithKey:@"classDisable1" andValue:[NSString stringWithFormat:@"%@-%@",self.morningStarBtn.titleLabel.text,self.morningEndBtn.titleLabel.text]];
    WebServiceParameter *parameter12 = [WebServiceParameter newWithKey:@"classDisable2" andValue:[NSString stringWithFormat:@"%@-%@",self.afternoonStarBtn.titleLabel.text,self.afternoonEndBtn.titleLabel.text]];
    WebServiceParameter *parameter13 = [WebServiceParameter newWithKey:@"weekDisable" andValue:str];
    WebServiceParameter *parameter14 = [WebServiceParameter newWithKey:@"latestTime" andValue:deviceModel.LatestTime];
    
    NSArray *parameter = @[parameter1, parameter2,parameter3,parameter4,parameter5,parameter6,parameter7,parameter8,parameter9,parameter10,parameter11,parameter12,parameter13,parameter14];
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
            if(code == 1)
            {
                [manager updataSQL:@"device_set" andType:@"ClassDisabled1" andValue:self.morningStarBtn.titleLabel.text andBindle:[defaults objectForKey:@"binnumber"]];
                [manager updataSQL:@"device_set" andType:@"ClassDisabled2" andValue:self.morningEndBtn.titleLabel.text andBindle:[defaults objectForKey:@"binnumber"]];
                [manager updataSQL:@"device_set" andType:@"ClassDisabled3" andValue:self.afternoonStarBtn.titleLabel.text andBindle:[defaults objectForKey:@"binnumber"]];
                [manager updataSQL:@"device_set" andType:@"ClassDisabled4" andValue:self.afternoonEndBtn.titleLabel.text andBindle:[defaults objectForKey:@"binnumber"]];
                [manager updataSQL:@"device_set" andType:@"WeekDisabled" andValue:str andBindle:[defaults objectForKey:@"binnumber"]];
                
                
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
    
}

- (IBAction)confirmBtn:(id)sender {
    
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

