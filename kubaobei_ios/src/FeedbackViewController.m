//
//  FeedbackViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "FeedbackViewController.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "OMGToast.h"
#import "MyFeedbackViewController.h"
#import "LoginViewController.h"
#import "Constants.h"

@interface FeedbackViewController ()<UITextViewDelegate>
{
    NSUserDefaults *defaults;

}
@end

@implementation FeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];
    
    UIButton* rightBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    self.sendButton .backgroundColor = MCN_buttonColor;
    // [rightBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    [rightBtn setTitle:@"我的反馈" forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [rightBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    rightBtn.frame = CGRectMake(20, 0, 80, 30);
    
    UIBarButtonItem* rightBtnItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    
    [rightBtn addTarget:self action:@selector(myfeed) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setRightBarButtonItem:rightBtnItem];
    
    if([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    self.textView.delegate = self;
}

- (void)myfeed
{
    MyFeedbackViewController *myfeedback = [[MyFeedbackViewController alloc] init];
    myfeedback.title = @"我的反馈";
    [self.navigationController pushViewController:myfeedback animated:YES];
}

- (BOOL)textView:(UITextView *)atextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSString *new = [self.textView.text stringByReplacingCharactersInRange:range withString:text];
    NSInteger res = 400-[new length];
    if(res >= 0){
        return YES;
    }
    else{
        NSRange rg = {0,[text length]+res};
        if (rg.length>0) {
            NSString *s = [text substringWithRange:rg];
            [self.textView setText:[self.textView.text stringByReplacingCharactersInRange:range withString:s]];
        }
        return NO;
    }
}

- (IBAction)sendFeedback:(id)sender {
    [self.textView resignFirstResponder];

    WebService *webService = [WebService newWithWebServiceAction:@"Feedback" andDelegate:self];
    webService.tag = 0;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"POST" andValue:@"feedback/add"];
    WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"token" andValue:[defaults objectForKey:MAIN_USER_TOKEN]];
    WebServiceParameter *parameter3 = [WebServiceParameter newWithKey:@"imei" andValue:[defaults objectForKey:@"binnumber"]];
    WebServiceParameter *parameter4 = [WebServiceParameter newWithKey:@"content" andValue:self.textView.text];
    
    NSArray *parameter = @[parameter1, parameter2,parameter3,parameter4];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"FeedbackResult"];
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
            
            if(code == 1){
                self.textView.text = @"";
                self.label.text = @"请在这里输入文字...";
                [OMGToast showWithText:NSLocalizedString(@"send_success", nil) bottomOffset:50 duration:2];

            }else{
                [OMGToast showWithText:NSLocalizedString(@"send_fail", nil) bottomOffset:50 duration:2];
            }
//            [OMGToast showWithText:NSLocalizedString([object objectForKey:@"Message"], nil)  bottomOffset:50 duration:2];
//
        }
    }
}

- (void)WebServiceGetError:(id)theWebService error:(NSString *)theError{
    [OMGToast showWithText:NSLocalizedString(@"waring_internet_error", nil) bottomOffset:50 duration:3];
}

-(void)textViewDidChange:(UITextView *)textView
{
    if(textView.text.length == 0)
    {
        self.label.text = @"请在这里输入文字...";
    }
    else
    {
        self.label.text = @"";
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = NO;
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
