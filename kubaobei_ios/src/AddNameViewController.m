//
//  AddNameViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//
#import "NSString+Tools.h"
#import "CommUtil.h"
#import "DXAlertView.h"
#import "AddNameViewController.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "OMGToast.h"
#import "DataManager.h"
#import "DeviceModel.h"
#import "ContactModel.h"
#import "BookViewController.h"
#import "LoginViewController.h"
#import "UserModel.h"
#import "CenterViewController.h"
#import "WWSideslipViewController.h"
#import "ContactsTool.h"
#import "AddressBookModel.h"

@interface AddNameViewController ()<UITextFieldDelegate>
{
    UserModel* model;
    NSUserDefaults *defaluts;
    ContactModel *conModel;
    DeviceModel *deviceModel;
    
    NSMutableArray *deviceArray;
    NSMutableArray *conArray;
    DataManager *manager;
    
}
@property(nonatomic, strong) ContactsTool *contactsTool;
@end

@implementation AddNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    model = [UserModel sharedUserInstance];
    defaluts = [NSUserDefaults standardUserDefaults];
    self.navigationController.navigationBar.barTintColor = MCN_buttonColor;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    self.saveButton.backgroundColor = MCN_buttonColor;
    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    if([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    
    self.contactLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"contact", nil),[defaluts objectForKey:@"Chenghu"]];
    
    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];
    
    manager = [DataManager shareInstance];
    
    deviceArray =  [manager isSelect:[defaluts objectForKey:@"binnumber"]];
    deviceModel = [deviceArray objectAtIndex:0];
    
    conArray = [manager isSelectContactTable:[defaluts objectForKey:@"binnumber"]];
    int t = [defaluts integerForKey:@"edit"];
    if([defaluts integerForKey:@"edit"] == 0)
    {
        conModel = [conArray objectAtIndex:[defaluts integerForKey:@"selectIndex"]];
    }
    self.phoneLabel.delegate = self;
    self.phoneshortLabel.delegate = self;
    
    self.phoneLabel.placeholder = NSLocalizedString(@"contact_num", nil);
    self.phoneshortLabel.placeholder = NSLocalizedString(@"contact_family", nil);
    self.phoneLabel.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneshortLabel.keyboardType = UIKeyboardTypeNumberPad;
    
    [self.saveButton setTitle:NSLocalizedString(@"save", nil ) forState:UIControlStateNormal];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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

- (BOOL)isPureInt:(NSString *)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

- (IBAction)saveButton:(id)sender {
    
    [self.phoneLabel resignFirstResponder];
    [self.phoneshortLabel resignFirstResponder];
    
    
    //    if(self.phoneLabel.text.length == 0)
    //    {
    //        [OMGToast showWithText:NSLocalizedString(@"watch_number_null", nil) bottomOffset:50 duration:2];
    //        return;
    //    }
    if (![self.phoneLabel.text isValidateMobile:self.phoneLabel.text]) {
        [OMGToast showWithText:NSLocalizedString(@"input_right_no", nil) bottomOffset:50 duration:2];
        return;
    }
    //    if (![self.phoneshortLabel.text isValidateMobile:self.phoneshortLabel.text]) {
    //        [OMGToast showWithText:NSLocalizedString(@"input_right_no", nil) bottomOffset:50 duration:2];
    //        return;
    //    }
    WebService *webService = [WebService newWithWebServiceAction:@"AddContact" andDelegate:self];
    webService.tag = 0;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"POST" andValue:@"phonebook/addfriend"];
    WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"token" andValue:[defaluts objectForKey:MAIN_USER_TOKEN]];
    WebServiceParameter *parameter3 = [WebServiceParameter newWithKey:@"imei" andValue:[defaluts objectForKey:@"binnumber"]];
    WebServiceParameter *parameter4 = [WebServiceParameter newWithKey:@"name" andValue:[defaluts objectForKey:@"Chenghu"]];
    WebServiceParameter *parameter5 = [WebServiceParameter newWithKey:@"headtype" andValue:[NSString stringWithFormat:@"%ld",[defaluts integerForKey:@"headType"]]];
    WebServiceParameter *parameter6 = [WebServiceParameter newWithKey:@"phone" andValue:self.phoneLabel.text];
    WebServiceParameter *parameter7 = [WebServiceParameter newWithKey:@"cornet" andValue:self.phoneshortLabel.text];
    WebServiceParameter *parameter8;
    if([defaluts integerForKey:@"resignType"] == 10){
        parameter8 = [WebServiceParameter newWithKey:@"isadmin" andValue:@"1"];
    }else{
        parameter8 = [WebServiceParameter newWithKey:@"isadmin" andValue:@"0"];
    }
    NSArray *parameter = @[parameter1, parameter2, parameter3, parameter4, parameter5, parameter6, parameter7,parameter8];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"AddContactResult"];
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
            if(code == 1){
                //                if ([CommUtil isNotBlank:self.bindNumber]) {
                //
                //
                //                    WWSideslipViewController *vc = [[WWSideslipViewController alloc] init];
                //                    vc.title = NSLocalizedString(@"mail_list", nil);
                //                    for (UIViewController *controller in self.navigationController.viewControllers) {
                //                        if ([controller isKindOfClass:[vc class]]) {
                //                            [self.navigationController popToViewController:controller animated:YES];
                //                        }
                //                    }
                //                }
                if(ws.tag == 0){
                    if([defaluts integerForKey:@"resignType"] == 10){
                        [defaluts setObject:self.phoneLabel.text forKey:MAIN_USER_PHONE];
                    }
                    [self getBabyList];
                }else if(ws.tag == 1){
                    NSArray *array = [object objectForKey:@"ContactArr"];
                    [manager removeContactTable:deviceModel.BindNumber];
                    
                    for(int i = 0; i<array.count;i++)
                    {
                        [manager addContactTable:deviceModel.BindNumber andDeviceContactId:[[array objectAtIndex:i] objectForKey:@"DeviceContactId"] andRelationship:[[array objectAtIndex:i] objectForKey:@"Relationship"]  andPhoto:[[array objectAtIndex:i] objectForKey:@"Photo"] andPhoneNumber:[[array objectAtIndex:i] objectForKey:@"PhoneNumber"]  andPhoneShort:[[array objectAtIndex:i] objectForKey:@"PhoneShort"] andType:[[array objectAtIndex:i] objectForKey:@"Type"]andObjectId:[[array objectAtIndex:i] objectForKey:@"ObjectId"] andHeadImg:[[array objectAtIndex:i] objectForKey:@"HeadImg"]];
                        
                    }
                    if([defaluts integerForKey:@"resignType"] == 10){
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }else{
                        for (UIViewController *controller in self.navigationController.viewControllers) {
                            if ([controller isKindOfClass:[BookViewController class]]) {
                                [self.navigationController popToViewController:controller animated:YES];
                                return;
                            }
                        }
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }
            }else if(ws.tag == 0){
                if(code == 2){
                    [OMGToast showWithText:NSLocalizedString(@"send_error_from_device_offline_tips", nil) bottomOffset:50 duration:3];
                }else{
                    [OMGToast showWithText:NSLocalizedString(@"check_device_online_tips", nil) bottomOffset:50 duration:3];
                }
            }
        }
    }
}

- (void)WebServiceGetError:(id)theWebService error:(NSString *)theError{
    [OMGToast showWithText:NSLocalizedString(@"waring_internet_error", nil) bottomOffset:50 duration:3];
}

- (void)getBabyList
{
    WebService *webService = [WebService newWithWebServiceAction:@"GetDeviceContact" andDelegate:self];
    webService.tag = 1;
    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"GET" andValue:[NSString stringWithFormat:@"phonebook/getPhoneBookList/%@/%@",[defaluts objectForKey:MAIN_USER_TOKEN],[defaluts objectForKey:@"binnumber"]]];
    NSArray *parameter = @[parameter1];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"GetDeviceContactResult"];
    
}

- (void)setviewinfo
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
- (IBAction)addressBook:(id)sender
{
    // 弹出页面选择条联系人信息
    self.contactsTool = [[ContactsTool alloc] init];
    __weak typeof(self) weakSelf = self;
    [self.contactsTool getOnePhoneInfoWithUI:self callBack:^(AddressBookModel *contactModel) {
        NSLog(@"-----------");
        NSLog(@"%@", contactModel.name);
        NSLog(@"%@", contactModel.phoneNum);
        if([contactModel.phoneNum rangeOfString:@"-"].location !=NSNotFound)//_roaldSearchText
        {
            NSLog(@"yes");
            contactModel.phoneNum = [contactModel.phoneNum stringByReplacingOccurrencesOfString:@"-" withString:@""];
        }
        weakSelf.phoneLabel.text = contactModel.phoneNum;
    }];
}

- (IBAction)pushAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
@end
