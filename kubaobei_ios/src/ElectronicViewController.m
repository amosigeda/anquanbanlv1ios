//
//  ElectronicViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//
#import "ElectronicViewController.h"
#import "ElectronicMapViewController.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "OMGToast.h"
#import "DataManager.h"
#import "ElectronicTableViewCell.h"
#import "DeviceModel.h"
#import "Constants.h"

@interface ElectronicViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

{
    NSUserDefaults *defaults;
    DataManager *manager;
    DeviceModel *deviceModel;
    
    NSMutableArray *deviceArray;
    NSMutableArray *nameArr;
    NSIndexPath *_indexPath;
}
@end

@implementation ElectronicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    manager = [DataManager shareInstance];
    deviceArray =  [manager isSelect:[defaults objectForKey:@"binnumber"]];
    deviceModel = [deviceArray objectAtIndex:0];
    nameArr = [[NSMutableArray alloc] init];

    self.cancel_Btn.backgroundColor = MCN_buttonColor;
    self.del_Btn.backgroundColor = MCN_buttonColor;
    self.comfirm_Btn.backgroundColor = MCN_buttonColor;
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    UIButton * rightBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [rightBtn setTitle:NSLocalizedString(@"add", nil) forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    rightBtn.frame = CGRectMake(0, 0, 50, 30);
    UIBarButtonItem* rightBtnItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    
    [rightBtn addTarget:self action:@selector(showNext) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setRightBarButtonItem:rightBtnItem];
    
    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];
    
    if([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
   // self.tableView.editing = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.rowHeight = 55;
    self.tableView.tableFooterView = [UIView new];
    self.nameText.delegate = self;
    self.bgView.layer.borderWidth = 1;
    self.bgView.layer.borderColor = [navigationBarColor CGColor];
    
    self.fence_label.text = NSLocalizedString(@"fence", nil);
    self.in_fence_label.text = NSLocalizedString(@"in_fence", nil);
    self.out_fence_Label.text = NSLocalizedString(@"out_fence", nil);
    self.fence_switch_label.text = NSLocalizedString(@"fence_switch", nil);
    self.check_fence_Label.text = NSLocalizedString(@"check_fence", nil);
    self.alarm_mode_Label.text = NSLocalizedString(@"alarm_mode", nil);
    
    [self.cancel_Btn setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [self.del_Btn setTitle:NSLocalizedString(@"del", nil) forState:UIControlStateNormal];
    [self.comfirm_Btn setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return nameArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cell1 = @"cell1";
    UINib *nib = [UINib nibWithNibName:@"ElectronicTableViewCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:cell1];
    
    ElectronicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell1];
    if (cell == nil) {
        cell = [[ElectronicTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cell1];
    }
    
    cell.nameLabel.text = [[nameArr objectAtIndex:indexPath.row] objectForKey:@"FenceName"];
    
    if([[[nameArr objectAtIndex:indexPath.row] objectForKey:@"Entry"] intValue] == 1)
    {
        if( [[[nameArr objectAtIndex:indexPath.row] objectForKey:@"Exit"] intValue] == 1)
        {
            cell.listLabel.text = NSLocalizedString(@"in_out_fence", nil);
            
        }
        else
        {
            cell.listLabel.text = NSLocalizedString(@"in_fence", nil);
        }
    }
    
    if([[[nameArr objectAtIndex:indexPath.row] objectForKey:@"Exit"] intValue] == 1)
    {
        if([[[nameArr objectAtIndex:indexPath.row] objectForKey:@"Entry"] intValue] == 1)
        {
            cell.listLabel.text = NSLocalizedString(@"in_out_fence", nil);
            
        }
        else
        {
            cell.listLabel.text = NSLocalizedString(@"out_fence", nil);
        }
    }

    return cell;

}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
    [self loadData];
}

- (void)loadData{
    WebService *webService = [WebService newWithWebServiceAction:@"GetGeoFenceList" andDelegate:self];
    webService.tag = 0;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"GET" andValue:[NSString stringWithFormat:@"security/getwatchfence/%@/%@",[defaults objectForKey:MAIN_USER_TOKEN],[defaults objectForKey:@"binnumber"]]];
    NSArray *parameter = @[parameter1];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"GetGeoFenceListResult"];
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
                if(ws.tag == 0){
                    nameArr = [object objectForKey:@"GeoFenceList"];
                    [self.tableView reloadData];
                 }else if(ws.tag == 1){
                    [OMGToast showWithText:NSLocalizedString(@"save_suc", nil) bottomOffset:50 duration:2];
                    [self loadData];
                }else{
                    [OMGToast showWithText:NSLocalizedString(@"del_success", nil) bottomOffset:50 duration:2];
                    [self loadData];
                }
            }else if (ws.tag == 1){
                [OMGToast showWithText:NSLocalizedString(@"save_fail", nil) bottomOffset:50 duration:2];
            }else if(ws.tag == 2){
                [OMGToast showWithText:NSLocalizedString(@"del_fail", nil) bottomOffset:50 duration:2];
            }
        }
    }
}

- (void)WebServiceGetError:(id)theWebService error:(NSString *)theError{
    [OMGToast showWithText:NSLocalizedString(@"waring_internet_error", nil) bottomOffset:50 duration:3];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _indexPath = indexPath;
    self.bgView.hidden = NO;
    
    if([[[nameArr objectAtIndex:indexPath.row] objectForKey:@"Entry"] intValue] == 1){
        self.swip1.on = YES;
    }
    else
    {
        self.swip1.on = NO;
    }
    
    if([[[nameArr objectAtIndex:indexPath.row] objectForKey:@"Exit"] intValue] == 1){
        self.swip2.on = YES;
    }
    else
    {
        self.swip2.on = NO;
    }
    
    if([[[nameArr objectAtIndex:indexPath.row] objectForKey:@"Enable"] intValue] == 1){
        self.swip3.on = YES;
    }
    else
    {
        self.swip3.on = NO;
    }
    self.nameText.text = [[nameArr objectAtIndex:indexPath.row] objectForKey:@"FenceName"];

}

- (void)showNext
{
    ElectronicMapViewController *vc = [[ElectronicMapViewController alloc] init];
    vc.title = NSLocalizedString(@"add_fence", nil);
    [defaults setValue:@"1" forKey:@"addOrEdit"];//搜索地图进入方式

    [defaults setValue:@"1" forKey:@"eleType"];
    [defaults setValue:@"0" forKey:@"eleMapType"];//搜索地图进入方式
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)lookEle:(id)sender {
    self.bgView.hidden = YES;

    ElectronicMapViewController *vc = [[ElectronicMapViewController alloc] init];
    vc.title = NSLocalizedString(@"edit_fence", nil);
    vc.dic = [nameArr objectAtIndex:_indexPath.row];
    [defaults setValue:@"0" forKey:@"eleType"];
    [defaults setValue:@"0" forKey:@"eleMapType"];//搜索地图进入方式
    [defaults setValue:@"0" forKey:@"addOrEdit"];//搜索地图进入方式
    [defaults setObject:[vc.dic objectForKey:@"GeofenceID"] forKey:@"genfenceidddd"];
    [defaults setObject:[vc.dic objectForKey:@"FenceName"] forKey:@"genfencenameee"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)confirm:(id)sender {
    
    self.bgView.hidden = YES;

    WebService *webService = [WebService newWithWebServiceAction:@"SaveGeoFence" andDelegate:self];
    webService.tag = 1;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"POST" andValue:@"security/updatewatchfence"];
    WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"token" andValue:[defaults objectForKey:MAIN_USER_TOKEN]];
    WebServiceParameter *parameter3 = [WebServiceParameter newWithKey:@"imei" andValue:[defaults objectForKey:@"binnumber"]];
    WebServiceParameter *parameter4 = [WebServiceParameter newWithKey:@"id" andValue:[[nameArr objectAtIndex:_indexPath.row] objectForKey:@"GeofenceID"]];
    WebServiceParameter *parameter5 = [WebServiceParameter newWithKey:@"name" andValue:self.nameText.text];
    WebServiceParameter *parameter6 = [WebServiceParameter newWithKey:@"entry" andValue:self.swip1.isOn ? @"1" : @"0"];
    WebServiceParameter *parameter7 = [WebServiceParameter newWithKey:@"exit" andValue:self.swip2.isOn ? @"1" : @"0"];
    WebServiceParameter *parameter8 = [WebServiceParameter newWithKey:@"enable" andValue:self.swip3.isOn?@"1":@"0"];
    WebServiceParameter *parameter9 = [WebServiceParameter newWithKey:@"lat" andValue:[[nameArr objectAtIndex:_indexPath.row] objectForKey:@"Lat"]];
    WebServiceParameter *parameter10 = [WebServiceParameter newWithKey:@"lng" andValue:[[nameArr objectAtIndex:_indexPath.row] objectForKey:@"Lng"]];
    WebServiceParameter *parameter11 = [WebServiceParameter newWithKey:@"radius" andValue:[[nameArr objectAtIndex:_indexPath.row] objectForKey:@"Radii"]];
    NSArray *parameter = @[parameter1, parameter2,parameter3,parameter4,parameter5,parameter6,parameter7,parameter8,parameter9,parameter10,parameter11];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"SaveGeoFenceResult"];
}

- (IBAction)deleAction:(id)sender {
    self.bgView.hidden = YES;
    WebService *webService = [WebService newWithWebServiceAction:@"DeleteGeoFence" andDelegate:self];
    webService.tag = 2;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"GET" andValue:[NSString stringWithFormat:@"security/deletewatchfence/%@/%@",[defaults objectForKey:MAIN_USER_TOKEN],[[nameArr objectAtIndex:_indexPath.row] objectForKey:@"GeofenceID"]]];
    NSArray *parameter = @[parameter1];
        // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"DeleteGeoFenceResult"];
}

- (IBAction)cacelAction:(id)sender {
    
    self.bgView.hidden = YES;
}

- (void)setviewinfo
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
