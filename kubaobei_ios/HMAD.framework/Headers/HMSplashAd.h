//
//  HMSplashAd.h
//  HMAD
//
//  Created by hm on 2017/6/12.
//  Copyright © 2017年 hm. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HMSplashAdDelegate <NSObject>

/**
 *  splash广告展示回调
 *
 */
-(void)onHMSplashAdExposure;

/**
 *  splash广告请求失败回调
 *
 */
-(void)onHMSplashAdFailed:(NSError *)error;

/**
 *  splash广告点击回调
 *
 */
-(void)onHMSplashAdClicked;

/**
 *  splash广告关闭回调
 *
 */
-(void)onHMSplashAdClosed;

@end

@interface HMSplashAd : NSObject


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
 * 用户的标签
 *
 */
@property(nonatomic, strong) NSMutableArray *tags;

/**
 * 事件通知delegate
 */
@property(nonatomic,assign) id<HMSplashAdDelegate> delegate;

/**
 * 请求超时时长(单位秒,默认为5秒)
 */
@property(nonatomic, assign) NSInteger fetchDelay;

/**
 * 展示时长(单位秒,默认为5秒)
 */
@property (nonatomic, assign) NSInteger exposureDelay;

/**
 * 多少秒等于1秒(单位秒,默认为1)
 */
@property (nonatomic, assign) float countdownRatio;

/**
 * 跳过按钮缩放比(0.5-1)
 */
@property (nonatomic, assign) float zoomRatio;

/**
 * 是否播放开屏动画(默认关闭)
 *
 */
@property(nonatomic, assign) BOOL animated;

/**
 *  注册开屏广告
 *
 */
+(instancetype) newInstance;

/**
 *  广告发起请求并展示在默认Window中
 *
 *  @param spaceId 广告位
 */
- (void)requestAd:(NSString *)spaceId;

/**
 *  广告发起请求并展示在Window中, 同时在屏幕底部设置应用自身的Logo页面或是自定义View
 *  详解：[可选]发起拉取广告请求,并将获取的广告以半屏形式展示在传入的Window的上半部，剩余部分展示传入的bottomView
 *       请注意bottomView需设置好宽高，所占的空间不能过大，并保证广告界面的高度大于360
 *         bottomView 自定义底部View，可以在此View中设置应用Logo
 *
 *  @param bottomView 自定义底部View
 *  @param spaceId 广告位
 */
- (void) requestAdWithBottomView:(UIView *)bottomView spaceId:(NSString *)spaceId;

/**
 *  广告发起请求并展示在Window中
 *
 *  @param spaceId 广告位
 */
- (void)requestAd:(NSString *)spaceId AndShowInWindow:(UIWindow *)window;

/**
 *  广告发起请求并展示在Window中, 同时在屏幕底部设置应用自身的Logo页面或是自定义View
 *  详解：[可选]发起拉取广告请求,并将获取的广告以半屏形式展示在传入的Window的上半部，剩余部分展示传入的bottomView
 *       请注意bottomView需设置好宽高，所占的空间不能过大，并保证广告界面的高度大于360
 *         bottomView 自定义底部View，可以在此View中设置应用Logo
 *
 *  @param bottomView 自定义底部View
 *  @param spaceId 广告位
 *  @param window 展示全屏开屏的容器
 */
- (void) requestAdWithBottomView:(UIView *)bottomView spaceId:(NSString *)spaceId AndShowInWindow:(UIWindow *)window;

@end

