//
//  EditPhoneViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "EditPhoneViewController.h"
#import "DataManager.h"
#import "DeviceModel.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "OMGToast.h"
@interface EditPhoneViewController ()<UITextFieldDelegate>
{
    NSUserDefaults *defaults;
    DataManager *manager;
    DeviceModel *model;
    int height;
    int keyboardHight;
}
@end

@implementation EditPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    self.saveBtn.backgroundColor = MCN_buttonColor;
    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];

    defaults = [NSUserDefaults standardUserDefaults];
    manager= [DataManager shareInstance];
    
    NSMutableArray *array = [manager isSelect:[defaults objectForKey:@"binnumber"]];
    model = [array objectAtIndex:0];
    
    self.yunyingshang.text = model.SmsNumber;
    self.huafei.text = model.SmsBalanceKey;
    self.liuliang.text = model.SmsFlowKey;
    
    self.huafei.delegate = self;
    self.liuliang.delegate = self;
    self.yunyingshang.delegate = self;
    
    height=self.view.frame.size.height;
    //使用NSNotificationCenter 鍵盤出現時
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWasShown:)
     
                                                 name:UIKeyboardDidShowNotification object:nil];
    //使用NSNotificationCenter 鍵盤隐藏時
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWillBeHidden:)
     
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    self.Operator_Label.text = NSLocalizedString(@"operator_number", nil);
    self.query_phone_Label.text = NSLocalizedString(@"fare_order", nil);
    self.quer_nstructions_Lable.text = NSLocalizedString(@"flow_order", nil);
    [self.saveBtn setTitle:NSLocalizedString(@"save", nil) forState:UIControlStateNormal];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    self.view.frame = CGRectMake(self.view.frame.origin.x, -35, self.view.frame.size.width,self.view.frame.size.height);
}

//当键盘隐藏的时候
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    self.view.frame =CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width,self.view.frame.size.height);
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


- (IBAction)save:(id)sender {
    
    [self.huafei resignFirstResponder];
    [self.yunyingshang resignFirstResponder];
    [self.liuliang resignFirstResponder];
    
    [defaults setObject:self.yunyingshang.text forKey:@"yunyingshang"];
    [defaults setObject:self.huafei.text forKey:@"huafei"];
    [defaults setObject:self.liuliang.text forKey:@"liuliang"];
    
    WebService *webService = [WebService newWithWebServiceAction:@"UpdateSmsOrder" andDelegate:self];
    webService.tag = 0;
    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
    WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"deviceId" andValue:model.DeviceID];
    WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"smsNumber" andValue:self.yunyingshang.text];
    WebServiceParameter *parameter4 = [WebServiceParameter newWithKey:@"smsBalanceKey" andValue:self.huafei.text];
    WebServiceParameter *loginParameter5 = [WebServiceParameter newWithKey:@"smsFlowKey" andValue:self.liuliang.text];
    NSArray *parameter = @[loginParameter1,parameter2,loginParameter3,parameter4,loginParameter5];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"UpdateSmsOrderResult"];
    
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
            if(code == 1)
            {
                [manager updataSQL:@"favourite_info" andType:@"SmsNumber" andValue:self.yunyingshang.text andBindle:[defaults objectForKey:@"binnumber"]];
                [manager updataSQL:@"favourite_info" andType:@"SmsBalanceKey" andValue:self.huafei.text andBindle:[defaults objectForKey:@"binnumber"]];
                [manager updataSQL:@"favourite_info" andType:@"SmsFlowKey" andValue:self.liuliang.text andBindle:[defaults objectForKey:@"binnumber"]];
                [OMGToast showWithText:NSLocalizedString(@"save_suc", nil) bottomOffset:50 duration:2];
                [self.navigationController popViewControllerAnimated:YES];

            }
        }
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
