//
//  HomeTabViewController.m
//  KuBaoBei
//
//  Created by zhanshengshu on 2019/1/9.
//  Copyright © 2019年 HH. All rights reserved.
//

#import "HomeTabViewController.h"
#import "RDVTabBarController.h"
#import "RDVTabBarItem.h"
#import "HistoryViewController.h"
#import "PhotoViewController.h"
#import "HealthViewController.h"
#import "ElectronicViewController.h"
#import "BookViewController.h"
#import "WatchSetViewController.h"
#import "WatchSetAlarmViewController.h"
#import "AudioViewController.h"
#import "FlowersRewardViewController.h"
#import "MainMapViewController.h"
#import "EditHeadAndNameViewController.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "DeviceSetModel.h"
#import "DeviceModel.h"
#import "DataManager.h"
#import "Constants.h"
#import "JSON.h"
#import "OMGToast.h"
#import "NSString+Tools.h"
#import <CloudPushSDK/CloudPushSDK.h>
//#import <adsdk/RootADUIView.h>
#import "XTFNetWorkRequest.h"
#import "CommUtil.h"

@interface HomeTabViewController ()<UIAlertViewDelegate,WebServiceProtocol>
{
    DeviceSetModel *model;
    DeviceModel *deviceModel;
    NSUserDefaults *defaults;
    DataManager *manager;
    NSString *managerMobile;
}
@end

@implementation HomeTabViewController

static CGPoint touchPoint;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    defaults = [NSUserDefaults standardUserDefaults];
    [self initViews];
    managerMobile = [defaults objectForKey:MAIN_USER_PHONE];
    if(![CommUtil isNotBlank: managerMobile] || [managerMobile isEqualToString:@"0"]){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIAlertView *alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"home_add_manager_phone", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"remind_me_later", nil),NSLocalizedString(@"go", nil), nil];
            alerview.tag = 2;
            [alerview show];
        });
    }
    [CloudPushSDK bindAccount:[defaults objectForKey:MAIN_USER_TOKEN] withCallback:^(CloudPushCallbackResult *res) {
        if (res.success) {
            NSLog(@"bindAccount success");
        } else {
            NSLog(@"bindAccount failed, error: %@", res.error);
        }
    }];
    // Do any additional setup after loading the view from its nib.
    
    //HM广告sdk绑定
    NSString *spaceId=@"827";
    self.nativeAd=[HMNativeAd newInstance];
    self.nativeAd.delegate=self;
    [self.nativeAd loadAd:spaceId];
    
    /***
    //20190327---下面为测试-------------------------------
    NSArray *imgUrls = @[
                      @"https://ss1.baidu.com/9vo3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=7844b6536559252da3424e4452a63709/4b90f603738da97798afd262b551f8198718e3f3.jpg",
                      @"https://ss1.baidu.com/9vo3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=2fbe89b579d98d1076815f7147028c3c/f603918fa0ec08fa505e0cee5cee3d6d55fbda18.jpg",
                      @"https://ss1.baidu.com/9vo3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=e5d0477f18950a7b75601d846cec56eb/0ff41bd5ad6eddc4f802a8b23cdbb6fd53663395.jpg",
                      @"https://ss0.baidu.com/-Po3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=88b9154b8244ebf86d24377fbfc4e318/42a98226cffc1e17695ba0794f90f603728de996.jpg"];
    
    [self initBanner:nil withUrls:imgUrls];
    ***/
}


//native广告加载成功回调
-(void)onHMNativeAdSucessToLoad:(HMNativeAdData *)nativeAdData{
    NSLog(@"--banner--onHMNativeAdSucessToLoad----");
    
    if (nativeAdData!=nil) {
        NSString *url=[nativeAdData getHMNativeAdImgByLabel:@"ad"].url;
        self.nativeAdData=nativeAdData;
        
        //-----------------------2019-3-27-start--------------------------
        NSMutableArray *imgUrls=[[NSMutableArray alloc] init];
        NSString *adTemplate=[nativeAdData getHMNativeAdTemplate];
        if([adTemplate isEqualToString:@"401"] || [adTemplate isEqualToString:@"402"]){
            
            /***sdk 方解决不了，就直接显示404模板的
            @try {
                NSString *arr402Json=[nativeAdData getHMNativeAdAssets];
                arr402Json = [arr402Json stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                NSMutableArray  *array = [arr402Json componentsSeparatedByString:@","];
                for (NSInteger index=0; index<array.count; index++) {
                    NSDictionary *dic=[array objectAtIndex:index];
                    NSDictionary *img=dic[@"img"];
                    if (![img isKindOfClass:[NSNull class]]) {
                        NSString *url=img[@"url"];
                        [imgUrls addObject:url];
                    }
                    //NSLog(@"%@",img);
                }
            } @catch (NSException *exception) {
                NSLog(@"---banner----NSException-%@",exception);
            }
             **/
            
        }else if([adTemplate isEqualToString:@"404"]){
            NSString *url=[nativeAdData getHMNativeAdImgByLabel:@"ad"].url;
            [imgUrls addObject:url];
        }else{
            //视频等不处理
        }
        
        //初始化界面
        if (imgUrls!=nil && imgUrls.count>0) {
            [self initBanner:nativeAdData withUrls:imgUrls];
        }
    }
}


-(NSDictionary *)parseJSONStringToNSDictionary:(NSString *)JSONString {
    NSData *JSONData = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableLeaves error:nil];
    return responseJSON;
}

//打开落地页后被关闭回调
- (void)onHMNativeAdClosed {
    NSLog(@"--banner--onHMNativeAdClosed----");
}

//native广告请求失败回调
- (void)onHMNativeAdFailToLoad:(NSError *)error {
    NSLog(@"-----%@",error);
}

//拿到数据后展示
-(void) initBanner:(HMNativeAdData *)nativeAdData withUrls:(NSMutableArray*)urls{
    
    //上报展示
    [self.nativeAd attachAd:nativeAdData];
    
    // 网络加载 --- 创建带标题的图片轮播器
    int width=[UIScreen mainScreen].bounds.size.width;
    self.cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 20, width, 180) delegate:self placeholderImage:[UIImage imageNamed:@"placeholder"]];
    self.cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
    self.cycleScrollView.currentPageDotColor = [UIColor whiteColor]; // 自定义分页控件小圆标颜色
    
    // 添加手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapScreen:)];
    tap.delegate = self;
    [self.cycleScrollView addGestureRecognizer:tap];
    [self.bannerView addSubview:self.cycleScrollView];
    self.cycleScrollView.imageURLStringsGroup = urls;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    // 根据当前点击，获取坐标
    touchPoint= [touch locationInView:self.cycleScrollView];
    //NSLog(@"point.x ==%f point.y == %f", touchPoint.x, touchPoint.y);
    
    // 不响应手势
    if ([touch.view.superview isKindOfClass:NSClassFromString(@"SDCollectionViewCell")]) {
        return NO;
    }
    return YES;
}

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    NSLog(@"---点击了第%ld张图片,x=%f,y=%f,----w=%f,h=%f", (long)index,touchPoint.x,touchPoint.y,self.bannerView.bounds.size.width,self.bannerView.bounds.size.height);
    
    //dispatch_sync(dispatch_get_main_queue(), ^{//其实这个也是在子线程中执行的，只是把它放到了主线程的队列中
        //可以做点击处理
        if (self.nativeAd!=nil && self.nativeAdData!=nil) {
            [self.nativeAd clickAd:self.nativeAdData relativePoint:touchPoint nativeAdWH:self.bannerView.bounds.size];
        }
    //});
    
}

- (void)tapScreen:(UITapGestureRecognizer*)sender{
    //CGPoint tpoint = [sender locationInView:self.cycleScrollView];
    //NSLog(@"---x=%ld,y=%ld", tpoint.x,tpoint.y);
}

- (void)skipDismiss:(id)sender{
    [self dismiss];
}

- (void)dismiss{
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.rdv_tabBarController setTabBarHidden:NO animated:NO];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.rdv_tabBarController setTabBarHidden:YES animated:NO];
}

-(void)initViews{
    self.lbFunction.text = NSLocalizedString(@"function", nil);
    self.lbSet.text = NSLocalizedString(@"set", nil);
    self.lbFirst.text = NSLocalizedString(@"home_type17", nil);
    self.lbSecond.text = NSLocalizedString(@"home_type5", nil);
    self.lbThird.text = NSLocalizedString(@"home_type6", nil);
    self.lbFourth.text = NSLocalizedString(@"home_type7", nil);
    self.lbFifth.text = NSLocalizedString(@"home_type8", nil);
    self.lbSixth.text = NSLocalizedString(@"home_type9", nil);
    self.lbSeventh.text = NSLocalizedString(@"home_type11", nil);
    self.lbEighth.text = NSLocalizedString(@"home_type12", nil);
    self.lbNinth.text = NSLocalizedString(@"home_type18", nil);
    self.lbTenth.text = NSLocalizedString(@"home_type4", nil);
    self.lbEleventh.text = NSLocalizedString(@"home_type10", nil);
    self.lbTwelveth.text = NSLocalizedString(@"home_type14", nil);
}

-(IBAction)firstAction:(id)sender{
    PhotoViewController *photo = [[PhotoViewController alloc] init];
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"deviceModelType"] == 1){
        photo.title = NSLocalizedString(@"watch_album_d8", nil);
    }else{
        photo.title = NSLocalizedString(@"watch_album", nil);
    }
    [self.navigationController pushViewController:photo animated:YES];
}

-(IBAction)secondAction:(id)sender{
    AudioViewController *audio = [[AudioViewController alloc] init];
    [self.navigationController pushViewController:audio animated:YES];
}

-(IBAction)thirdAction:(id)sender{
    MainMapViewController *mainMapController = [[MainMapViewController alloc] init];
    mainMapController.title = NSLocalizedString(@"main_title", nil);
    [self.navigationController pushViewController:mainMapController animated:YES];
}

-(IBAction)fourthAction:(id)sender{
    HistoryViewController *history = [[HistoryViewController alloc] init];
    history.title = NSLocalizedString(@"history_track", nil);
    [self.navigationController pushViewController:history animated:YES];
}

-(IBAction)fifthAction:(id)sender{
    HealthViewController *health = [[HealthViewController alloc] init];
    health.title = NSLocalizedString(@"health_management", nil);
    [self.navigationController pushViewController:health animated:YES];
}

-(IBAction)sixthAction:(id)sender{
    ElectronicViewController *weilanm = [[ElectronicViewController alloc] init];
    weilanm.title = NSLocalizedString(@"fence", nil);
    [self.navigationController pushViewController:weilanm animated:YES];
}

-(IBAction)seventhAction:(id)sender{
    UIAlertView *alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"sure_remote_shutdown", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
    alerview.tag = 1;
    [alerview show];
}

-(IBAction)eighthAction:(id)sender{
    UIAlertView *alerview;
    if ([deviceModel.DeviceType isEqualToString:@"2"]) {
        alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"sure_find_watch_d8", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil), NSLocalizedString(@"OK", nil), nil];
    } else {
        alerview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"sure_find_watch", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil), NSLocalizedString(@"OK", nil), nil];
    }
    alerview.tag = 0;
    [alerview show];
}

-(IBAction)ninthAction:(id)sender{
    WatchSetViewController *watch = [[WatchSetViewController alloc] init];
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"deviceModelType"] == 1){
        watch.title = NSLocalizedString(@"watch_setting_d8", nil);
    }else{
        watch.title = NSLocalizedString(@"watch_setting", nil);
    }
    [self.navigationController pushViewController:watch animated:YES];
}

-(IBAction)tenthAction:(id)sender{
    BookViewController *book = [[BookViewController alloc] init];
    book.title = NSLocalizedString(@"mail_list", nil);
    [self.navigationController pushViewController:book animated:YES];
}

-(IBAction)eleventhAction:(id)sender{
    FlowersRewardViewController *vc = [[FlowersRewardViewController alloc] init];
    vc.title = NSLocalizedString(@"red_flowers_reward", nil);
    [self.navigationController pushViewController:vc animated:YES];
}

-(IBAction)twelvethAction:(id)sender{
    WatchSetAlarmViewController *vc = [[WatchSetAlarmViewController alloc] init];
    vc.title = NSLocalizedString(@"clock_setting", nil);
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        if (alertView.tag == 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                WebService *webService = [WebService newWithWebServiceAction:@"SendDeviceCommand" andDelegate:self];
                webService.tag = 0;
                WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"GET" andValue:[NSString stringWithFormat:@"controllerDevice/find/%@/%@",[defaults objectForKey:MAIN_USER_TOKEN],[defaults objectForKey:@"binnumber"]]];
                NSArray *parameter = @[parameter1];
                // webservice请求并获得结
                
                webService.webServiceParameter = parameter;
                [webService getWebServiceResult:@"SendDeviceCommandResult"];
            });
        } else if (alertView.tag == 1) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                WebService *webService = [WebService newWithWebServiceAction:@"SendDeviceCommand" andDelegate:self];
                webService.tag = 0;
                WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"GET" andValue:[NSString stringWithFormat:@"controllerDevice/poweroff/%@/%@",[defaults objectForKey:MAIN_USER_TOKEN],[defaults objectForKey:@"binnumber"]]];
                NSArray *parameter = @[parameter1];
                // webservice请求并获得结
                
                webService.webServiceParameter = parameter;
                [webService getWebServiceResult:@"SendDeviceCommandResult"];
            });
        }else if(alertView.tag == 2){
            [defaults setInteger:1 forKey:@"edit"];
            EditHeadAndNameViewController *vc = [[EditHeadAndNameViewController alloc] init];
//            vc.title = NSLocalizedString(@"edit_relat", nil);
            [defaults setInteger:10 forKey:@"editWatch"];
            [self.navigationController pushViewController:vc animated:YES];
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"watch_no", nil) message:NSLocalizedString(@"input_watch_no", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
//            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
//            [alertView textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
//            alertView.tag = 3;
//            [alertView show];
        }else if(alertView.tag == 3){
            if (![[alertView textFieldAtIndex:0].text isValidateMobile:[alertView textFieldAtIndex:0].text]){
                [OMGToast showWithText:NSLocalizedString(@"input_right_no", nil) bottomOffset:50   duration:4];
            }else{
                managerMobile = [alertView textFieldAtIndex:0];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    WebService *webService = [WebService newWithWebServiceAction:@"UpdateManagerMobile" andDelegate:self];
                    webService.tag = 1;
                    WebServiceParameter *parameter1 = [WebServiceParameter newWithKey:@"GET" andValue:[NSString stringWithFormat:@"watchAppUser/updateAdminPhone/%@/%@/%@",[defaults objectForKey:MAIN_USER_TOKEN],[defaults objectForKey:@"binnumber"],[alertView textFieldAtIndex:0].text]];
                    NSArray *parameter = @[parameter1];
                    // webservice请求并获得结
                    
                    webService.webServiceParameter = parameter;
                    [webService getWebServiceResult:@"UpdateManagerMobileResult"];
                });
            }
        }
    }
}

- (void)WebServiceGetCompleted:(id)theWebService{
    WebService *ws = theWebService;
    if ([[theWebService soapResults] length] > 0) {
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        // 解析成json数据
        id object = [parser objectWithString:[theWebService soapResults] error:&error];
        if (!error && object) {
            // 获得状态
            int code = [[object objectForKey:@"Code"] intValue];
            if(ws.tag == 0){
                if(code == 1){
                    [OMGToast showWithText:NSLocalizedString(@"send_success", nil) bottomOffset:50 duration:3];
                }else if(code == 2){
                    [OMGToast showWithText:NSLocalizedString(@"send_error_from_device_offline_tips", nil) bottomOffset:50 duration:3];
                }else{
                    [OMGToast showWithText:NSLocalizedString(@"check_device_online_tips", nil) bottomOffset:50 duration:3];
                }
            }else if(ws.tag == 1){
                if(code == 1){
                    [defaults setObject:@"1" forKey:MAIN_USER_PHONE];
                    [OMGToast showWithText:NSLocalizedString(@"bind_suc", nil) bottomOffset:50 duration:3];
                }else{
                    [OMGToast showWithText:NSLocalizedString(@"bind_fail", nil) bottomOffset:50 duration:3];
                }
            }
        }
    }
}

- (void)WebServiceGetError:(id)theWebService error:(NSString *)theError{
    [OMGToast showWithText:NSLocalizedString(@"waring_internet_error", nil) bottomOffset:50 duration:3];
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
