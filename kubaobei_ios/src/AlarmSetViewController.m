//
//  AlarmSetViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/10.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "AlarmSetViewController.h"
#import "DataManager.h"
#import "DeviceSetModel.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "OMGToast.h"
#import "DeviceModel.h"
#import "LoginViewController.h"

extern int alarm_pick;
extern int button_pick1;
extern int button_pick2;
extern int button_pick3;
NSString *str_week1;
NSString *str_week2;
NSString *str_week3;
NSString *str_alarm1;
NSString *str_alarm2;
NSString *str_alarm3;
NSString *str_weekalarm1;
NSString *str_weekalarm2;
NSString *str_weekalarm3;
extern NSString *model_alarm1;
extern NSString *model_alarm2;
extern NSString *model_alarm3;

@interface AlarmSetViewController ()<UIPickerViewDataSource,UIPickerViewDelegate,WebServiceProtocol>
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
    
    NSString *str_week;
}
@end

@implementation AlarmSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isSelect = NO;
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
    //self.bgView.hidden = YES;
    
    self.weekLabel.text = NSLocalizedString(@"week", nil);
    [self.cancelBtn setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [self.confirmBtn setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
    [self.saveBtn setTitle:NSLocalizedString(@"save", nil) forState:UIControlStateNormal];
  
    button_pick1=0;
    button_pick2=0;
    button_pick3=0;
    
    defaults = [NSUserDefaults standardUserDefaults];
    manager = [DataManager shareInstance];
    
    array =   [manager isSelectDeviceSetTable:[defaults objectForKey:@"binnumber"]];
    
    model = [array objectAtIndex:0];
    
    deviceArray = [manager isSelect:[defaults objectForKey:@"binnumber"]];
    
    deviceModel = [deviceArray objectAtIndex:0];
    
//    [defaults setObject:model.alarm1 forKey:@"Alarm1"];
//    [defaults setObject:model.alarm2 forKey:@"Alarm2"];
//    [defaults setObject:model.alarm3 forKey:@"Alarm3"];
//    [defaults setObject:model.weekAlarm1 forKey:@"WeekAlarm1"];
//    [defaults setObject:model.weekAlarm2 forKey:@"WeekAlarm2"];
//    [defaults setObject:model.weekAlarm3 forKey:@"WeekAlarm3"];
    
    str_alarm1=model.alarm1;
    str_alarm2=model.alarm2;
    str_alarm3=model.alarm3;
    
    if([str_alarm1 rangeOfString:@"null"].location !=NSNotFound)
    {
        str_alarm1=@"00:00";
    }
    if([str_alarm2 rangeOfString:@"null"].location !=NSNotFound)
    {
        str_alarm2=@"00:00";
    }
    if([str_alarm3 rangeOfString:@"null"].location !=NSNotFound)
    {
        str_alarm3=@"00:00";
    }
    
    if(alarm_pick== 1)
    {
        if(str_alarm1.length!=0)
        {
            [self.pickView selectRow:[[[str_alarm1 componentsSeparatedByString:@":"] objectAtIndex:0] intValue] inComponent:0 animated:NO];
            [self.pickView selectRow:[[[str_alarm1 componentsSeparatedByString:@":"] objectAtIndex:1] intValue] inComponent:1 animated:NO];
        }
    }
    else if(alarm_pick== 2)
    {
        if(str_alarm2.length!=0)
        {
            [self.pickView selectRow:[[[str_alarm2 componentsSeparatedByString:@":"] objectAtIndex:0] intValue] inComponent:0 animated:NO];
            [self.pickView selectRow:[[[str_alarm2 componentsSeparatedByString:@":"] objectAtIndex:1] intValue] inComponent:1 animated:NO];
        }
    }
    else
    {
        if(str_alarm3.length!=0)
        {
            [self.pickView selectRow:[[[str_alarm3 componentsSeparatedByString:@":"] objectAtIndex:0] intValue] inComponent:0 animated:NO];
            [self.pickView selectRow:[[[str_alarm3 componentsSeparatedByString:@":"] objectAtIndex:1] intValue] inComponent:1 animated:NO];
        }
    }
    
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
   
//    if(alarm_pick== 1)
//    {
        if(_watchModel.week.length != 0)
        {
            for(int i = 0; i < _watchModel.week.length;i++)
            {
                str_week = [_watchModel.week substringWithRange:NSMakeRange(i, 1)];
                if(str_week.intValue == 1)
                {
                    [self.monBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//                    [self.monBtn setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
                    self.monBtn.backgroundColor = MCN_buttonColor;
                    mon = YES;
                }
                else if(str_week.intValue == 2)
                {
                    [self.tueBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//                    [self.tueBtn setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
                    self.tueBtn.backgroundColor = MCN_buttonColor;
                    tue = YES;
                }
                else if(str_week.intValue == 3)
                {
                    [self.thrBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//                    [self.thrBtn setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
                    self.thrBtn.backgroundColor= MCN_buttonColor;
                    thr = YES;
                }
                else if(str_week.intValue == 4)
                {
                    [self.thurBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//                    [self.thurBtn setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
                    self.thurBtn.backgroundColor = MCN_buttonColor;
                    thur = YES;
                }
                else if(str_week.intValue == 5)
                {
                    [self.friBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//                    [self.friBtn setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
                    self.friBtn.backgroundColor = MCN_buttonColor;
                    fri = YES;
                }
                else if(str_week.intValue == 6)
                {
                    [self.satBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//                    [self.satBtn setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
                    self.satBtn.backgroundColor = MCN_buttonColor;
                    sat = YES;
                }
                else if(str_week.intValue == 7)
                {
                    [self.sunBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//                    [self.sunBtn setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
                    self.sunBtn.backgroundColor = MCN_buttonColor;
                    sun = YES;
                }
            }
        }
        
    
//    else if(alarm_pick== 2)
//    {
//        if(str_weekalarm2.length != 0)
//        {
//            for(int i = 0; i < str_weekalarm2.length;i++)
//            {
//                str_week = [str_weekalarm2 substringWithRange:NSMakeRange(i, 1)];
//                if(str_week.intValue == 1)
//                {
//                    [self.monBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
////                    [self.monBtn setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
//                    self.monBtn.backgroundColor = MCN_buttonColor;
//                    mon = YES;
//                }
//                else if(str_week.intValue == 2)
//                {
//                    [self.tueBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
////                    [self.tueBtn setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
//                    self.tueBtn.backgroundColor = MCN_buttonColor;
//                    tue = YES;
//                }
//                else if(str_week.intValue == 3)
//                {
//                    [self.thrBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
////                    [self.thrBtn setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
//                    self.thrBtn.backgroundColor = MCN_buttonColor;
//                    thr = YES;
//                }
//                else if(str_week.intValue == 4)
//                {
//                    [self.thurBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
////                    [self.thurBtn setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
//                    self.thurBtn.backgroundColor = MCN_buttonColor;
//                    thur = YES;
//                }
//                else if(str_week.intValue == 5)
//                {
//                    [self.friBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
////                    [self.friBtn setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
//                    self.friBtn.backgroundColor = MCN_buttonColor;
//                    fri = YES;
//                }
//                else if(str_week.intValue == 6)
//                {
//                    [self.satBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
////                    [self.satBtn setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
//                    self.satBtn.backgroundColor = MCN_buttonColor;
//                    sat = YES;
//                }
//                else if(str_week.intValue == 7)
//                {
//                    [self.sunBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
////                    [self.sunBtn setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
//                    self.sunBtn.backgroundColor = MCN_buttonColor;
//                    sun = YES;
//                }
//            }
//        }
//    }
//    else
//    {
//        if(str_weekalarm3.length != 0)
//        {
//            for(int i = 0; i < str_weekalarm3.length;i++)
//            {
//                str_week = [str_weekalarm3 substringWithRange:NSMakeRange(i, 1)];
//                if(str_week.intValue == 1)
//                {
//                    [self.monBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
////                    [self.monBtn setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
//                    self.monBtn.backgroundColor = MCN_buttonColor;
//                    mon = YES;
//                }
//                else if(str_week.intValue == 2)
//                {
//                    [self.tueBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
////                    [self.tueBtn setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
//                    self.tueBtn.backgroundColor = MCN_buttonColor;
//                    tue = YES;
//                }
//                else if(str_week.intValue == 3)
//                {
//                    [self.thrBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
////                    [self.thrBtn setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
//                    self.thurBtn.backgroundColor = MCN_buttonColor;
//                    thr = YES;
//                }
//                else if(str_week.intValue == 4)
//                {
//                    [self.thurBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
////                    [self.thurBtn setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
//                    self.thurBtn.backgroundColor = MCN_buttonColor;
//                    thur = YES;
//                }
//                else if(str_week.intValue == 5)
//                {
//                    [self.friBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
////                    [self.friBtn setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
//                    self.friBtn.backgroundColor = MCN_buttonColor;
//                    fri = YES;
//                }
//                else if(str_week.intValue == 6)
//                {
//                    [self.satBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
////                    [self.satBtn setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
//                    self.satBtn.backgroundColor = MCN_buttonColor;
//                    sat = YES;
//                }
//                else if(str_week.intValue == 7)
//                {
//                    [self.sunBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
////                    [self.sunBtn setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
//                    self.sunBtn.backgroundColor = MCN_buttonColor;
//                    sun = YES;
//                }
//            }
//        }
//
//    }
    
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

- (IBAction)cancelBtn:(id)sender {
    button_pick1=0;
    button_pick2=0;
    button_pick3=0;
    [self.navigationController popViewControllerAnimated:YES];
    //self.bgView.hidden = YES;
}

- (IBAction)confirmBtn:(id)sender {
    
    NSString* alarm = [NSString stringWithFormat:@"%@:%@",[hourArray objectAtIndex:[self.pickView selectedRowInComponent:0]],[minArray objectAtIndex:[self.pickView selectedRowInComponent:1]]];
    NSString* week = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@",mon == YES?NSLocalizedString(@"Monday", nil):@"",tue == YES?NSLocalizedString(@"Weekday", nil):@"",thr == YES?NSLocalizedString(@"Tuesday", nil):@"",thur == YES?NSLocalizedString(@"Wednesday", nil):@"",fri == YES?NSLocalizedString(@"Thursday", nil):@"",sat == YES?NSLocalizedString(@"Friday", nil):@"",sun == YES?NSLocalizedString(@"Saturday", nil):@""];
    NSString* weekAlarm = [NSString stringWithFormat:@"%@%@%@%@%@%@%@",mon == YES?@"1":@"",tue == YES?@"2":@"",thr == YES?@"3":@"",thur == YES?@"4":@"",fri == YES?@"5":@"",sat == YES?@"6":@"",sun == YES?@"7":@""];
    _watchModel.week = weekAlarm;
    _watchModel.alarm = alarm;
    if(alarm_pick== 1)
    {
        button_pick1=1;
        str_alarm1 =alarm;
        str_week1 =week;
        str_weekalarm1=weekAlarm;
        
    }
    else if(alarm_pick== 2)
    {
        
        button_pick2=1;
        str_alarm2 = alarm;
        str_week2 = week;
        str_weekalarm2=weekAlarm;
    }
    else
    {
        button_pick3=1;
        str_alarm3 = alarm;
        str_week3 = week;
        str_weekalarm3= weekAlarm;
    }
    
 
    switch (alarm_pick) {
        case 1:
            model.alarm1=str_alarm1;
            [defaults setObject:model.alarm1 forKey:@"Alarm1"];
            break;
        case 2:
            model.alarm2=str_alarm2;
            [defaults setObject:model.alarm2 forKey:@"Alarm2"];
            break;
        case 3:
            model.alarm3=str_alarm3;
            [defaults setObject:model.alarm3 forKey:@"Alarm3"];
            break;
            
        default:
            break;
    }
    [self.navigationController popViewControllerAnimated:YES];
    //self.bgView.hidden = YES;
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
