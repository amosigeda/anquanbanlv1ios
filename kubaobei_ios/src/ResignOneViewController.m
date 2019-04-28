//
//  ResignOneViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//
#import "NSString+Tools.h"
#import "ResignOneViewController.h"
#import "ResignTwoViewController.h"
#import "ForgetTwoViewController.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "OMGToast.h"
#import "LoginViewController.h"
#import "CommonCrypto/CommonDigest.h"

@interface ResignOneViewController ()<WebServiceProtocol,UITextFieldDelegate>
{
    NSUserDefaults *defaults;
    
}
@end

@implementation ResignOneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    self.next_Btn.backgroundColor = MCN_buttonColor;
    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];
    
    self.phoneNumberTextField.delegate = self;
    self.phoneNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    self.phoneNumberTwoTextField.delegate = self;
    self.phoneNumberTwoTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    if([defaults integerForKey:@"reforType"] == 1)
    {
        self.listLabel.hidden = YES;
    }
    else
    {
        self.listLabel.hidden = NO;
    }
    
    self.phone_Label.text = NSLocalizedString(@"input_reg_num", nil);
    self.phonetwo_Label.text = NSLocalizedString(@"Again_input_phone_num", nil);
    self.listLabel.text = NSLocalizedString(@"PS_reg", nil);
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

//md5 16位加密 （大写）
-(NSString *)md5:(NSString *)str {
    
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result);
    
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",result[0], result[1], result[2], result[3],result[4], result[5], result[6], result[7],result[8], result[9], result[10], result[11],result[12], result[13], result[14], result[15]];
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
  
    
    NSString *phonecode = [self md5:self.phoneNumberTextField.text];
    
    if([self.phoneNumberTextField.text isEqualToString:self.phoneNumberTwoTextField.text])
    {
        WebService *webService = [WebService newWithWebServiceAction:@"RegisterCheck" andDelegate:self];
        webService.tag = 0;
        WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"phoneNumber" andValue:self.phoneNumberTextField.text];
        WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"phoneCode" andValue:phonecode];
        WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"project" andValue:PROJECT];

        NSArray *parameter = @[loginParameter1,loginParameter2,loginParameter3];
        // webservice请求并获得结果
        webService.webServiceParameter = parameter;
        [webService getWebServiceResult:@"RegisterCheckResult"];
    }
    
    else
    {
        [OMGToast showWithText:NSLocalizedString(@"phone_num_equa", nil) bottomOffset:50 duration:2];
        return;
        
    }

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

                    ResignTwoViewController *resign = [[ResignTwoViewController alloc] init];
                    resign.title = NSLocalizedString(@"get_code", nil);
                    [self.navigationController pushViewController:resign animated:YES];

                }
                else if(code == 3)
                {
                    [OMGToast showWithText:NSLocalizedString(@"user_available", nil) bottomOffset:50 duration:3];
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
                
                if(code != 1&&code != 3)
                {
                    [OMGToast showWithText:NSLocalizedString([object objectForKey:@"Message"], nil)  bottomOffset:50 duration:2];
                }
            }//
            else
            {
                if(code == 1)
                {
                    [defaults setObject:[object objectForKey:@"Check"] forKey:@"Check"];
                    [defaults setObject:@"Message" forKey:@"Message"];
                    [defaults setObject:self.phoneNumberTextField.text forKey:@"phoneNum"];

                    ResignTwoViewController *resign = [[ResignTwoViewController alloc] init];
                    resign.title = NSLocalizedString(@"get_code", nil);
                    [self.navigationController pushViewController:resign animated:YES];

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
            
        }///
        
    }////
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:NO];

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
