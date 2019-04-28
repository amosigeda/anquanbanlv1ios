//
//  FriendListViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "FriendListViewController.h"
#import "FriendListTableViewCell.h"
#import "LXActionSheet.h"
#import "DataManager.h"
#import "DeviceModel.h"
#import "ContactModel.h"
#import "VPImageCropperViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "OMGToast.h"
#import "DXAlertView.h"
#import "UIImageView+WebCache.h"
#import "LoginViewController.h"
#import "UIImage+Utility.h"
#import "MJRefresh.h"
#import "Friendlist.h"

@interface FriendListViewController ()<UITableViewDelegate,UITableViewDataSource,LXActionSheetDelegate,UIAlertViewDelegate>
{
    NSUserDefaults *defaults;
    
    Friendlist *friendModel;
    DeviceModel *deviceModel;
    
    NSMutableArray *deviceArray;
    NSMutableArray *friendArray;
    LXActionSheet *actionSheet;
    NSIndexPath *_indexPath;
    DataManager *manager;
    BOOL isShowPersonHead;
    
    NSMutableArray *setArray;
    
@private NSString *imgHex;
    
}
@end

@implementation FriendListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    //manager = [DataManager shareInstance];
    //deviceArray =  [manager isSelect:[defaults objectForKey:@"binnumber"]];
    //deviceModel = [deviceArray objectAtIndex:0];
    
    //[self refresgFriend];
    //friendArray = [manager isSelectFriendListTable:[defaults objectForKey:@"binnumber"]];
    
    [defaults setObject:@"0" forKey:@"showRight"];
    [defaults setObject:@"1" forKey:@"showLeft"];
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];
    
    /*
    UIButton* rightBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setTitle:NSLocalizedString(@"add", nil) forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    rightBtn.frame = CGRectMake(0, 0, 50, 30);
    UIBarButtonItem* rightBtnItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    [rightBtn addTarget:self action:@selector(showNext) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setRightBarButtonItem:rightBtnItem];
    */
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //self.automaticallyAdjustsScrollViewInsets = NO;
    //[self.tableView addHeaderWithTarget:self action:@selector(Refresh)];
    //self.tableView.headerPullToRefreshText = @"";
    //self.tableView.headerRefreshingText = NSLocalizedString(@"header_hint_loading", nil);
    //self.tableView.headerReleaseToRefreshText = NSLocalizedString(@"header_hint_normal", nil);
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresgFriend) name:@"refresgFriend" object:nil];
    
    //[self.tableView reloadData];
}

//每个分组下边预留的空白高度
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return friendArray.count;
}

-(void)Refresh
{
    [self refresgFriend];
}

- (void)showNext
{
    if(friendArray.count >= 50)
    {
        [OMGToast showWithText:NSLocalizedString(@"addressbook_limit", nil) bottomOffset:50 duration:2];
        return;
    }
}

- (void)refresgFriend
{
    WebService *webService = [WebService newWithWebServiceAction:@"GetBabyFriendList" andDelegate:self];
    webService.tag = 5;
    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
    WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"deviceId" andValue:deviceModel.DeviceID];
    WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"DeviceFriendId" andValue:friendModel.DeviceFriendId];
    WebServiceParameter *loginParameter4 = [WebServiceParameter newWithKey:@"Relationship" andValue:friendModel.Relationship];
    WebServiceParameter *loginParameter5 = [WebServiceParameter newWithKey:@"FriendDevicedId" andValue:friendModel.FriendDevicedId];
    WebServiceParameter *loginParameter6 = [WebServiceParameter newWithKey:@"Name" andValue:friendModel.Name];
    WebServiceParameter *loginParameter7 = [WebServiceParameter newWithKey:@"Phone" andValue:friendModel.Phone];
    NSArray *parameter = @[loginParameter1, loginParameter2, loginParameter3, loginParameter4, loginParameter5, loginParameter6, loginParameter7];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"GetBabyFriendListResult"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:NO];
    
    manager = [DataManager shareInstance];
    deviceArray =  [manager isSelect:[defaults objectForKey:@"binnumber"]];
    deviceModel = [deviceArray objectAtIndex:0];
    
    [self refresgFriend];
    friendArray = [manager isSelectFriendListTable:[defaults objectForKey:@"binnumber"]];
    //  [self refresgFriend];
    
    [self.tableView reloadData];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static  NSString *cell1 = @"FriendListCell";
    
    UINib *nib = [UINib nibWithNibName:@"FriendListTableViewCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:cell1];
    
    FriendListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell1];
    if (cell == nil) {
        cell = [[FriendListTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cell1];
    }

    friendModel = [friendArray objectAtIndex:indexPath.row];
    
    cell.nameLabel.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"watch_the_host", nil),friendModel.DeviceFriendId];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.phoneLabel.text = [NSString stringWithFormat:@"%@",friendModel.Name];
    cell.phoneShortLabel.text =[ NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"cornet_family", nil),friendModel.Phone];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    _indexPath = indexPath;
    friendModel = [friendArray objectAtIndex:indexPath.row];
    
    [defaults setInteger:indexPath.row forKey:@"selectIndex"];//用于编辑通讯录选择model
    [defaults setValue:friendModel.DeviceFriendId forKey:@"DeviceFriendId"];
    
    //if(deviceModel.UserId.intValue == conModel.ObjectId.intValue || conModel.ObjectId.intValue == [[defaults objectForKey:@"UserId"] intValue])//我对于自己的操作
    {
       // if(deviceModel.UserId.intValue != friendModel.ObjectId.intValue)
        {
         //   if(deviceModel.UserId.intValue != friendModel.ObjectId.intValue)
            {

                actionSheet = [[LXActionSheet alloc] initWithTitle:friendModel.Name delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:nil otherButtonTitles:@[NSLocalizedString(@"Edit_Friend_Name", nil),NSLocalizedString(@"del", nil)]];
                
                actionSheet.tag = 1;
                [actionSheet showInView:self.view];
            }
        }
    }
}

- (BOOL)isPureInt:(NSString *)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

- (void)didClickOnButtonIndex:(NSInteger *)buttonIndex
{
    if (buttonIndex == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Friend_Name", nil) message:NSLocalizedString(@"Set_Friend_Name", nil)  delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView textFieldAtIndex:0].text = friendModel.Phone;
        alertView.tag = 1;
        [alertView show];
        
    }
    else if(buttonIndex == 1)
    {
        ///删除联系人
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:NSLocalizedString(@"delete_members", nil) contentText:[NSString stringWithFormat:@"%@:%@(%@:%@)",NSLocalizedString(@"whether_delete_members", nil),friendModel.Name,NSLocalizedString(@"phone", nil),friendModel.Phone] leftButtonTitle:NSLocalizedString(@"cancel", nil) rightButtonTitle:NSLocalizedString(@"OK", nil)];
        [alert show];
        alert.leftBlock = ^() {
        };
        
        alert.rightBlock = ^() {
            
            WebService *webService = [WebService newWithWebServiceAction:@"DeleteBabyFriend" andDelegate:self];
            webService.tag = 2;
            WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
            WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"DeviceFriendId" andValue:friendModel.DeviceFriendId];
            NSArray *parameter = @[loginParameter1,loginParameter2];
            // webservice请求并获得结果
            webService.webServiceParameter = parameter;
            [webService getWebServiceResult:@"DeleteBabyFriendResult"];
            
        };
        alert.dismissBlock = ^() {
            NSLog(@"Do something interesting after dismiss block");
        };
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1)
    {
        
        WebService *webService = [WebService newWithWebServiceAction:@"UpdateBabyFriendName" andDelegate:self];
        webService.tag = 10000;
        WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
        WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"deviceId" andValue:deviceModel.DeviceID];
        WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"DeviceFriendId" andValue:friendModel.DeviceFriendId];
        WebServiceParameter *loginParameter4 = [WebServiceParameter newWithKey:@"Name" andValue:friendModel.Name];

        NSArray *parameter = @[loginParameter1, loginParameter2,loginParameter3,loginParameter4];
        // webservice请求并获得结果
        webService.webServiceParameter = parameter;
        [webService getWebServiceResult:@"UpdateBabyFriendNameResult"];
    }
}

- (void)getFriendList
{
    WebService *webService = [WebService newWithWebServiceAction:@"GetBabyFriendList" andDelegate:self];
    webService.tag = 1;
    
    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
    WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"deviceId" andValue:deviceModel.DeviceID];
    WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"DeviceFriendId" andValue:friendModel.DeviceFriendId];
    WebServiceParameter *loginParameter4 = [WebServiceParameter newWithKey:@"Phone" andValue:friendModel.Phone];
    WebServiceParameter *loginParameter5 = [WebServiceParameter newWithKey:@"FriendDevicedId" andValue:friendModel.FriendDevicedId];
    WebServiceParameter *loginParameter6 = [WebServiceParameter newWithKey:@"Relationship" andValue:friendModel.Relationship];
    WebServiceParameter *loginParameter7 = [WebServiceParameter newWithKey:@"Name" andValue:friendModel.Name];
    NSArray *parameter = @[loginParameter1, loginParameter2, loginParameter3, loginParameter4, loginParameter5, loginParameter6, loginParameter7];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"GetBabyFriendListResult"];
    
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
                    [self getFriendList];
                    
                }
                else if(ws.tag == 5)
                {
                    NSMutableArray *arra = [manager isSelectFaWithDevice:deviceModel.DeviceID];
                    if(arra.count != 0)
                    {
                        DeviceModel *des = [arra objectAtIndex:0];
                        [manager removeContactTable:des.BindNumber];
                    
                        NSArray *array = [object objectForKey:@"friendList"];
                    
                        NSString *devicefriendId_new = [[array objectAtIndex:0] objectForKey:@"DeviceFriendId"];
                        
                        if([devicefriendId_new isEqualToString:friendModel.DeviceFriendId]==NO)
                        {
                            for(int i = 0; i<array.count;i++)
                            {
                                [manager addFriendListTable:des.BindNumber andDeviceFriendId:[[array objectAtIndex:i] objectForKey:@"DeviceFriendId"] andPhone:[[array objectAtIndex:i] objectForKey:@"Phone"] andFriendDevicedId:      [[array objectAtIndex:i] objectForKey:@"FriendDeviceId"] andRelationship:[[array objectAtIndex:i] objectForKey:@"Relationship"] andName:[[array objectAtIndex:i] objectForKey:@"Name"]];
                            }
                        }
                    }
                }
                
                
                //[OMGToast showWithText:NSLocalizedString(@"save_suc", nil) bottomOffset:50 duration:2];
                //[self.navigationController popViewControllerAnimated:YES];
            }
            else if(code == 0)
            {
                // [OMGToast showWithText:NSLocalizedString(@"登陆异常", nil) bottomOffset:50 duration:3];
                LoginViewController *vc = [[LoginViewController alloc] init];
                for (UIViewController *controller in self.navigationController.viewControllers) {
                    if ([controller isKindOfClass:[vc class]]) {
                        [self.navigationController popToViewController:controller animated:YES];
                    }
                }
                
            }
            else if(code == 2)
            {
                [OMGToast showWithText:NSLocalizedString(@"数据为空", nil) bottomOffset:50 duration:1];
            }
            else if(code == 3)
            {
                [OMGToast showWithText:NSLocalizedString(@"未取到数据", nil) bottomOffset:50 duration:1];
            }

            [OMGToast showWithText:[object objectForKey:@"Message"] bottomOffset:50 duration:1];
        }
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
