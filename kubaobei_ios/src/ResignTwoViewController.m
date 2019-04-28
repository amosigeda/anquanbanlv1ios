//
//  ResignTwoViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "ResignTwoViewController.h"
#import "ResignThreeViewController.h"
#import "PsswordSetViewController.h"
#import "LoginViewController.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "OMGToast.h"
#import "CommonCrypto/CommonDigest.h"

@interface ResignTwoViewController ()<WebServiceProtocol,UITextFieldDelegate>
{
    NSUserDefaults *defaults;
    NSTimer *timer;
    int time;
    int height;
    
    NSString *changeString;
}
@end

@implementation ResignTwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    time = 60;
    self.checkCode.backgroundColor = MCN_buttonColor;
    self.nextButton.backgroundColor = MCN_buttonColor;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];
    
    self.checkNum.delegate = self;
    
    self.noticeLabel.text = [defaults objectForKey:@"phoneNum"];
    self.phoneNumber.text = NSLocalizedString(@"sent_identifying_code", nil);
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
    
    //[self.checkButton setBackgroundImage:[UIImage imageNamed:@"message_normal"] forState:UIControlStateNormal];
    //[self.checkButton setTitle:NSLocalizedString(@"get_code", nil) forState:UIControlStateNormal];
    self.checkNum.placeholder=@"输入验证码";
    [self.checkCode setTitle:NSLocalizedString(@"Change_code", nil) forState:UIControlStateNormal];
    [self change_codes];
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
    
    if([defaults integerForKey:@"reforType"] == 0)
    {
        WebService *webService = [WebService newWithWebServiceAction:@"RegisterCheck" andDelegate:self];
        webService.tag = 0;
        WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"phoneNumber" andValue:self.phoneNumber.text];
        WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"project" andValue:PROJECT];

        NSArray *parameter = @[loginParameter1,loginParameter2];
        // webservice请求并获得结果
        webService.webServiceParameter = parameter;
        [webService getWebServiceResult:@"RegisterCheckResult"];
    }
    else
    {
        WebService *webService = [WebService newWithWebServiceAction:@"ForgotCheck" andDelegate:self];
        webService.tag = 1;
        WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"phoneNumber" andValue:self.phoneNumber.text];
        NSArray *parameter = @[loginParameter1];
        // webservice请求并获得结果
        webService.webServiceParameter = parameter;
        [webService getWebServiceResult:@"ForgotCheckResult"];
    }
  
}

//md5 16位加密 （大写）
-(NSString *)md5:(NSString *)str {
    
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result);
    
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",result[0], result[1], result[2], result[3],result[4], result[5], result[6], result[7],result[8], result[9], result[10], result[11],result[12], result[13], result[14], result[15]];
}

- (IBAction)doNext:(id)sender {
   
    [self.passwordTextField resignFirstResponder];
    [self.againPassWord resignFirstResponder];
    
    if([self.checkNum.text isEqualToString:changeString]==NO)
    {
        [OMGToast showWithText:NSLocalizedString(@"verification_code_error", nil) bottomOffset:50 duration:2];
        return;
    }
    
    if(self.passwordTextField.text.length == 0 || self.againPassWord.text.length == 0)
    {
        [OMGToast showWithText:NSLocalizedString(@"pwd_cannot_null", nil) bottomOffset:50 duration:2];
        return;
    }
    
    NSString *check_phonecode = [self md5:[defaults objectForKey:@"phoneNum"]];
    
    if([self.passwordTextField.text isEqualToString:self.againPassWord.text])
    {

        WebService *webService = [WebService newWithWebServiceAction:@"Register" andDelegate:self];
        webService.tag = 3;
        WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"phoneNumber" andValue:[defaults objectForKey:@"phoneNum"]];
        WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"phoneCode" andValue:check_phonecode];
        WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"checkNumber" andValue:self.checkNum.text];
        WebServiceParameter *loginParameter4 = [WebServiceParameter newWithKey:@"passWord" andValue:self.againPassWord.text];
        WebServiceParameter *loginParameter5 = [WebServiceParameter newWithKey:@"appleId" andValue:@""];
        WebServiceParameter *loginParameter6 = [WebServiceParameter newWithKey:@"project" andValue:PROJECT];
        WebServiceParameter *loginParameter7 = [WebServiceParameter newWithKey:@"language" andValue:[defaults objectForKey:@"currentLanguage_phone"]];
        WebServiceParameter *loginParameter8 = [WebServiceParameter newWithKey:@"version" andValue:[defaults objectForKey:@"currentVersion"]];
        NSArray *parameter = @[loginParameter1,loginParameter2,loginParameter3,loginParameter4,loginParameter5,loginParameter6,loginParameter7,loginParameter8];
        // webservice请求并获得结果
        webService.webServiceParameter = parameter;
        [webService getWebServiceResult:@"RegisterResult"];

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
                        
                        /*
                            timer=[NSTimer scheduledTimerWithTimeInterval:1
                                                                   target:self
                                                                 selector:@selector(loadTimer)
                                                                 userInfo:nil repeats:YES];
                        */
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
                        [defaults setInteger:0 forKey:@"loginType"];
                        [self.navigationController pushViewController:vc animated:YES];
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



#define kLineCount 4
- (void)change_codes
{
    // @{
    // @name 生成背景色
    float red = arc4random() % 100 / 100.0;
    float green = arc4random() % 100 / 100.0;
    float blue = arc4random() % 100 / 100.0;
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:0.2];
    self.checkButton.backgroundColor = [UIColor clearColor];
    [self.checkButton setBackgroundColor:color];
    // @} end 生成背景色
    
    // @{
    // @name 生成文字
    NSArray *changeArray = [NSArray array];
    changeArray = [NSArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z", nil];
    
    NSMutableString *getStr = [[[NSMutableString alloc] initWithCapacity:5] init]; //可变字符串，存取得到的随机数
    
    changeString = [[[NSMutableString alloc] initWithCapacity:6] init]; //可变string，最终想要的验证码
    for(NSInteger i = 0; i < kLineCount; i++) //得到四个随机字符，取四次，可自己设长度
    {
        NSInteger index = arc4random() % ([changeArray count] - 1);  //得到数组中随机数的下标
        getStr = [changeArray objectAtIndex:index];  //得到数组中随机数，赋给getStr
        
        changeString = (NSMutableString *)[changeString stringByAppendingString:getStr]; //把随机字符加到可变string后面，循环四次后取完
    }
    
    NSLog(@"changeString:%@", changeString);
    // @} end 生成文字
    
    CGSize cSize = [@"m" sizeWithAttributes: @{NSFontAttributeName: [UIFont systemFontOfSize:20]}];
    int width_font = self.checkButton.frame.size.width / changeString.length-3;
    int height_font = self.checkButton.frame.size.height - cSize.height;
    CGPoint point;
    float pX, pY;
    
    for (int i = 0; i < kLineCount; i++) {
        pX = width_font + 80 / kLineCount * i - 1;
        pY = arc4random() % height_font;
        point = CGPointMake(pX, pY);
        unichar c = [changeString characterAtIndex:i];
        /*
        UILabel *tempLabel = [[UILabel alloc]
                              initWithFrame:CGRectMake(pX, pY,
                                                       self.checkButton.frame.size.width / 4,
                                                       self.checkButton.frame.size.height)];
        tempLabel.backgroundColor = [UIColor clearColor];
         */
        
        // 字体颜色
        float red = arc4random() % 100 / 100.0;
        float green = arc4random() % 100 / 100.0;
        float blue = arc4random() % 100 / 100.0;
        UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
        
        NSString *textC = [NSString stringWithFormat:@"%C", c];
        //tempLabel.textColor = color;
        //tempLabel.text = textC;
        
        if(i==0){
            self.Code1Label.textColor = color;
            self.Code1Label.text = textC;
        }
        else if(i==1){
            self.Code2Label.textColor = color;
            self.Code2Label.text = textC;
        }
        else if(i==2){
            self.Code3Label.textColor = color;
            self.Code3Label.text = textC;
        }
        else{
            self.Code4Label.textColor = color;
            self.Code4Label.text = textC;
        }
        //[self.checkButton addSubview:tempLabel];
    }
    
    // 干扰线
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    for(int i = 0; i < kLineCount; i++) {
        red = arc4random() % 100 / 100.0;
        green = arc4random() % 100 / 100.0;
        blue = arc4random() % 100 / 100.0;
        color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
        pX = arc4random() % (int)self.checkButton.frame.size.width;
        pY = arc4random() % (int)self.checkButton.frame.size.height;
        CGContextMoveToPoint(context, pX, pY);
        pX = arc4random() % (int)self.checkButton.frame.size.width;
        pY = arc4random() % (int)self.checkButton.frame.size.height;
        CGContextAddLineToPoint(context, pX, pY);
        CGContextSetStrokeColorWithColor(context, [color CGColor]);
        CGContextStrokePath(context);  
    }

    //[self.checkButton setTitle:[NSString stringWithFormat:@"%@",changeString] forState:UIControlStateNormal];
    
    return;  
}

- (IBAction)checkCode:(id)sender {
   // [self.checkButton removeFromSuperview];
    [self change_codes];
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
