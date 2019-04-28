//
//  ForgetOneViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//
#import "NSString+Tools.h"
#import "ForgetOneViewController.h"
#import "ResignTwoViewController.h"
#import "ForgetTwoViewController.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "OMGToast.h"
#import "LoginViewController.h"
#import "CommonCrypto/CommonDigest.h"
#import "SYQRCodeViewController.h"
#import "PsswordSetViewController.h"

NSString *qrcode_str;

@interface ForgetOneViewController ()<WebServiceProtocol,UITextFieldDelegate>
{
    NSUserDefaults *defaults;
    SYQRCodeViewController *vc;
    NSString *imeiStr;
}
@end

@implementation ForgetOneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    self.next_Btn.backgroundColor = MCN_buttonColor;
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
    
    self.phoneNumberTextField.delegate = self;
    self.phoneNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    if([defaults integerForKey:@"reforType"] == 1)
    {
        self.listLabel.hidden = YES;
    }
    else
    {
        self.listLabel.hidden = YES;
    }
    
    self.phone_Label.text = NSLocalizedString(@"forgot_pwd_tips", nil);
    [self.next_Btn setTitle:NSLocalizedString(@"next", nil) forState:UIControlStateNormal];
    
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

- (IBAction)doNext:(id)sender {
    [self.phoneNumberTextField resignFirstResponder];
    
//    if(self.phoneNumberTextField.text.length != 11)
//    {
//        [OMGToast showWithText:NSLocalizedString(@"input_right_no", nil) bottomOffset:50 duration:2];
//
//        return;
//    }
    if (![self.phoneNumberTextField.text isValidateMobile:self.phoneNumberTextField.text])
    {
        [OMGToast showWithText:NSLocalizedString(@"input_right_no", nil) bottomOffset:50   duration:4];
        return;
    }
    [self ForgetshowAddView];
    
    /*
    WebService *webService = [WebService newWithWebServiceAction:@"ForgotCheck" andDelegate:self];
    webService.tag = 1;
    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"phoneNumber" andValue:self.phoneNumberTextField.text];
    WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"project" andValue:PROJECT];
    NSArray *parameter = @[loginParameter1,loginParameter2];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"ForgotCheckResult"];
     */
    
}

- (void)WebServiceGetCompleted:(id)theWebService
{
    WebService * ws = theWebService;
    if ([[theWebService soapResults] length] > 0) {////
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        // 解析成json数据
        id object = [parser objectWithString:[theWebService soapResults] error:&error];
        if (!error && object) {///
            // 获得状态
            int code = [[object objectForKey:@"Code"] intValue];
            
            if(ws.tag == 0)
            {
                //注册成功
                if(code == 1)
                {
                    [defaults setObject:@"Message" forKey:@"Message"];
                    [defaults setObject:self.phoneNumberTextField.text forKey:@"phoneNum"];
                    if([defaults integerForKey:@"reforType"] == 0)
                    {
                        ResignTwoViewController *resign = [[ResignTwoViewController alloc] init];
                        resign.title = NSLocalizedString(@"get_code", nil);
                        [self.navigationController pushViewController:resign animated:YES];
                    }
                    else{
                        ForgetTwoViewController *resign = [[ForgetTwoViewController alloc] init];
                        resign.title = NSLocalizedString(@"get_password", nil);
                        [self.navigationController pushViewController:resign animated:YES];
                    }
                    
                }
                else if(code == 3)
                {
                }
                else if(code == 0)
                {
                    LoginViewController *vc = [[LoginViewController alloc] init];
                    for (UIViewController *controller in self.navigationController.viewControllers) {
                        if ([controller isKindOfClass:[vc class]]) {
                            [self.navigationController popToViewController:controller animated:YES];
                        }
                    }
                }
                
                if(code != 1)
                {
                    [OMGToast showWithText:NSLocalizedString([object objectForKey:@"Message"], nil)  bottomOffset:50 duration:2];
                }
            }//
            else if(ws.tag == 1){
                if(code == 1){
                    PsswordSetViewController *pswSetController = [[PsswordSetViewController alloc] init];
                    pswSetController.title = NSLocalizedString(@"get_password", nil);
                    pswSetController.imeiStr = imeiStr;
                    [self.navigationController pushViewController:pswSetController animated:YES];
                }else if(code == 2){
                    [OMGToast showWithText:NSLocalizedString(@"forgot_pwd_error_tips", nil) bottomOffset:50 duration:3];
                }else if(code == -1){
                    [OMGToast showWithText:NSLocalizedString(@"forgot_pwd_unchange_tips", nil) bottomOffset:50 duration:3];
                }else{
                    [OMGToast showWithText:NSLocalizedString(@"send_fail", nil) bottomOffset:50 duration:3];
                }
            }else{
                if(code == 1){
                    [defaults setObject:[object objectForKey:@"Check"] forKey:@"Check"];
                    [defaults setObject:@"Message" forKey:@"Message"];
                    [defaults setObject:self.phoneNumberTextField.text forKey:@"phoneNum"];
                    if([defaults integerForKey:@"reforType"] == 0)
                    {
                        ResignTwoViewController *resign = [[ResignTwoViewController alloc] init];
                        resign.title = NSLocalizedString(@"get_code", nil);
                        [self.navigationController pushViewController:resign animated:YES];
                    }
                    else{
                        ForgetTwoViewController *resign = [[ForgetTwoViewController alloc] init];
                        resign.title = NSLocalizedString(@"get_password", nil);
                        [self.navigationController pushViewController:resign animated:YES];
                    }
                }else if(code == 3){
                    ForgetOneViewController *resign = [[ForgetOneViewController alloc] init];
                    resign.title = NSLocalizedString(@"forget_password", nil);
                    [self.navigationController pushViewController:resign animated:YES];

                }else if(code == 0){
                    LoginViewController *vc = [[LoginViewController alloc] init];
                    for (UIViewController *controller in self.navigationController.viewControllers) {
                        if ([controller isKindOfClass:[vc class]]) {
                            [self.navigationController popToViewController:controller animated:YES];
                        }
                    }
                }
                else if(code == -2)
                {
                    ForgetOneViewController *resign = [[ForgetOneViewController alloc] init];
                    resign.title = NSLocalizedString(@"forget_password", nil);
                    [self.navigationController pushViewController:resign animated:YES];
                }
            }//
            
        }///
        
    }////
}

- (void)WebServiceGetError:(id)theWebService error:(NSString *)theError{
    [OMGToast showWithText:NSLocalizedString(@"waring_internet_error", nil) bottomOffset:50 duration:3];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)ForgetshowAddView
{
    [defaults setInteger:1 forKey:@"editWatch"];
    
    SYQRCodeViewController *qrcodevc = [[SYQRCodeViewController alloc] init];
    qrcodevc.title = NSLocalizedString(@"scans", nil);
    qrcodevc.SYQRCodeSuncessBlock = ^(SYQRCodeViewController *aqrvc,NSString *qrString){
        [qrcodevc.navigationController popViewControllerAnimated:YES];
        if ([qrString isValidateIMEI:qrString]){
            imeiStr = qrString;
            WebService *webService = [WebService newWithWebServiceAction:@"ForgotCheck" andDelegate:self];
            webService.tag = 1;
            WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"GET" andValue:[NSString stringWithFormat:@"watchAppUser/verificationImeiAdmin/%@/%@",imeiStr,self.phoneNumberTextField.text]];
            NSArray *parameter = @[parameter1];
            // webservice请求并获得结果
            webService.webServiceParameter = parameter;
            [webService getWebServiceResult:@"ForgotCheckResult"];
        }else{
            [OMGToast showWithText:NSLocalizedString(@"input_login_IMEIError", nil) bottomOffset:50 duration:3];
        }
        
    };
    qrcodevc.SYQRCodeFailBlock = ^(SYQRCodeViewController *aqrvc){
        [OMGToast showWithText:NSLocalizedString(@"scans_error", nil) bottomOffset:50 duration:3];
        [qrcodevc dismissViewControllerAnimated:NO completion:nil];
    };
    qrcodevc.SYQRCodeCancleBlock = ^(SYQRCodeViewController *aqrvc){
        [OMGToast showWithText:NSLocalizedString(@"scan_cancellation", nil) bottomOffset:50 duration:3];
        [qrcodevc dismissViewControllerAnimated:NO completion:nil];
    };
    //  [self presentViewController:qrcodevc animated:YES completion:nil];
    [self.navigationController pushViewController:qrcodevc animated:YES];
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
