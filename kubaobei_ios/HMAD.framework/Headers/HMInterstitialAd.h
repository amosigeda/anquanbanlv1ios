//
//  HMInterstitialAd.h
//  HMAD
//
//  Created by hm on 17/8/1.
//  Copyright © 2017年 hm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol HMInterstitialAdDelegate <NSObject>

/**
 *  interstitial广告资源加载成功回调
 *
 */
-(void)onHMInterstitialAdLoaded;

/**
 *  interstitial广告请求失败回调
 *
 */
-(void)onHMInterstitialAdFailed:(NSError *)error;

/**
 *  interstitial广告展示成功回调
 *
 */
-(void)onHMInterstitialAdExposure;

/**
 *  interstitial广告点击回调
 *
 */
-(void)onHMInterstitialAdClicked;

/**
 *  interstitial广告关闭回调
 *
 */
-(void)onHMInterstitialAdClosed;

/**
 *  interstitial广告落地页被关闭回调
 *
 */
-(void)onHMInterstitialAdLandingClosed;

@end

@interface HMInterstitialAd : UIView

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
 *
 */
@property(nonatomic,weak) id<HMInterstitialAdDelegate> delegate;

/**
 * 请求超时时长
 *
 */
@property(nonatomic, assign) NSInteger fetchDelay;

/**
 *  插屏广告预加载是否完成
 *
 */
@property (nonatomic) BOOL isReady;

/**
 * 是否播放开屏动画
 *
 */
@property(nonatomic, assign) BOOL animated;

/**
 *  注册插屏广告
 *
 */
+ (instancetype)newInstance;

/**
 *  通过spaceId加载插屏广告
 *
 *  @param spaceId spaceId
 */
- (void)loadAd:(NSString *)spaceId;

/**
 *  展示插屏广告
 *
 */
-(void)showAd;

@end

