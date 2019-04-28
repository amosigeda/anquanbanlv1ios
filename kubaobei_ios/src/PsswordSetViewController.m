//
//  PsswordSetViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "PsswordSetViewController.h"
#import "ResignThreeViewController.h"

#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "OMGToast.h"
#import "LoginViewController.h"

@interface PsswordSetViewController ()<WebServiceProtocol,UITextFieldDelegate>
{
    NSUserDefaults *defaults;
}
@end

@implementation PsswordSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    self.finishButton.backgroundColor = MCN_buttonColor;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];
    self.noticeLabel.text = @"";
    //    self.noticeLabel.text = NSLocalizedString(@"input_pwd", nil);
    self.passwordTextField.placeholder = NSLocalizedString(@"your_pwd", nil);
    self.againPasswordTextField.placeholder = NSLocalizedString(@"confirm_pwd", nil);
    [self.finishButton setTitle:NSLocalizedString(@"finish", nil) forState:UIControlStateNormal];
    
}

- (IBAction)nextAction:(id)sender {
    
    if(self.passwordTextField.text.length == 0 || self.againPasswordTextField.text.length == 0)
    {
        [OMGToast showWithText:NSLocalizedString(@"pwd_cannot_null", nil) bottomOffset:50 duration:2];
        return;
    }
    
    if([self.passwordTextField.text isEqualToString:self.againPasswordTextField.text]){
        WebService *webService = [WebService newWithWebServiceAction:@"Forgot" andDelegate:self];
        webService.tag = 1;
        WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"POST" andValue:@"watchAppUser/udpatePwdByImei"];
        WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"pwd" andValue:self.passwordTextField.text];
        WebServiceParameter *parameter3 = [WebServiceParameter newWithKey:@"imei" andValue:self.imeiStr];
        NSArray *parameter = @[parameter1,parameter2,parameter3];
        // webservice请求并获得结果
        webService.webServiceParameter = parameter;
        [webService getWebServiceResult:@"ForgotResult"];
    }
    //    {
    //        if([defaults integerForKey:@"reforType" ]== 0)
    //        {
    //            WebService *webService = [WebService newWithWebServiceAction:@"Register" andDelegate:self];
    //            webService.tag = 0;
    //            WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"phoneNumber" andValue:[defaults objectForKey:@"phoneNum"]];
    //            WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"checkNumber" andValue:[defaults objectForKey:@"Check"]];
    //            WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"passWord" andValue:self.againPasswordTextField.text];
    //            WebServiceParameter *loginParameter4 = [WebServiceParameter newWithKey:@"appleId" andValue:@""];
    //
    //            WebServiceParameter *loginParameter5 = [WebServiceParameter newWithKey:@"language" andValue:[defaults objectForKey:@"currentLanguage_phone"]];
    //            WebServiceParameter *loginParameter6 = [WebServiceParameter newWithKey:@"version" andValue:[defaults objectForKey:@"currentVersion"]];
    //            NSArray *parameter = @[loginParameter1,loginParameter2,loginParameter3,loginParameter4,loginParameter5,loginParameter6];
    //
    //            // webservice请求并获得结果
    //            webService.webServiceParameter = parameter;
    //            [webService getWebServiceResult:@"RegisterResult"];
    //        }
    //        else
    //        {
    //            WebService *webService = [WebService newWithWebServiceAction:@"Forgot" andDelegate:self];
    //            webService.tag = 1;
    //            WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"phoneNumber" andValue:[defaults objectForKey:@"phoneNum"]];
    //            WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"checkNumber" andValue:[defaults objectForKey:@"Check"]];
    //            WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"passWord" andValue:self.againPasswordTextField.text];
    //            WebServiceParameter *loginParameter4 = [WebServiceParameter newWithKey:@"appleId" andValue:@""];
    //            WebServiceParameter *loginParameter5 = [WebServiceParameter newWithKey:@"language" andValue:[defaults objectForKey:@"currentLanguage_phone"]];
    //            WebServiceParameter *loginParameter6 = [WebServiceParameter newWithKey:@"version" andValue:[defaults objectForKey:@"currentVersion"]];
    //            NSArray *parameter = @[loginParameter1,loginParameter2,loginParameter3,loginParameter4,loginParameter5,loginParameter6];
    //            // webservice请求并获得结果
    //            webService.webServiceParameter = parameter;
    //            [webService getWebServiceResult:@"ForgotResult"];
    //        }
    //    }
    else
    {
        [OMGToast showWithText:NSLocalizedString(@"pwd_different", nil) bottomOffset:50 duration:2];
        return;
    }
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
            if(ws.tag == 1){
                if(code == 1){
                    [OMGToast showWithText:NSLocalizedString(@"edit_suc", nil) bottomOffset:50 duration:2];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }else{
                    [OMGToast showWithText:NSLocalizedString(@"edit_fail", nil) bottomOffset:50 duration:2];
                }
            }else{
                //注册成功
                if(code == 1)
                {
                    [defaults setObject:[object objectForKey:@"LoginId"] forKey:@"LoginId"];
                    [defaults setObject:[object objectForKey:@"UserId"] forKey:@"UserId"];
                    [defaults setObject:[object objectForKey:@"UserType"] forKey:@"UserType"];
                    [defaults setObject:[object objectForKey:@"Name"] forKey:@"Name"];
                    [defaults setObject:[object objectForKey:@"Notification"] forKey:@"Notification"];
                    [defaults setObject:[object objectForKey:@"NotificationSound"] forKey:@"NotificationSound"];
                    [defaults setObject:[object objectForKey:@"NotificationVibration"] forKey:@"NotificationVibration"];
                    
                    if(ws.tag == 0)
                    {
                        ResignThreeViewController *resign = [[ResignThreeViewController alloc] init];
                        //if([model.DeviceType isEqualToString:@"2"])
                        if(/* DISABLES CODE */ (0))
                        {
                            resign.title = NSLocalizedString(@"reg_suc_bound_d8", nil);
                        }
                        else
                        {
                            resign.title = NSLocalizedString(@"reg_suc_bound", nil);
                        }
                        [self.navigationController pushViewController:resign animated:YES];
                        
                    }
                    else
                    {
                        [OMGToast showWithText:NSLocalizedString(@"edit_suc_login", nil) bottomOffset:50 duration:2];
                        LoginViewController *vc = [[LoginViewController alloc] init];
                        [defaults setInteger:0 forKey:@"loginType"];
                        [self.navigationController pushViewController:vc animated:YES];
                    }
                }
                else if(code == 3)
                {
                    [OMGToast showWithText:NSLocalizedString(@"user_available", nil) bottomOffset:50 duration:3];
                }
                else if(code == -2)
                {
                    [OMGToast showWithText:NSLocalizedString(@"system_error", nil) bottomOffset:50 duration:3];
                }
                else if(code == 4)
                {
                    [OMGToast showWithText:NSLocalizedString(@"verification_code_error", nil) bottomOffset:50 duration:3];
                }
                else if(code == 5)
                {
                    [OMGToast showWithText:NSLocalizedString(@"captcha_overdue", nil) bottomOffset:50 duration:3];
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
}

- (void)WebServiceGetError:(id)theWebService error:(NSString *)theError{
    [OMGToast showWithText:NSLocalizedString(@"waring_internet_error", nil) bottomOffset:50 duration:3];
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
