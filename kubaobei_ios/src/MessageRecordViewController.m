//
//  MessageRecordViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "MessageRecordViewController.h"
#import "DataManager.h"
#import "DeviceModel.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "OMGToast.h"
#import "MessageModel.h"
#import "MessageRecordTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "EditHeadAndNameViewController.h"
#import "LocationViewController.h"
#import "LoginViewController.h"
#import "MJRefresh.h"

@interface MessageRecordViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    NSUserDefaults *defaults;
    DeviceModel *deviceModel;
    MessageModel *model;
    DataManager *manager;
    NSMutableArray *deviceArray;
    NSMutableArray *conArray;
    NSMutableArray *messageArray;
    BOOL isShow;
    UIButton* rightBtn;
    NSMutableArray *nameArr;

}
@end

@implementation MessageRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     defaults = [NSUserDefaults standardUserDefaults];
    conArray = [[NSMutableArray alloc] init];
    deviceArray = [[NSMutableArray alloc] init];
    messageArray = [[NSMutableArray alloc] init];
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
    
    rightBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [rightBtn setTitle:NSLocalizedString(@"edit", nil) forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    rightBtn.frame = CGRectMake(0, 0, 50, 30);
    UIBarButtonItem* rightBtnItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    
    [rightBtn addTarget:self action:@selector(showNext) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setRightBarButtonItem:rightBtnItem];
    
    if([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    manager =  [DataManager shareInstance];
    
    deviceArray =  [manager isSelect:[defaults objectForKey:@"binnumber"]];
    deviceModel = [deviceArray objectAtIndex:0];
    conArray = [manager getAllMessageTable];
    for(int i = 0; i < conArray.count;i++)
    {
        MessageModel *modelss = [conArray objectAtIndex:i];
        NSLog(@"%@",modelss.Message);
    }

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 73;
    self.tableView.tableFooterView = [UIView new];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.tableView addHeaderWithTarget:self action:@selector(Refresh)];
    self.tableView.headerPullToRefreshText = @"";
    self.tableView.headerRefreshingText = NSLocalizedString(@"load", nil);
    self.tableView.headerReleaseToRefreshText = NSLocalizedString(@"down_load", nil);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMessage) name:@"refreshMessage" object:nil];

    [self getMessage];
}

-(void)Refresh
{
    [self getMessage];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    model = [messageArray objectAtIndex:messageArray.count - 1 - indexPath.row];
    WebService *webService = [WebService newWithWebServiceAction:@"DeleteMsg" andDelegate:self];
    webService.tag = 1;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"GET" andValue:[NSString stringWithFormat:@"message/deleteMsg/%@/%@/%@",[defaults objectForKey:MAIN_USER_TOKEN],[defaults objectForKey:@"binnumber"],model.mId]];
    NSArray *parameter = @[parameter1];
    // webservice请求并获得结
    
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"DeleteMsgResult"];
    [manager deleteMessageWithId:model.mId];
    conArray = [manager getAllMessageTable];
    messageArray = [manager isSelectWithDeviceID:deviceModel.DeviceID];
    [self.tableView reloadData];
}

- (void)setviewinfo
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    model = [messageArray objectAtIndex:messageArray.count-1 - indexPath.row ];
    
    [defaults setObject:model.AddDevice forKey:@"NoDeviceID"];
    
    if(model.Type.intValue == 2)
    {
        NSArray *array = [model.Content componentsSeparatedByString:@","];
        [defaults setObject:[array objectAtIndex:0] forKey:@"NOUseID"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:model.Message delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil),nil];
        
        alert.tag = 2;
        [alert show];
    }
    else if (model.Type.intValue > 100 && model.Type.intValue < 200)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];

        
        [defaults setObject:model.DeviceID forKey:@"MapDevice"];
        [defaults setObject:[[model.Content componentsSeparatedByString:@"-"] objectAtIndex:0] forKey:@"MapLat"];
        [defaults setObject:[[model.Content componentsSeparatedByString:@"-"] objectAtIndex:1] forKey:@"MapLng"];
        [defaults setObject:model.CreateTime forKey:@"MapTime"];
        
        [defaults setObject:@"1" forKey:@"messageToLocation"];//定位选择
        
        LocationViewController *vc = [[LocationViewController alloc] init];
        vc.title = NSLocalizedString(@"positioning", nil);
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        if(alertView.tag == 2)
        {
            EditHeadAndNameViewController *vc = [[EditHeadAndNameViewController alloc] init];
            [defaults setInteger:4 forKey:@"editWatch"];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:NO];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cell1 = @"cell1";
    UINib *nib = [UINib nibWithNibName:@"MessageRecordTableViewCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:cell1];
    
    MessageRecordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell1];
    if (cell == nil) {
        cell = [[MessageRecordTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cell1];
    }
    model = [messageArray objectAtIndex:messageArray.count-1 - indexPath.row ];
    
    cell.title3Label.text = model.Message;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];

    cell.timeLabel.text = model.CreateTime;
    if(model.Type.intValue == 2)
    {
        if([deviceModel.DeviceType isEqualToString:@"2"])
        {
            cell.title2Label.text = NSLocalizedString(@"ask_binding_watch_d8", nil);
        }
        else{
            cell.title2Label.text = NSLocalizedString(@"ask_binding_watch", nil);
        }
        cell.coadImage.image = [UIImage imageNamed:@"bangding_watch"];
    }
    else if(model.Type.intValue == 3)
    {
        cell.title2Label.text = NSLocalizedString(@"admin_agree", nil);
        cell.coadImage.image = [UIImage imageNamed:@"agree_icon"];
    }
    else if(model.Type.intValue == 4)
    {
        cell.title2Label.text = NSLocalizedString(@"admin_refuse", nil);
        cell.coadImage.image = [UIImage imageNamed:@"dele_bangding_icon"];
    }
    else if(model.Type.intValue == 5)
    {
        if([deviceModel.DeviceType isEqualToString:@"2"])
        {
            cell.title2Label.text = NSLocalizedString(@"watch_updata_d8", nil);
        }
        else{
            cell.title2Label.text = NSLocalizedString(@"watch_updata", nil);
        }
        cell.coadImage.image = [UIImage imageNamed:@"update_watch"];
    }
    else if(model.Type.intValue == 6)
    {
        if([deviceModel.DeviceType isEqualToString:@"2"])
        {
            cell.title2Label.text = NSLocalizedString(@"watchInfo_Synchronous_d8", nil);
        }
        else{
            cell.title2Label.text = NSLocalizedString(@"watchInfo_Synchronous", nil);
        }
        cell.coadImage.image = [UIImage imageNamed:@"load_watch"];
    }
    else if(model.Type.intValue == 7)
    {
        cell.title2Label.text = NSLocalizedString(@"concast_Synchronous", nil);
        cell.coadImage.image = [UIImage imageNamed:@"book_watch"];
    }
    else if(model.Type.intValue == 10)
    {
        cell.title2Label.text = NSLocalizedString(@"baby_Synchronous", nil);
        cell.coadImage.image = [UIImage imageNamed:@"baby_watch"];
    }
    else if (model.Type.intValue == 206)
    {
        cell.title2Label.text = NSLocalizedString(@"new_announcement", nil);
        cell.coadImage.image = [UIImage imageNamed:@"gonggao_icon"];
    }
    else if (model.Type.intValue > 100 && model.Type.intValue < 200)
    {
        cell.title2Label.text = NSLocalizedString(@"alarm_to_remind", nil);
        cell.coadImage.image = [UIImage imageNamed:@"alert"];
    }
    else
    {
        cell.title2Label.text = NSLocalizedString(@"school_defend", nil);
        cell.coadImage.image = [UIImage imageNamed:@"school_small_icon"];
    }
    
    if([deviceModel.Photo isEqualToString:@""])
    {
        cell.iconImage.image = [UIImage imageNamed:@"user_head_normal"];
    }
    else
    {
        [cell.iconImage setImageWithURL:[NSURL URLWithString:deviceModel.Photo]];
        
    }
    
    return cell;
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

- (void)getMessage
{
    WebService *webService = [WebService newWithWebServiceAction:@"GetMessage" andDelegate:self];
    webService.tag = 0;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"GET" andValue:[NSString stringWithFormat:@"message/msglist/%@/%@",[defaults objectForKey:MAIN_USER_TOKEN],[defaults objectForKey:@"binnumber"]]];
    NSArray *parameter = @[parameter1];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"GetMessageResult"];
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
            [self.tableView headerEndRefreshing];
            if(code == 1){
                if(ws.tag == 0){
                    NSArray *list = [object objectForKey:@"List"];
                    for(int i = 0; i < list.count;i++){
                        [manager addMessageDeviceID:deviceModel.DeviceID andType:[[list objectAtIndex:i] objectForKey:@"Type"] andAddDevice:[[list objectAtIndex:i] objectForKey:@"DeviceID"]  andContent:[[list objectAtIndex:i] objectForKey:@"Content"] andMessage:[[list objectAtIndex:i] objectForKey:@"Message"] andCreateTime:[[list objectAtIndex:i] objectForKey:@"CreateTime"] andId:[[list objectAtIndex:i] objectForKey:@"id"]];
                    }
                    conArray = [manager getAllMessageTable];
                    messageArray = [manager isSelectWithDeviceID:deviceModel.DeviceID];
                    [self.tableView reloadData];
                }
            }
        }
    }
}

- (void)WebServiceGetError:(id)theWebService error:(NSString *)theError{
    [OMGToast showWithText:NSLocalizedString(@"waring_internet_error", nil) bottomOffset:50 duration:3];
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
