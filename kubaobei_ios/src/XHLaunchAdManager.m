//
//  XHLaunchAdManager.m
//  XHLaunchAdExample
//
//  Created by zhuxiaohui on 2017/5/3.
//  Copyright © 2017年 it7090.com. All rights reserved.
//  代码地址:https://github.com/CoderZhuXH/XHLaunchAd
//  开屏广告初始化

#import "XHLaunchAdManager.h"
#import "XHLaunchAd.h"
//#import "Network.h"
//#import "LaunchAdModel.h"
//#import "UIViewController+Nav.h"
//#import "WebViewController.h"

/** 以下连接供测试使用 */

/** 静态图 */
#define imageURL1 @"http://yun.it7090.com/image/XHLaunchAd/pic01.jpg"
#define imageURL2 @"http://yun.it7090.com/image/XHLaunchAd/pic02.jpg"
#define imageURL3 @"http://yun.it7090.com/image/XHLaunchAd/pic03.jpg"
#define imageURL4 @"http://yun.it7090.com/image/XHLaunchAd/pic04.jpg"

/** 动态图 */
#define imageURL5 @"http://yun.it7090.com/image/XHLaunchAd/pic05.gif"
#define imageURL6 @"http://yun.it7090.com/image/XHLaunchAd/pic06.gif"

/** 视频链接 */
#define videoURL1 @"http://yun.it7090.com/video/XHLaunchAd/video01.mp4"
#define videoURL2 @"http://yun.it7090.com/video/XHLaunchAd/video02.mp4"
#define videoURL3 @"http://yun.it7090.com/video/XHLaunchAd/video03.mp4"

@interface XHLaunchAdManager()<XHLaunchAdDelegate>

@end

@implementation XHLaunchAdManager

+(void)load{
    [self shareManager];
}

+(XHLaunchAdManager *)shareManager{
    static XHLaunchAdManager *instance = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken,^{
        instance = [[XHLaunchAdManager alloc] init];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        //在UIApplicationDidFinishLaunching时初始化开屏广告,做到对业务层无干扰,当然你也可以直接在AppDelegate didFinishLaunchingWithOptions方法中初始化
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            
            //2019-03-24屏蔽该方式使用闪屏页，切换到修改LaunchImage中实现
            //NSDictionary *infoAction = [[NSDictionary alloc] initWithObjectsAndKeys:@"4", @"adtype", @"400", @"adheight",@"824",@"spaceId",nil];
            //NSString *spaceId = @"824";
            ///RootADUIView * view = [[RootADUIView alloc] initWithSpaceId:spaceId withAdData:infoAction];
            //view.tag = 10000;
            //[[[UIApplication sharedApplication] keyWindow] addSubview:view];
            
            
            
            //初始化开屏广告
            //            [self setupXHLaunchAd];
        }];
    }
    return self;
}

-(void)setupXHLaunchAd{
    
    //1.******图片开屏广告 - 网络数据******
    //[self example01];
    
    //2.******图片开屏广告 - 本地数据******
    [self example02];
    
    //3.******视频开屏广告 - 网络数据(网络视频只支持缓存OK后下次显示,看效果请二次运行)******
    //[self example03];
    
    //4.******视频开屏广告 - 本地数据******
    //[self example04];
    
    //5.******如需自定义跳过按钮,请看这个示例******
    //[self example05];
    
    //6.******使用默认配置快速初始化,请看下面两个示例******
    //[self example06];//图片
    //[self example07];//视频
    
    //7.******如果你想提前缓存图片/视频请看下面两个示例*****
    //批量下载并缓存图片
    //[self batchDownloadImageAndCache];
    
    //批量下载并缓存视频
    //[self batchDownloadVideoAndCache];
    
}


#pragma mark - 图片开屏广告-本地数据-示例
//图片开屏广告 - 本地数据
-(void)example02{
    
    //设置你工程的启动页使用的是:LaunchImage 还是 LaunchScreen.storyboard(不设置默认:LaunchImage)
    [XHLaunchAd setLaunchSourceType:SourceTypeLaunchImage];
    
    //配置广告数据
    XHLaunchImageAdConfiguration *imageAdconfiguration = [XHLaunchImageAdConfiguration new];
    //广告停留时间
    imageAdconfiguration.duration = 5;
    //广告frame
    imageAdconfiguration.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    //广告图片URLString/或本地图片名(.jpg/.gif请带上后缀)
    imageAdconfiguration.imageNameOrURLString = @"comm_bg.gif";
    //设置GIF动图是否只循环播放一次(仅对动图设置有效)
    imageAdconfiguration.GIFImageCycleOnce = YES;
    //图片填充模式
    imageAdconfiguration.contentMode = UIViewContentModeScaleAspectFill;
    //广告点击打开页面参数(openModel可为NSString,模型,字典等任意类型)
    imageAdconfiguration.openModel = @"http://www.it7090.com";
    //广告显示完成动画
    imageAdconfiguration.showFinishAnimate =ShowFinishAnimateFlipFromLeft;
    //广告显示完成动画时间
    imageAdconfiguration.showFinishAnimateTime = 0.8;
    //跳过按钮类型
    imageAdconfiguration.skipButtonType = SkipTypeNone;
    //后台返回时,是否显示广告
    imageAdconfiguration.showEnterForeground = NO;
    //设置要添加的子视图(可选)
    //imageAdconfiguration.subViews = [self launchAdSubViews];
    //显示开屏广告
    [XHLaunchAd imageAdWithImageAdConfiguration:imageAdconfiguration delegate:self];
    
}
/**
 *  图片本地读取/或下载完成回调
 *
 *  @param launchAd  XHLaunchAd
 *  @param image 读取/下载的image
 *  @param imageData 读取/下载的imageData
 */
-(void)xhLaunchAd:(XHLaunchAd *)launchAd imageDownLoadFinish:(UIImage *)image imageData:(NSData *)imageData{
    NSLog(@"图片下载完成/或本地图片读取完成回调");
}

/**
 *  视频本地读取/或下载完成回调
 *
 *  @param launchAd XHLaunchAd
 *  @param pathURL  视频保存在本地的path
 */
-(void)xhLaunchAd:(XHLaunchAd *)launchAd videoDownLoadFinish:(NSURL *)pathURL{
    
    NSLog(@"video下载/加载完成/保存path = %@",pathURL.absoluteString);
}

/**
 *  视频下载进度回调
 */
-(void)xhLaunchAd:(XHLaunchAd *)launchAd videoDownLoadProgress:(float)progress total:(unsigned long long)total current:(unsigned long long)current{
    NSLog(@"总大小=%lld,已下载大小=%lld,下载进度=%f",total,current,progress);
    
}

/**
 *  广告显示完成
 */
-(void)xhLaunchAdShowFinish:(XHLaunchAd *)launchAd{
    
    NSLog(@"广告显示完成");
}



@end
