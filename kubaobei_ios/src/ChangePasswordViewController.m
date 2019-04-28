//
//  ChangePasswordViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "OMGToast.h"
#import "LoginViewController.h"
#import "ResignOneViewController.h"
#import "Constants.h"

@interface ChangePasswordViewController ()<UITextFieldDelegate,WebServiceProtocol>
{
    NSUserDefaults *defaults;
    BOOL ishow1;
    BOOL ishow2;
}
@end

@implementation ChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ishow1 = NO;
    ishow2 = NO;
    defaults = [NSUserDefaults standardUserDefaults];
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    self.finishButton.backgroundColor = MCN_buttonColor;
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.passwordTextField.delegate = self;
    self.againPasswordTextField.delegate = self;
    self.oldPasswordTextField.delegate = self;
    
    self.oldPasswordTextField.placeholder = NSLocalizedString(@"old_pwd", nil);
    self.passwordTextField.placeholder = NSLocalizedString(@"new_pwd", nil);
    self.againPasswordTextField.placeholder = NSLocalizedString(@"confirm_pwd", nil);
    [self.forgetPasswordButton setTitle:NSLocalizedString(@"forget_password", nil) forState:UIControlStateNormal];
    [self.finishButton setTitle:NSLocalizedString(@"finish", nil) forState:UIControlStateNormal];
    

}

- (void)setviewinfo{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)forgotAction:(id)sender {
    
    ResignOneViewController *vc = [[ResignOneViewController alloc] init];
    
    [defaults setInteger:1 forKey:@"reforType"];
    vc.title = NSLocalizedString(@"forget_password", nil);
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)finishAction:(id)sender {
    
    [self.oldPasswordTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.againPasswordTextField resignFirstResponder];
    
    if(![self.passwordTextField.text isEqualToString:self.againPasswordTextField.text]){
        [OMGToast showWithText:NSLocalizedString(@"pwd_different", nil) bottomOffset:50 duration:2];
        return;
    }
    
    WebService *webService = [WebService newWithWebServiceAction:@"ChangePassword" andDelegate:self];
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"POST" andValue:@"watchAppUser/udpatePwd"];
    WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"token" andValue:[defaults objectForKey:MAIN_USER_TOKEN]];
    WebServiceParameter *parameter3 = [WebServiceParameter newWithKey:@"tel" andValue:[defaults objectForKey:@"DMusername"]];
    WebServiceParameter *parameter4 = [WebServiceParameter newWithKey:@"pwd" andValue:self.passwordTextField.text];
    WebServiceParameter *parameter5 = [WebServiceParameter newWithKey:@"oldpwd" andValue:self.oldPasswordTextField.text];
    NSArray *parameter = @[parameter1,parameter2,parameter3,parameter4,parameter5];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"ChangePasswordResult"];
}

- (void)WebServiceGetCompleted:(id)theWebService
{
    if ([[theWebService soapResults] length] > 0) {
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        // 解析成json数据
        id object = [parser objectWithString:[theWebService soapResults] error:&error];
        if (!error && object) {
            // 获得状态
            int code = [[object objectForKey:@"Code"] intValue];
            //注册成功
            if(code == 1){
               // LoginViewController *vc = [[LoginViewController alloc] init];
//                [defaults setInteger:0 forKey:@"loginType"];
                [defaults setValue:self.passwordTextField.text forKey:@"DMpassword"];
                [OMGToast showWithText:NSLocalizedString(@"edit_suc", nil) bottomOffset:50 duration:2];
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [OMGToast showWithText:NSLocalizedString(@"edit_fail", nil) bottomOffset:50 duration:3];
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

- (IBAction)showPass1:(id)sender {
    
    if(ishow1 == NO)
    {
        [self.showPass1 setBackgroundImage:[UIImage imageNamed:@"remember_icon"] forState:UIControlStateNormal];
        self.passwordTextField.secureTextEntry = NO;
        ishow1 = YES;
    }else
    {
        [self.showPass1 setBackgroundImage:[UIImage imageNamed:@"remember_icon_normal"] forState:UIControlStateNormal];
        self.passwordTextField.secureTextEntry = YES;

        ishow1 = NO;
    }
}


- (IBAction)showPass2:(id)sender {
    
    if(ishow2 == NO)
    {
        [self.showPass2 setBackgroundImage:[UIImage imageNamed:@"remember_icon"] forState:UIControlStateNormal];
        self.againPasswordTextField.secureTextEntry = NO;
        ishow2 = YES;
    }else
    {
        [self.showPass2 setBackgroundImage:[UIImage imageNamed:@"remember_icon_normal"] forState:UIControlStateNormal];
        self.againPasswordTextField.secureTextEntry = YES;
        ishow2 = NO;
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
