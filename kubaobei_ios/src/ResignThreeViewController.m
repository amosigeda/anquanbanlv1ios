//
//  ResignThreeViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "ResignThreeViewController.h"
#import "SYQRCodeViewController.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "OMGToast.h"
#import "EditHeadAndNameViewController.h"
#import "LoginViewController.h"

@interface ResignThreeViewController ()<UIAlertViewDelegate>
{
    NSUserDefaults *defaults;
    UIAlertView *alerView;
}
@end

@implementation ResignThreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.binding_Btn.backgroundColor = MCN_buttonColor;
    defaults = [NSUserDefaults standardUserDefaults];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];
    [defaults setValue:@"2" forKey:@"editWatch"];
    
    
    //if([model.DeviceType isEqualToString:@"2"])
    if(/* DISABLES CODE */ (0))
    {
        [self.binding_Btn setTitle:NSLocalizedString(@"bound_watch_d8", nil) forState:UIControlStateNormal];
        self.lsit_Label.text = NSLocalizedString(@"registered_success_bind_watch_d8", nil);
    }
    else{
        [self.binding_Btn setTitle:NSLocalizedString(@"bound_watch", nil) forState:UIControlStateNormal];
        self.lsit_Label.text = NSLocalizedString(@"registered_success_bind_watch", nil);
    }

}

- (void)setviewinfo
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)qrcView:(id)sender {
    
    SYQRCodeViewController *qrcodevc = [[SYQRCodeViewController alloc] init];
    qrcodevc.title =NSLocalizedString(@"scan", nil);
    qrcodevc.SYQRCodeSuncessBlock = ^(SYQRCodeViewController *aqrvc,NSString *qrString){
        
        if([qrString rangeOfString:@"?"].location != NSNotFound)
        {
            [defaults setObject:[[qrString componentsSeparatedByString:@"?"] objectAtIndex:1] forKey:@"bindNumber"];
        }
        else if(([qrString rangeOfString:@"/"].location != NSNotFound))
        {
            NSArray *arr = [qrString componentsSeparatedByString:@"/"];
            
            
            [defaults setObject:[[qrString componentsSeparatedByString:@"/"] objectAtIndex:arr.count-1] forKey:@"bindNumber"];
        }
        else
        {
            [defaults setObject:qrString forKey:@"bindNumber"];
        }

        WebService *webService = [WebService newWithWebServiceAction:@"LinkDeviceCheck" andDelegate:self];
        webService.tag = 0;
        WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
        WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"bindNumber" andValue:[defaults objectForKey:@"bindNumber"]];
        
        NSArray *parameter = @[loginParameter1, loginParameter2];
        // webservice请求并获得结果
        webService.webServiceParameter = parameter;
        [webService getWebServiceResult:@"LinkDeviceCheckResult"];

    };
    qrcodevc.SYQRCodeFailBlock = ^(SYQRCodeViewController *aqrvc){
        [aqrvc dismissViewControllerAnimated:NO completion:nil];
    };
    qrcodevc.SYQRCodeCancleBlock = ^(SYQRCodeViewController *aqrvc){
        [aqrvc dismissViewControllerAnimated:NO completion:nil];
    };
    //  [self presentViewController:qrcodevc animated:YES completion:nil];
    [self.navigationController pushViewController:qrcodevc animated:YES];
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
                    [defaults setInteger:0 forKey:@"edit"];
                    
                    EditHeadAndNameViewController *edit = [[EditHeadAndNameViewController alloc] init];
                    [defaults setInteger:2 forKey:@"editWatch"];
                    
                    [self.navigationController pushViewController:edit animated:YES];
 
                }
                else if (ws.tag == 3)
                {
                    LoginViewController *vc = [[LoginViewController alloc] init];
                    for (UIViewController *controller in self.navigationController.viewControllers) {
                        if ([controller isKindOfClass:[vc class]]) {
                            [self.navigationController popToViewController:controller animated:YES];
                        }
                    }
                }
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
                alerView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"input_name", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
                alerView.alertViewStyle = UIAlertViewStylePlainTextInput;
                alerView.tag = 1;
                [alerView show];
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
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        WebService *webService = [WebService newWithWebServiceAction:@"LinkDevice" andDelegate:self];
        webService.tag = 3;
        WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
        
        WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"name" andValue:[NSString stringWithFormat:@"%@",[alertView textFieldAtIndex:0].text]];
        WebServiceParameter *loginParameter4 = [WebServiceParameter newWithKey:@"bindNumber" andValue:[defaults objectForKey:@"bindNumber"]];
        WebServiceParameter *loginParameter5 = [WebServiceParameter newWithKey:@"language" andValue:[defaults objectForKey:@"currentLanguage"]];
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
