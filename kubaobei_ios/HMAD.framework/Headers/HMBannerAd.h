//
//  HMBannerAd.h
//  HMAD
//
//  Created by hm on 2017/7/19.
//  Copyright © 2017年 hm. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HMBannerAdDelegate <NSObject>

/**
 *  banner广告请求失败回调
 *
 */
-(void)onHMBannerAdFailedToLoad:(NSError *)error;

/**
 *  banner广告展示回调
 *
 */
-(void)onHMBannerAdExposure;

/**
 *  banner广告点击回调
 *
 */
-(void)onHMBannerAdClicked;

/**
 *  banner广告关闭回调
 *
 */
-(void)onHMBannerAdClosed;

/**
 *  banner广告落地页被关闭回调
 *
 */
-(void)onHMBannerAdLandingClosed;

@end

@interface HMBannerAd : UIView
//点击之后导航栏设置
/** 导航栏背景颜色或者背景图片 */
@property (nonatomic, strong) UIImage *navBackgroundImage;

/** 导航栏按钮颜色 */
@property (nonatomic, strong) UIColor *navButtonTitleColor;

/** 导航栏标题大小 */
@property (nonatomic, assign) NSInteger fontNum;

/** 导航栏标题颜色 */
@property (nonatomic, strong) UIColor *navTitleColor;

/**
 *  banner推荐尺寸,开发者在嵌入Banner条时，可以手动设置Banner条的宽度用来满足场景需求，
 *  而高度的话不建议更改，否则显示效果会有影响
 */
#define HM_AD_320x50    CGSizeMake(320, 50) //For iPhone
#define HM_AD_SIZE_468x60    CGSizeMake(468, 60) //For iPad
#define HM_AD_SIZE_728x90    CGSizeMake(728, 90) //For iPad

/**
 * 事件通知delegate
 *
 */
@property(nonatomic,weak) id<HMBannerAdDelegate> delegate;

/**
 *  父视图
 *  详解：[必选]需设置为显示广告的UIViewController
 */
@property (nonatomic, weak) UIViewController *currentViewController;

/**
 * 请求超时时长(单位秒,默认为5秒)
 */
@property(nonatomic, assign) NSInteger fetchDelay;

/**
 * 广告刷新周期(单位秒,默认为30秒)
 */
@property (nonatomic,assign) NSInteger refreshInterval;

/**
 * 是否开启自动刷新广告(默认开启)
 */
@property(nonatomic, assign) BOOL autoRefresh;

/**
 * Banner条展示关闭按钮(默认展示)
 */
@property(nonatomic, assign) BOOL showCloseBtn;

/**
 * 是否播放开屏动画(默认关闭)
 *
 */
@property(nonatomic, assign) BOOL animated;

/**
 * 用户的标签
 *
 */
@property(nonatomic, strong) NSMutableArray *tags;

/**
 *  初始化banner
 *
 *  @param frame 广告banner展示的位置和大小，包含四个参数(x, y, width, height)
 *
 */
+ (instancetype) initWithFrame:(CGRect)frame;

/**
 *  通过spaceId加载banner广告
 */
-(void)loadAd:(NSString *)spaceId;

@end
