//
//  ForgetTwoViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//
#import "ForgetTwoViewController.h"
#import "ResignThreeViewController.h"
#import "PsswordSetViewController.h"
#import "LoginViewController.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "OMGToast.h"

extern NSString *qrcode_str;
@interface ForgetTwoViewController ()<WebServiceProtocol,UITextFieldDelegate>
{
    NSUserDefaults *defaults;
    NSTimer *timer;
    int time;
    int height;
    
    NSString *changeString;
}
@end

@implementation ForgetTwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    time = 60;
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    self.nextButton.backgroundColor = MCN_buttonColor;
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];
    
    self.checkNum.delegate = self;
    
    self.noticeLabel.text = [defaults objectForKey:@"phoneNum"];
    self.phoneNumber.text = NSLocalizedString(@"sent_identifying_password", nil);
    self.checkButton.userInteractionEnabled = NO;
    self.passwordTextField.placeholder = NSLocalizedString(@"your_pwd", nil);
    self.againPassWord.placeholder = NSLocalizedString(@"confirm_pwd", nil);
    [self.nextButton setTitle:NSLocalizedString(@"next", nil) forState:UIControlStateNormal];
    
    height=self.view.frame.size.height;

    //使用NSNotificationCenter 鍵盤出現時
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWasShown:)
     
                                                 name:UIKeyboardDidShowNotification object:nil];
    //使用NSNotificationCenter 鍵盤隐藏時
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWillBeHidden:)
     
                                                 name:UIKeyboardWillHideNotification object:nil];
    

    self.checkNum.placeholder=@"输入短信验证码";
    
     timer=[NSTimer scheduledTimerWithTimeInterval:1
     target:self
     selector:@selector(loadTimer)
     userInfo:nil repeats:YES];
    
    [self.checkButton setBackgroundImage:[UIImage imageNamed:@"message_normal"] forState:UIControlStateNormal];
    [self.checkButton setTitle:NSLocalizedString(@"get_password", nil) forState:UIControlStateNormal];
    
    //[self.checkButton setTitle:[NSString stringWithFormat:@"%@",changeString] forState:UIControlStateNormal];
}


- (void)keyboardWasShown:(NSNotification*)aNotification
{
    self.view.frame = CGRectMake(self.view.frame.origin.x, -80, self.view.frame.size.width,height);
}

//当键盘隐藏的时候
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    self.view.frame =CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width, height);
}

- (void)loadTimer
{
    time --;
    self.checkButton.userInteractionEnabled = NO;

    [self.checkButton setTitle:[NSString stringWithFormat:@"%@(%ds)", NSLocalizedString(@"get_code", nil),time] forState:UIControlStateNormal];
    
    if(time == -1)
    {
        [timer invalidate];
        [self.checkButton setTitle:NSLocalizedString(@"get_code", nil) forState:UIControlStateNormal];
        [self.checkButton setTitleColor:[UIColor colorWithRed:255/255.0 green:204/255.0 blue:102/255.0 alpha:1] forState:UIControlStateNormal];
        [self.checkButton setBackgroundImage:[UIImage imageNamed:@"login_button"] forState:UIControlStateNormal];
        self.checkButton.userInteractionEnabled = YES;
    }
}

- (void)setviewinfo
{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)checkNumber:(id)sender {
    
    WebService *webService = [WebService newWithWebServiceAction:@"ForgotCheck" andDelegate:self];
    webService.tag = 1;
    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"phoneNumber" andValue:self.phoneNumber.text];
    WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"project" andValue:PROJECT];
    NSArray *parameter = @[loginParameter1,loginParameter2];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"ForgotCheckResult"];
  
}

- (IBAction)doNext:(id)sender {
   
    [self.passwordTextField resignFirstResponder];
    [self.againPassWord resignFirstResponder];
    
    if(self.passwordTextField.text.length == 0 || self.againPassWord.text.length == 0)
    {
        [OMGToast showWithText:NSLocalizedString(@"pwd_cannot_null", nil) bottomOffset:50 duration:2];
        return;
    }
    
    if([self.passwordTextField.text isEqualToString:self.againPassWord.text])
    {
 
        WebService *webService = [WebService newWithWebServiceAction:@"Forgot" andDelegate:self];
        webService.tag = 4;
        WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"phoneNumber" andValue:[defaults objectForKey:@"phoneNum"]];
        WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"checkNumber" andValue:self.checkNum.text];
        WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"passWord" andValue:self.againPassWord.text];
        WebServiceParameter *loginParameter4 = [WebServiceParameter newWithKey:@"appleId" andValue:@""];
        WebServiceParameter *loginParameter5 = [WebServiceParameter newWithKey:@"project" andValue:PROJECT];
        WebServiceParameter *loginParameter6 = [WebServiceParameter newWithKey:@"SerialNumber" andValue:qrcode_str];
        WebServiceParameter *loginParameter7 = [WebServiceParameter newWithKey:@"language" andValue:[defaults objectForKey:@"currentLanguage_phone"]];
        WebServiceParameter *loginParameter8 = [WebServiceParameter newWithKey:@"version" andValue:[defaults objectForKey:@"currentVersion"]];
        NSArray *parameter = @[loginParameter1,loginParameter2,loginParameter3,loginParameter4,loginParameter5,loginParameter6,loginParameter7,loginParameter8];
        // webservice请求并获得结果
        webService.webServiceParameter = parameter;
        [webService getWebServiceResult:@"ForgotResult"];
        
    }
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
                //注册成功
                if(code == 1)
                {
                    if(ws.tag == 0 || ws.tag == 1)
                    {
                        [OMGToast showWithText:NSLocalizedString(@"ver_code_your_phone_please_find", nil) bottomOffset:50 duration:2];
                        
                            timer=[NSTimer scheduledTimerWithTimeInterval:1
                                                                   target:self
                                                                 selector:@selector(loadTimer)
                                                                 userInfo:nil repeats:YES];
                        [defaults setObject:@"Message" forKey:@"Message"];
                    }
                    else if(ws.tag == 3)
                    {
                        [timer invalidate];
                        time = 60;
                        ResignThreeViewController *resign = [[ResignThreeViewController alloc] init];
                        resign.title = NSLocalizedString(@"reg_suc", nil);
                        [self.navigationController pushViewController:resign animated:YES];
                    }
                    else if(ws.tag == 4)
                    {
                        [timer invalidate];
                        time = 60;
                        [OMGToast showWithText:NSLocalizedString(@"edit_suc_login", nil) bottomOffset:50 duration:2];
                        LoginViewController *vc = [[LoginViewController alloc] init];
                        for (UIViewController *controller in self.navigationController.viewControllers) {
                            if ([controller isKindOfClass:[vc class]]) {
                                [self.navigationController popToViewController:controller animated:YES];
                            }
                        }
                    }
                }//
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
                else
                {
                     [OMGToast showWithText:NSLocalizedString([object objectForKey:@"Message"], nil)  bottomOffset:50 duration:2];
                }
        }
    }
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
