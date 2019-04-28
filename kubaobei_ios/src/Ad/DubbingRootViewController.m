//
//  DubbingRootViewController.m
//  DubbingMaster
//
//  Created by on 2019/3/8.
//  Copyright © 2019年 Damon. All rights reserved.
//

#import "DubbingRootViewController.h"
#import "XTFNetWorkRequest.h"
#import "AppDelegate.h"

@interface DubbingRootViewController (){
    //开屏
    //HMSplashAd *_splashAd;
}
//@property (nonatomic, strong) UIView *launchMask;
//@property (nonatomic, strong) LOTAnimationView *launchAnimation;
@end

@implementation DubbingRootViewController

  
- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    CGSize windowSize = [UIScreen mainScreen].bounds.size;
    
    NSArray *launchImagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    NSString *imgName = @"";
    
    for (NSDictionary *imgDic in launchImagesDict) {
        CGSize imgSize = CGSizeFromString([NSString stringWithFormat:@"%@",[imgDic objectForKey:@"UILaunchImageSize"]]);
        if (CGSizeEqualToSize(windowSize, imgSize)) {
            imgName = [imgDic objectForKey:@"UILaunchImageName"];
            break;
        }
        
    }
    //UIImageView *bgImage = [MethodsCommon createImageViewFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) imageName:imgName color:nil];
    //UIImageView *bgImage=
   
    
    //背景图
    UIImageView *bgImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, windowSize.width, windowSize.height)];
    bgImage.userInteractionEnabled = YES;
    bgImage.contentMode = UIViewContentModeScaleAspectFill;
    bgImage.clipsToBounds = YES;
    bgImage.image=[UIImage imageNamed:imgName];
    
    [self.view addSubview:bgImage];
    
    //开始请求
    [self initSplashAd];
    
}
//*************************    开屏广告      *******************************//

-(void)initSplashAd{
    
    NSString *spaceId=@"824";
    self.nativeAd=[HMNativeAd newInstance];
    self.nativeAd.delegate=self;
    [self.nativeAd loadAd:spaceId];
}


//native广告加载成功回调
-(void)onHMNativeAdSucessToLoad:(HMNativeAdData *)nativeAdData{
    NSLog(@"----onHMNativeAdSucessToLoad----");

    if (nativeAdData!=nil) {
        
        self.nativeAdData=nativeAdData;
        
        NSString *url=[nativeAdData getHMNativeAdImgByLabel:@"ad"].url;
        
        XTFNetWorkRequest *req = [[XTFNetWorkRequest alloc] init];
        req.interval = 5;
        
        if (url!=nil) {
            [req fetchWithUrlData:url httpMedthod:HMGET params:nil success:^(id responseObject, NSString * objectStr, NSInteger httpCode){
                
                if (responseObject!=nil) {
                    UIImage *uiImage=[UIImage imageWithData:responseObject];
                    if (uiImage==nil) {
                        [self errorToSwitchViewController];
                        return;
                    }
                    
                    int width=[[UIScreen mainScreen] bounds].size.width;
                    int height=[[UIScreen mainScreen] bounds].size.height;
                    
                    // 1.广告图片
                    self.adImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
                    self.adImageView.userInteractionEnabled = YES;
                    self.adImageView.contentMode = UIViewContentModeScaleAspectFill;
                    self.adImageView.clipsToBounds = YES;
                    
                    //为广告图片添加手势触摸
                    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapScreen:)];
                    [self.adImageView addGestureRecognizer:tap];
                    
                    self.adImageView.image=[UIImage imageWithData:responseObject];
                    
                    self.adImageView.contentMode=UIViewContentModeScaleToFill;
                    
                    self.count = 5;
                    //开始倒计时
                    [self startTimer];
                    
                    // 2.跳过按钮
                    self.countButton = [UIButton buttonWithType:UIButtonTypeSystem];
                    [self.countButton setTitle:[NSString stringWithFormat:@"跳过%ld",(long)self.count] forState:UIControlStateNormal];
                    
                    
                    self.countButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 84, 50, 60, 30);
                    [self.countButton addTarget:self action:@selector(skipDismiss:) forControlEvents:UIControlEventTouchUpInside];
                    
                    self.countButton.titleLabel.font = [UIFont systemFontOfSize:15];
                    [self.countButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    self.countButton.backgroundColor = [UIColor colorWithRed:38 /255.0 green:38 /255.0 blue:38 /255.0 alpha:0.6];
                    self.countButton.layer.cornerRadius = 4;
                    
                    [self.adImageView addSubview:self.countButton];
                    
                    [self.view addSubview:self.adImageView];
                    
                    
                    //上报展示
                    [self.nativeAd attachAd: self.nativeAdData];
                    
                }else{
                    [self errorToSwitchViewController];
                }
            } failure:^(NSError * _Nonnull error) {
                [self errorToSwitchViewController];
            }];
        }else{
            [self errorToSwitchViewController];
        }
    }else{
        //没有数据返回
         [self errorToSwitchViewController];
    }
}

//打开落地页后被关闭回调
- (void)onHMNativeAdClosed {
    
    //[(AppDelegate*)[[UIApplication sharedApplication]delegate] rootWindows];
    //NSLog(@"----onHMNativeAdClosed----");
    [self switchViewController];
}

//native广告请求失败回调
- (void)onHMNativeAdFailToLoad:(NSError *)error {
    //NSLog(@"-----%@",error);
    [self errorToSwitchViewController];
}

-(void) errorToSwitchViewController{
    self.count = 2;
    [self startTimer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


// 定时器倒计时
- (void)startTimer
{
    [[NSRunLoop mainRunLoop] addTimer:self.countTimer forMode:NSRunLoopCommonModes];
}

- (NSTimer *)countTimer
{
    if (!_countTimer) {
        _countTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    }
    return _countTimer;
}

- (void)countDown
{
    _count --;
    if (_countButton!=nil) {
         [_countButton setTitle:[NSString stringWithFormat:@"跳过%ld",(long)_count] forState:UIControlStateNormal];
    }
    if (_count <= 0) {
        
        [self switchViewController];
    }
}

- (void)tapScreen:(UITapGestureRecognizer*)sender{
    //取得所点击的点的坐标
    if (self.adImageView!=nil) {
        CGPoint point = [sender locationInView:self.adImageView];
        [self.nativeAd clickAd:self.nativeAdData relativePoint:point nativeAdWH:self.adImageView.bounds.size];
        
        //点击展示后暂停定时器
        [self stopTimeCountDown];
        
    }else{
         [self switchViewController];
    }
    
    //other?
}

- (void)skipDismiss:(id)sender{
    [self switchViewController];
}


-(void) stopTimeCountDown{
    if (self.countTimer!=nil) {
        [self.countTimer invalidate];
        self.countTimer = nil;
    }
}

-(void)switchViewController{
    
    if (self.countTimer!=nil) {
        [self.countTimer invalidate];
        self.countTimer = nil;
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        self.view.alpha=0;
    } completion:^(BOOL finished) {
        if (self.adImageView!=nil) {
            [self.adImageView removeFromSuperview];
        }
    }];
    
    // 移除广告页面,跳转到根控制器页
    [(AppDelegate*)[[UIApplication sharedApplication]delegate] rootWindows];
}


@end
