//
//  WatchPhoneViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "WatchPhoneViewController.h"
#import "DataManager.h"
#import "DeviceModel.h"
#import "ShortMessageModel.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "WatchPhoneSendTableViewCell.h"
#import "WatchPhoneTableViewCell.h"
#import "OMGToast.h"
#import "EditPhoneViewController.h"
#import "UIImageView+WebCache.h"
#import "GMDCircleLoader.h"
#import "LoginViewController.h"


@interface WatchPhoneViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSUserDefaults *defaults;
    NSMutableArray *deviceArray;
    NSMutableArray *shortMessage;
    DataManager *manager;
    DeviceModel *deviceModel;
    ShortMessageModel *shortMessageModel;
    int pageindex;
    BOOL isLoad;
    int pageTotal;
    int pageSize;
    BOOL isShow;
    UIButton* rightBtn;

}
@end

@implementation WatchPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    pageindex = 1;
    self.chaliuliang.frame = CGRectMake(0, self.tableView.frame.size.height+64, self.view.frame.size.width/2+1, self.view.frame.size.height-self.tableView.frame.size.height-64);
    self.chahuafei.frame = CGRectMake(self.view.frame.size.width/2+1, self.tableView.frame.size.height+64, self.view.frame.size.width/2-1, self.view.frame.size.height-self.tableView.frame.size.height-64);
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"1" forKey:@"showRight"];
    [defaults setObject:@"0" forKey:@"showLeft"];
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];
    
    isShow = NO;
    rightBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [rightBtn setTitle:NSLocalizedString(@"edit", nil) forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    rightBtn.frame = CGRectMake(0, 0, 50, 30);
    UIBarButtonItem* rightBtnItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    
    [rightBtn addTarget:self action:@selector(showNext) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setRightBarButtonItem:rightBtnItem];

    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //self.tableView.rowHeight = 121;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.chahuafei_Label.text = NSLocalizedString(@"check_fare", nil);
    self.chaliuliang_Label.text = NSLocalizedString(@"check_flow", nil);
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSMS:) name:@"refreshSMS" object:nil];

}

- (void)refreshSMS:(NSNotification *)n
{
    [self getLoad];
}

- (IBAction)checkLiuLiang:(id)sender {
    UIButton *btn = sender;
    if( [deviceModel.SmsFlowKey length] == 0 || [deviceModel.SmsBalanceKey length] == 0 || deviceModel.SmsNumber.length == 0 )
    {
        [OMGToast showWithText:NSLocalizedString(@"set_the_related_information", nil) bottomOffset:50 duration:1];
        EditPhoneViewController *vc = [[EditPhoneViewController alloc] init];
        vc.title = NSLocalizedString(@"watch_fare", nil);
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        WebService *webService = [WebService newWithWebServiceAction:@"SaveDeviceSMS" andDelegate:self];
        webService.tag = 0;
        WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
        WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"deviceId" andValue:deviceModel.DeviceID];
        WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"phone" andValue:deviceModel.SmsNumber];
        WebServiceParameter *parameter4 = @"";

        if(btn.tag == 0)
        {
            parameter4 = [WebServiceParameter newWithKey:@"content" andValue:deviceModel.SmsFlowKey];
            [defaults setObject:@"0" forKey:@"t"];
        }
        else
        {
           parameter4 = [WebServiceParameter newWithKey:@"content" andValue:deviceModel.SmsBalanceKey];
            [defaults setObject:@"1" forKey:@"t"];

            
        }
        NSArray *parameter = @[loginParameter1,parameter2,loginParameter3,parameter4];
        // webservice请求并获得结果
        webService.webServiceParameter = parameter;
        [GMDCircleLoader setOnView:self.view withTitle:NSLocalizedString(@"wait", nil) animated:YES];

        [webService getWebServiceResult:@"SaveDeviceSMSResult"];
    }
    
  //  [self.tableView reloadData];

}

- (void)showNext
{
    if(isShow == NO)
    {
        self.tableView.editing = YES;
        [rightBtn setTitle:NSLocalizedString(@"finish", nil) forState:UIControlStateNormal];
        isShow = YES;
    }
    else
    {
        self.tableView.editing= NO;
        [rightBtn setTitle:NSLocalizedString(@"edit", nil) forState:UIControlStateNormal];
        
        isShow = NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    shortMessageModel = [shortMessage objectAtIndex:indexPath.row];
    
    if(shortMessageModel.Type.intValue == 2)
    {
          [manager deleteShortMessageWithDeviceSMSID:shortMessageModel.DeviceSMSID];
    }
    else if(shortMessageModel.Type.intValue == 1)
    {
        [manager deleteShortMessageWithCreateTime:shortMessageModel.CreateTime];
    }
    
    shortMessage = [manager isSelectShortMessageWithDeviceID:deviceModel.DeviceID];
    
    [self.tableView reloadData];
}

- (void)setviewinfo
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:NO];
    manager = [DataManager shareInstance];
    
    deviceArray  = [[NSMutableArray alloc] init];
    deviceArray = [manager isSelect:[defaults objectForKey:@"binnumber"]];
    deviceModel = [deviceArray  objectAtIndex:0];
    
    shortMessage = [[NSMutableArray alloc] init];
    shortMessage = [manager isSelectShortMessageWithDeviceID:deviceModel.DeviceID];
    
//    for(int i = 0;i < shortMessage.count;i++)
//    {
//        shortMessageModel = [shortMessage objectAtIndex:i];
//        NSLog(@"%@",shortMessageModel.CreateTime);
//        
//    }
    [self getLoad];
}

- (void)getLoad
{
    WebService *webService = [WebService newWithWebServiceAction:@"GetDeviceSMS" andDelegate:self];
    webService.tag = 1000;
    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
    WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"deviceId" andValue:deviceModel.DeviceID];
    
    NSArray *parameter = @[loginParameter1,parameter2];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"GetDeviceSMSResult"];
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
            if(code == 1)
            {
                if(ws.tag == 0)
                {
                    NSDateFormatter *farmatter = [[NSDateFormatter alloc] init];
                    [farmatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
                    NSString *str = [farmatter stringFromDate:[NSDate date]];
                    
                  if([[defaults objectForKey:@"t"] intValue] == 0)
                  {
                      [manager addShortMessageDeviceID:deviceModel.DeviceID andDeviceSMSID:nil anddeviceID:deviceModel.DeviceID andType:@"1" andPhone:deviceModel.PhoneNumber andSMS:NSLocalizedString(@"traffic", nil)    andCreateTime:str];
                  }
                else
                {
                        [manager addShortMessageDeviceID:deviceModel.DeviceID andDeviceSMSID:nil anddeviceID:deviceModel.DeviceID andType:@"1" andPhone:deviceModel.PhoneNumber andSMS:NSLocalizedString(@"the_phone", nil)    andCreateTime:str];
                }
                    
            }
                
               else if(ws.tag == 1000)
                {
                    NSArray *array = [[NSArray alloc] init];
                    array = [object objectForKey:@"SMSList"];
                    
                    for(int i = 0;i < array.count;i++)
                    {
                        [manager addShortMessageDeviceID:deviceModel.DeviceID andDeviceSMSID:[[array objectAtIndex:i] objectForKey:@"DeviceSMSID"]anddeviceID:[[array objectAtIndex:i] objectForKey:@"DeviceID"] andType:[[array objectAtIndex:i] objectForKey:@"Type"] andPhone:[[array objectAtIndex:i] objectForKey:@"Phone"] andSMS:[[array objectAtIndex:i] objectForKey:@"SMS"] andCreateTime:[[array objectAtIndex:i] objectForKey:@"CreateTime"]];
                    }
                }
                
            }
            else if(code == 0)
            {
                [OMGToast showWithText:NSLocalizedString(@"abnormal_login", nil) bottomOffset:50 duration:3];
                LoginViewController *vc = [[LoginViewController alloc] init];
                for (UIViewController *controller in self.navigationController.viewControllers) {
                    if ([controller isKindOfClass:[vc class]]) {
                        [self.navigationController popToViewController:controller animated:YES];
                    }
                }

            }
            
            if(shortMessage.count != 0)
            {
                [shortMessage removeAllObjects];
            }
            NSMutableArray *shortME = [manager isSelectShortMessageWithDeviceID:deviceModel.DeviceID];
            for(int i =0;i < shortME.count;i++)
            {
                [shortMessage addObject:[shortME objectAtIndex:i]];
            }
            [self.tableView reloadData];
            [GMDCircleLoader hideFromView:self.view animated:YES];

            if(pageindex==1)
            {
                NSUInteger sectionCount = [self.tableView numberOfSections];
                if (sectionCount) {
                    
                    NSUInteger rowCount = [self.tableView numberOfRowsInSection:0];
                    if (rowCount) {
                        
                        NSUInteger ii[2] = {0, rowCount - 1};
                        NSIndexPath* indexPath = [NSIndexPath indexPathWithIndexes:ii length:2];
                        [self.tableView scrollToRowAtIndexPath:indexPath
                                              atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                        
                    }
                }
            }else {
                NSUInteger ii[2] = {0, pageSize-1};
                NSIndexPath* indexPath = [NSIndexPath indexPathWithIndexes:ii length:2];
                [self.tableView scrollToRowAtIndexPath:indexPath
                                      atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            }
            isLoad=YES;
            
            
        }

    }
        
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return shortMessage.count;
}

- (IBAction)editList:(id)sender {
    
    EditPhoneViewController *vc = [[EditPhoneViewController alloc] init];
    vc.title = NSLocalizedString(@"watch_fare", nil);
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (shortMessage.count > 0&&isLoad) {
        if (indexPath.row == 0&&pageindex<pageTotal) {
            pageindex++;
            [self getLoad];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    shortMessageModel = [shortMessage objectAtIndex:indexPath.row];

    if (shortMessageModel.Type.intValue == 2) {
        static NSString *cellID = @"short1";
        UINib *nib = [UINib nibWithNibName:@"WatchPhoneTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:cellID];
        WatchPhoneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[WatchPhoneTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        }
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];

        
        cell.timeLabel.text = shortMessageModel.CreateTime;
        cell.listLabel.text = shortMessageModel.SMS;

       // [cell heightForString:cell.listLabel.text fontSize:14 andWidth:290];
        //[cell setIntroductionText:shortMessageModel.SMS];
        CGRect size = cell.frame;
        size.size.height = [cell heightForString:cell.listLabel.text fontSize:14 andWidth:[UIScreen mainScreen].bounds.size.width - 54 - 75] + 85;
        cell.nameLabel.text = deviceModel.BabyName;
        if(deviceModel.Photo.length == 0)
        {
            cell.headView.image = [UIImage imageNamed:@"user_head_normal"];
        }
        else
        {
            [cell.headView setImageWithURL:[NSURL URLWithString:deviceModel.Photo]];

        }
        
        cell.frame = size;
        
        return cell;
    }
    else
    {
        static NSString *cellID = @"short";
        UINib *nib = [UINib nibWithNibName:@"WatchPhoneSendTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:cellID];
        WatchPhoneSendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[WatchPhoneSendTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        }
        
        cell.timeLabel.text = shortMessageModel.CreateTime;
        
        if([deviceModel.DeviceType isEqualToString:@"2"])
        {
            cell.listLabel.text = [NSString stringWithFormat:@"%@%@%@%@%@",NSLocalizedString(@"query_the_watch_d8", nil),deviceModel.PhoneNumber,NSLocalizedString(@"the", nil),shortMessageModel.SMS,NSLocalizedString(@"please_wait_a_moment_d8", nil)];
        }
        else{
            cell.listLabel.text = [NSString stringWithFormat:@"%@%@%@%@%@",NSLocalizedString(@"query_the_watch", nil),deviceModel.PhoneNumber,NSLocalizedString(@"the", nil),shortMessageModel.SMS,NSLocalizedString(@"please_wait_a_moment", nil)];
        }
        return cell;
     
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    shortMessageModel = [shortMessage objectAtIndex:indexPath.row];
    
     if ([shortMessageModel.Type isEqualToString:@"2"]) {
//
    WatchPhoneTableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    
         return cell.frame.size.height;
         
     }
    else
    {
        return 121;
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
