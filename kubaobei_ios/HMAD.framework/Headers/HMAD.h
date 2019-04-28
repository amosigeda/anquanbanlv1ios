//
//  HMAD.h
//  HMAD
//
//  Created by hm on 2017/8/11.
//  Copyright © 2017年 hm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMBannerAd.h"
#import "HMInterstitialAd.h"
#import "HMSplashAd.h"
#import "HMNativeAd.h"
#import "HMNativeAdImg.h"
#import "HMNativeAdData.h"
#import "HMVideoAd.h"



/**
 *  建议在didFinishLaunchingWithOptions最初始位置初始化SDK
 *
 */
@interface HMAD : NSObject

/**
 *  广告请求网络类型(可进行组合，例如：HMRequestByWifi|HMRequestBy4G|HMRequestBy3G )
 *
 */
typedef NS_ENUM(NSInteger, HMRequestNetworkType) {
    /**
     * 任何网络状态下都可请求
     *
     */
    HMRequestByAny = 1 << 0,
    
    /**
     *  仅wifi情况下请求
     *
     */
    HMRequestByWifi = 1 << 1,
    
    /**
     *  仅2g情况下请求
     *
     */
    HMRequestBy2G = 1 << 2,
    
    /**
     *  仅3g情况下请求
     *
     */
    HMRequestBy3G = 1 << 3,
    
    /**
     *  仅4g情况下请求
     *
     */
    HMRequestBy4G = 1 << 4,
};

/**
 * 落地页标题
 */
@property(nonatomic, strong) NSString *landingTitle;
/**
 * 落地页标题颜色
 */
@property(nonatomic, strong) UIColor *landingTitleColor;
/**
 * 落地页NavigationBar背景色
 */
@property(nonatomic, strong) UIColor *landingNavigationBarColor;
/**
 * 落地页返回按钮文字(如果设置了图标，将替换为图标)
 */
@property(nonatomic, strong) NSString *landingBackText;
/**
 * 落地页返回按钮图标
 */
@property(nonatomic, retain) UIImage *landingBackImage;
/**
 * 落地页返回按钮图标颜色
 */
@property(nonatomic, retain) UIColor *landingBackImageColor;
/**
 * 落地页动画(默认打开)
 */
@property(nonatomic, assign) BOOL ladingAnimated;

/**
 * 指定网络下请求广告（默认任何网络）
 *
 */
@property(nonatomic ,assign) HMRequestNetworkType requestNetworkType;

/**
 * debug日志开关（默认关闭）
 *
 */
@property(nonatomic, assign) BOOL debug;

@property(nonatomic, copy) NSString *appId;
@property(nonatomic, copy) NSString *secretKey;

/**
 *  注册HMAD
 *
 *  @param appId appId
 *  @param secretKey secretKey
 */
+(instancetype) regWithAppId:(NSString*)appId secretKey:(NSString *)secretKey;

+(instancetype)getHMAd;

//Get SDK Version.
+(NSString*)getSDKVersion;

+(void)cleanCache;

 
@end
