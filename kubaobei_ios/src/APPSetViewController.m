//
//  APPSetViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "APPSetViewController.h"
#import "APPSetTableViewCell.h"
#import "ChangePasswordViewController.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "OMGToast.h"
#import "LoginViewController.h"
#import "DXAlertView.h"
#import "MessageNotiViewController.h"
#import "DataManager.h"
#import "Constants.h"
#import "HelpcontetViewController.h"

@interface APPSetViewController ()<UITableViewDataSource,UITableViewDelegate,WebServiceProtocol,UIAlertViewDelegate>

{
    NSArray *iconList;
    NSArray *nameList;
    NSUserDefaults *defaults;
    DataManager *manager;
    NSString *app_Version;
    int  ver;
    
}
@end

@implementation APPSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"1" forKey:@"showRight"];
    [defaults setObject:@"0" forKey:@"showLeft"];
    manager = [DataManager shareInstance];
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    self.logoutButton.backgroundColor = MCN_buttonColor;
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
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
    app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    NSArray *arr =[app_Version componentsSeparatedByString:@"."];
    
    ver = [[arr objectAtIndex:0] intValue] * 10000 + [[arr objectAtIndex:1] intValue] * 100 +[[arr objectAtIndex:2] intValue];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 40;
    self.tableView.tableFooterView = [UIView new];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    iconList = [[NSArray alloc] initWithObjects:@"alerts_icon",@"change_password",@"clean_cache",@"help_icon",nil];
    nameList = [[NSArray alloc] initWithObjects:NSLocalizedString(@"msg_notification", nil),NSLocalizedString(@"change_pwd", nil),NSLocalizedString(@"cache", nil),NSLocalizedString(@"Help_str", nil),nil];
    [self.logoutButton setTitle:NSLocalizedString(@"logout", nil ) forState:UIControlStateNormal];
    
}

- (void)setviewinfo{
    [self.navigationController popViewControllerAnimated:YES];
}


- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"APPSetTab";
    
    UINib *nib = [UINib nibWithNibName:@"APPSetTableViewCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:cellID];
    
    APPSetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[APPSetTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cellID];
    }
    
    cell.icon.image = [UIImage imageNamed:[iconList objectAtIndex:indexPath.row]];
    cell.title.text = [nameList objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == 1)
    {
        ChangePasswordViewController *vc = [[ChangePasswordViewController alloc] init];
        vc.title = NSLocalizedString(@"change_pwd", nil);
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(indexPath.row == 0)
    {
        MessageNotiViewController *mess = [[MessageNotiViewController alloc] init];
        mess.title = NSLocalizedString(@"msg_notification", nil);
        [self.navigationController pushViewController:mess animated:YES];
    }
    else if(indexPath.row == 2)
    {
        DXAlertView *alert;
        if([defaults integerForKey:@"deviceModelType"] == 1)
        {
            alert = [[DXAlertView alloc] initWithTitle:NSLocalizedString(@"cache", nil) contentText:NSLocalizedString(@"cache_PS_d8", nil) leftButtonTitle:NSLocalizedString(@"cancel", nil) rightButtonTitle:NSLocalizedString(@"OK", nil)];
        }
        else{
            alert = [[DXAlertView alloc] initWithTitle:NSLocalizedString(@"cache", nil) contentText:NSLocalizedString(@"cache_PS", nil) leftButtonTitle:NSLocalizedString(@"cancel", nil) rightButtonTitle:NSLocalizedString(@"OK", nil)];
        }
        
        [alert show];
        alert.leftBlock = ^() {
        };
        
        alert.rightBlock = ^() {
            
            [manager dropShortMessage];
            [manager dropMessage];
            [manager dropAudioTable];
            [manager dropPhotoTable];
            [manager createShortMessage];
            [manager createAudioTable];
            [manager createMessageRecord];
            [manager createPhoto];
            [manager dropLocationCache];
            [manager createLocationCache];
            
            NSString *extension = @"wav";
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            
            NSArray *contents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:NULL];
            NSEnumerator *e = [contents objectEnumerator];
            NSString *filename;
            while ((filename = [e nextObject])) {
                
                if ([[filename pathExtension] isEqualToString:extension]) {
                    
                    [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:NULL];
                }
            }
            [OMGToast showWithText:NSLocalizedString(@"cache_success", nil) bottomOffset:50 duration:2];
            
        };
        alert.dismissBlock = ^() {
            NSLog(@"Do something interesting after dismiss block");
        };
    }
    else if(indexPath.row == 3)
    {
        HelpcontetViewController *vc = [[HelpcontetViewController alloc] init];
        vc.title = NSLocalizedString(@"Help_str", nil);
        [self.navigationController pushViewController:vc animated:YES];
        
        /*
         WebService *webService = [WebService newWithWebServiceAction:@"CheckAppVersion" andDelegate:self];
         webService.tag = 100;
         WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
         
         NSArray *parameter = @[loginParameter1];
         // webservice请求并获得结果
         webService.webServiceParameter = parameter;
         [webService getWebServiceResult:@"CheckAppVersionResult"];
         */
    }
}

- (IBAction)doLogout:(id)sender {
    
    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:NSLocalizedString(@"logout", nil) contentText:NSLocalizedString(@"sure_logout", nil) leftButtonTitle:NSLocalizedString(@"cancel", nil) rightButtonTitle:NSLocalizedString(@"OK", nil)];
    [alert show];
    alert.leftBlock = ^() {
    };
    
    alert.rightBlock = ^() {
        [defaults setObject:@"0" forKey:@"passType"];
        
        WebService *webService = [WebService newWithWebServiceAction:@"LoginOut" andDelegate:self];
        webService.tag = 0;
        WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"GET" andValue:[NSString stringWithFormat:@"watchAppUser/exit/%@",[defaults objectForKey:MAIN_USER_TOKEN]]];
        NSArray *parameter = @[parameter1];
        // webservice请求并获得结果
        webService.webServiceParameter = parameter;
        [webService getWebServiceResult:@"LoginOutResult"];
        
        [defaults setInteger:1 forKey:@"loginType"];
        [defaults setObject:@"0" forKey:@"DMloginScaleKey"];
        [defaults setObject:@"1" forKey:@"goSowMain"];
        
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
    };
    alert.dismissBlock = ^() {
        NSLog(@"Do something interesting after dismiss block");
    };
}

//- (void)WebServiceGetCompleted:(id)theWebService
//{
//    WebService *ws = theWebService;
//
//    if ([[theWebService soapResults] length] > 0) {
//        SBJsonParser *parser = [[SBJsonParser alloc] init];
//        NSError *error = nil;
//        // 解析成json数据
//        id object = [parser objectWithString:[theWebService soapResults] error:&error];
//        if (!error && object) {
//            // 获得状态
//            int code = [[object objectForKey:@"Code"] intValue];
//            if(code == 1)
//            {
//                if(ws.tag == 0)
//                {
//                    //                    [[NSNotificationCenter defaultCenter] postNotificationName:@"threadExit" object:self];
//                    [defaults setInteger:1 forKey:@"loginType"];
//                    [defaults setObject:@"0" forKey:@"DMloginScaleKey"];
//                    [defaults setObject:@"1" forKey:@"goSowMain"];
//
//                    UIWindow *window = [UIApplication sharedApplication].keyWindow;
//                    if ([window.rootViewController isKindOfClass:[UINavigationController class]]) {
//                        UINavigationController *nav = window.rootViewController;
//                        for(UIViewController *controller in nav.viewControllers){
//                            if([controller isKindOfClass:[LoginViewController class]]){
//                                return;
//                            }
//                        }
//                    }
//                    LoginViewController *vc = [[LoginViewController alloc] init];
//                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
//                    [window setRootViewController:nav];
//                    [window makeKeyAndVisible];
//                    //                    for (UIViewController *controller in self.navigationController.viewControllers) {
//                    //                        if ([controller isKindOfClass:[vc class]]) {
//                    //                            [self.navigationController popToViewController:controller animated:YES];
//                    //                        }
//                    //                    }
//                }
//                else if(ws.tag == 100)
//                {
//                    [defaults setObject:[object objectForKey:@"AppleUrl"] forKey:@"AppleUrl"];
//
//
//                    if(ver < [[object objectForKey:@"AppleVersion"] intValue])
//                    {
//                        UIAlertView *view = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"have_new_versions", nil) message:[NSString stringWithFormat:NSLocalizedString(@"have_new_versions", nil)] delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"update_latter", nil),NSLocalizedString(@"update_now", nil), nil];
//                        [view show];
//                    }
//                    else
//                    {
//                        UIAlertView *view = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"have_new_versions", nil) message:NSLocalizedString(@"is_new_version", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
//                        view.tag = 1;
//                        [view show];
//                    }
//                }
//            }else if(ws.tag == 0){
//                [defaults setInteger:1 forKey:@"loginType"];
//                [defaults setObject:@"0" forKey:@"DMloginScaleKey"];
//                [defaults setObject:@"1" forKey:@"goSowMain"];
//
//                UIWindow *window = [UIApplication sharedApplication].keyWindow;
//                if ([window.rootViewController isKindOfClass:[UINavigationController class]]) {
//                    UINavigationController *nav = window.rootViewController;
//                    for(UIViewController *controller in nav.viewControllers){
//                        if([controller isKindOfClass:[LoginViewController class]]){
//                            return;
//                        }
//                    }
//                }
//                LoginViewController *vc = [[LoginViewController alloc] init];
//                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
//                [window setRootViewController:nav];
//                [window makeKeyAndVisible];
//                [OMGToast showWithText:NSLocalizedString(@"abnormal_login", nil) bottomOffset:50 duration:3];
//                //                    for (UIViewController *controller in self.navigationController.viewControllers) {
//                //                        if ([controller isKindOfClass:[vc class]]) {
//                //                            [self.navigationController popToViewController:controller animated:YES];
//                //                        }
//                //                    }
//            }
//        }
//        //            else if(code == 0)
//        //            {
//        //                [OMGToast showWithText:NSLocalizedString(@"abnormal_login", nil) bottomOffset:50 duration:3];
//        //                LoginViewController *vc = [[LoginViewController alloc] init];
//        //                for (UIViewController *controller in self.navigationController.viewControllers) {
//        //                    if ([controller isKindOfClass:[vc class]]) {
//        //                        [self.navigationController popToViewController:controller animated:YES];
//        //                    }
//        //                }
//        //            }
//        //            if(code != 1)
//        //            {
//        //              //  [OMGToast showWithText:[object objectForKey:@"Message"] bottomOffset:50 duration:3];
//        //            }
//    }
//}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        if(alertView.tag == 0 )
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[defaults objectForKey:@"AppleUrl"]]];
        }
    }
}

//- (void)WebServiceGetError:(id)theWebService error:(NSString *)theError{
//    [OMGToast showWithText:NSLocalizedString(@"send_fail", nil) bottomOffset:50 duration:3];
//}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
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
