//
//  AboutWatchViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "AboutWatchViewController.h"
#import "AboutWatchOneTableViewCell.h"
#import "AboutWatchTwoTableViewCell.h"
#import "DataManager.h"
#import "DeviceModel.h"
#import "WatchFirmwareViewController.h"
#import "QRCodeGenerator.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "OMGToast.h"
#import "SYQRCodeViewController.h"
#import "EditHeadAndNameViewController.h"
#import "STAlertView.h"
#import "DXAlertView.h"
#import "LoginViewController.h"
#import "Constants.h"
@interface AboutWatchViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    NSUserDefaults *defaults;
    NSArray *seciton1Array;
    NSArray *seciton2Array;
    
    NSMutableArray *array;
    DeviceModel *model;
    DataManager *manager;
    UIAlertView *alertView;
    BOOL isGPS;
}
@end

@implementation AboutWatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"0" forKey:@"showRight"];
    [defaults setObject:@"1" forKey:@"showLeft"];
    self.tableView.estimatedRowHeight = 150;//估算高度
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.navigationController.navigationBar.barTintColor = MCN_buttonColor;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    self.removeBtn.backgroundColor = MCN_buttonColor;
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
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    manager = [DataManager shareInstance];
    NSLog(@"binnumber:%@",[defaults objectForKey:@"binnumber"]);
//    
    array =  [manager isSelect:[defaults objectForKey:@"binnumber"]];
    model = [array objectAtIndex:0];
    
    [self.removeBtn setTitle:NSLocalizedString(@"unbound", nil) forState:UIControlStateNormal];
    
    if(model.CurrentFirmware.length==0)
    {
        model.CurrentFirmware=@"00000000";
    }
    
    if(([model.CurrentFirmware rangeOfString:@"D10_CHUANGMT"].location != NSNotFound)||([model.CurrentFirmware rangeOfString:@"D9_CHUANGMT"].location != NSNotFound)||([model.DeviceType isEqualToString:@"2"])||([model.CurrentFirmware rangeOfString:@"D9_TP_CHUANGMT"].location != NSNotFound)||([model.CurrentFirmware rangeOfString:@"D12_CHUANGMT"].location != NSNotFound)||([model.CurrentFirmware rangeOfString:@"YDB_S3_C1_CHUANGMT"].location != NSNotFound))//添加易多宝判断（YDB）
    {
        isGPS = NO;
    }
    else{
        isGPS = YES;
    }
    
    if([model.DeviceType isEqualToString:@"2"])
    {
        seciton1Array = [[NSArray alloc] initWithObjects:NSLocalizedString(@"watch_firmware_version_d8", nil),NSLocalizedString(@"model", nil), nil];
    }
    else
    {
        seciton1Array = [[NSArray alloc] initWithObjects:NSLocalizedString(@"watch_firmware_version", nil),NSLocalizedString(@"model", nil), nil];
    }
    seciton2Array = [[NSArray alloc] initWithObjects:@"GPS",@"WIFI",NSLocalizedString(@"three_axis_sensor", nil),nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 1;
    }
    else if (section == 1)
    {
        return 2;
    }
    return 3;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(isGPS)
    {
        return 2;
    }
    else
    {
        return 2;
    }
}

//每个分组上边预留的空白高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return 0.1;
    }
    else if(section == 2)
    {
        return 15;
    }
        return 5;
}
//每个分组下边预留的空白高度
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 2)
    {
        if([model.DeviceType isEqualToString:@"2"])
        {
            return NSLocalizedString(@"configuration_d8", nil);
        }
        else
        {
            return NSLocalizedString(@"configuration", nil);
        }
    }
    return @"";
}

//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
////    if (indexPath.section==0) {
////        return 185;
////    }
//    return 40;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        static  NSString *watchOneTable = @"watchOneTable";
        
        UINib *nib = [UINib nibWithNibName:@"AboutWatchOneTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:watchOneTable];
        
        AboutWatchOneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:watchOneTable];
        if (cell == nil) {
            cell = [[AboutWatchOneTableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:watchOneTable];
        }
        cell.erweimaImage.image = [QRCodeGenerator qrImageForString:model.BindNumber imageSize:cell.erweimaImage.bounds.size.width];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.watchBindNumLabel.text  = model.BindNumber;
        if([model.DeviceType isEqualToString:@"2"])
        {
            cell.scanLabel.text = NSLocalizedString(@"watch_QR_Code_d8", nil);
            cell.watchErweimaLabel.text = NSLocalizedString(@"sweep_bound_d8", nil);
            cell.watchBindLabel.text = NSLocalizedString(@"watch_bound_no_d8", nil);
        }
        else
        {
            cell.scanLabel.text = NSLocalizedString(@"watch_QR_Code", nil);
            cell.watchErweimaLabel.text = NSLocalizedString(@"sweep_bound", nil);
            cell.watchBindLabel.text = NSLocalizedString(@"watch_bound_no", nil);
        }

        
        return cell;
    }
    else
    {
        static  NSString *watchOneTable = @"watchOneTable";
        
        UINib *nib = [UINib nibWithNibName:@"AboutWatchTwoTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:watchOneTable];
        
        AboutWatchTwoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:watchOneTable];
        if (cell == nil) {
            cell = [[AboutWatchTwoTableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:watchOneTable];
        }
        
        if(indexPath.section == 1)
        {
            cell.title.text = [seciton1Array objectAtIndex:indexPath.row];
            if(indexPath.row == 0)
            {
                cell.listLabel.text = model.CurrentFirmware;
                                
            }
            else if(indexPath.row == 1)
            {
                cell.listLabel.text = [NSString stringWithFormat:@"AnQuanShouHuII%@",model.DeviceModelID];
            }
  
        }
        else if(indexPath.section == 2)
        {
            cell.title.text = [seciton2Array objectAtIndex:indexPath.row];

            if(indexPath.row == 0)
            {
                cell.listLabel.text = NSLocalizedString(@"GPS_PS", nil);
            }
            else if(indexPath.row == 1)
            {
                cell.listLabel.text = NSLocalizedString(@"WIFI_PS", nil);
            }
            else
            {
                cell.listLabel.text = NSLocalizedString(@"three_axis_sensor_PS", nil);
            }
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        
        return cell;
    }
}

- (void)setviewinfo
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:NO];
    
}

- (IBAction)removeBtn:(id)sender {
    
    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:NSLocalizedString(@"unbound", nil) contentText:NSLocalizedString(@"sure_unbind", nil) leftButtonTitle:NSLocalizedString(@"cancel",nil ) rightButtonTitle:NSLocalizedString(@"OK", nil)];
    [alert show];
    alert.leftBlock = ^() {
    };
    
    alert.rightBlock = ^() {
        
        WebService *webService = [WebService newWithWebServiceAction:@"ReleaseBound" andDelegate:self];
        webService.tag = 0;
        WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"GET" andValue:[NSString stringWithFormat:@"watchAppUser/deleteDeviceByImei/%@/%@",[defaults objectForKey:MAIN_USER_TOKEN],[defaults objectForKey:@"binnumber"]]];
        NSArray *parameter = @[parameter1];
        // webservice请求并获得结果
        webService.webServiceParameter = parameter;
        self.removeBtn.enabled = NO;
        [webService getWebServiceResult:@"ReleaseBoundResult"];
        
    };
    alert.dismissBlock = ^() {
        NSLog(@"Do something interesting after dismiss block");
    };
}

- (void)WebServiceGetCompleted:(id)theWebService
{
    WebService *ws = theWebService;
    
    if ([[theWebService soapResults] length] > 0) {////
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        // 解析成json数据

        id object = [parser objectWithString:[theWebService soapResults] error:&error];
        if (!error && object) {///
            // 获得状态
            int code = [[object objectForKey:@"Code"] intValue];
            //注册成功
          
                if(ws.tag == 0){
                    self.removeBtn.enabled = YES;
                    if(code == 1){
                        [manager removeFavourite:[defaults objectForKey:@"binnumber"]];
                        [manager deleDeviceSetItem:[defaults objectForKey:@"binnumber"]];
                        [manager removeContactTable:[defaults objectForKey:@"binnumber"]];
                    
                        NSMutableArray *allArray  = [manager getAllFavourie];
                        if(allArray.count == 0){
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"threadExit" object:self];

                            [OMGToast showWithText:NSLocalizedString(@"unbundling_successful_login_again", nil) bottomOffset:50 duration:3];
                            [defaults setObject:@"0" forKey:@"DMloginScaleKey"];
                            [defaults setObject:@"1" forKey:@"goSowMain"];
                            [defaults setObject:@"" forKey:@"binnumber"];
                        }else{
                            [OMGToast showWithText:NSLocalizedString(@"unbundling_success", nil) bottomOffset:50 duration:3];
                            DeviceModel *deviceModel = [[manager getAllFavourie] objectAtIndex:0];
                            [defaults setObject:deviceModel.BindNumber forKey:@"binnumber"];
                        }
                        UIWindow *window = [UIApplication sharedApplication].keyWindow;
                        if ([window.rootViewController isKindOfClass:[UINavigationController class]]) {
                            UINavigationController *nav = window.rootViewController;
                            for(UIViewController *controller in nav.viewControllers){
                                if([controller isKindOfClass:[LoginViewController class]]){
                                    return;
                                }
                            }
                        }
                        LoginViewController *vc = [[LoginViewController alloc] init];
                        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                        [window setRootViewController:nav];
                        [window makeKeyAndVisible];
                    }else{
                        [OMGToast showWithText:NSLocalizedString(@"unbind_fail", nil) bottomOffset:50 duration:3];
                    }
                }else if(ws.tag == 1){
                    if(code == 1)
                    {
                        EditHeadAndNameViewController *edit = [[EditHeadAndNameViewController alloc] init];
                        [defaults setInteger:1 forKey:@"editWatch"];
                            
                        [self.navigationController pushViewController:edit animated:YES];
                    }
                    else if(code == 4)
                    {
                        [OMGToast showWithText:NSLocalizedString(@"equipment_has_been_associated", nil) bottomOffset:50 duration:2];
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                    else if (code == 3)
                    {
                        [OMGToast showWithText:NSLocalizedString(@"device_no_exist", nil) bottomOffset:50 duration:2];
                        [self.navigationController popViewControllerAnimated:YES];
                        
                    }
                    else if (code == 2)
                    {
                        alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"input_name", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
                        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                        [alertView show];
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
                   
                }
                else if (ws.tag == 3)
                {
                    [self.navigationController popViewControllerAnimated:YES];
                    [OMGToast showWithText:NSLocalizedString([object objectForKey:@"Message"], nil)  bottomOffset:50 duration:2];
                }

        }
    }
}

- (void)WebServiceGetError:(id)theWebService error:(NSString *)theError{
    self.removeBtn.enabled = YES;
    [OMGToast showWithText:NSLocalizedString(@"waring_internet_error", nil) bottomOffset:50 duration:3];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        WebService *webService = [WebService newWithWebServiceAction:@"LinkDevice" andDelegate:self];
        webService.tag = 3;
        WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
        
        WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"name" andValue:[NSString stringWithFormat:@"%@",[alertView textFieldAtIndex:0].text]];
        WebServiceParameter *loginParameter4 = [WebServiceParameter newWithKey:@"bindNumber" andValue:[defaults objectForKey:@"bindNumber"]];
        WebServiceParameter *loginParameter5 = [WebServiceParameter newWithKey:@"language" andValue:[defaults objectForKey:@"currentLanguage_phone"]];
        WebServiceParameter *loginParameter6 = [WebServiceParameter newWithKey:@"timeZone" andValue:[defaults objectForKey:@"currentTimezone"]];

        NSArray *parameter = @[loginParameter1,loginParameter3,loginParameter4,loginParameter5,loginParameter6];
        // webservice请求并获得结果
        webService.webServiceParameter = parameter;
        [webService getWebServiceResult:@"LinkDeviceResult"];
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
