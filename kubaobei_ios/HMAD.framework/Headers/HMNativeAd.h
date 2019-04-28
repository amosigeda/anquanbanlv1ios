//
//  HMNativeAd.h
//  HMAD
//
//  Created by hm on 2017/6/21.
//  Copyright © 2017年 hm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMNativeAdData.h"

@protocol HMNativeAdDelegate <NSObject>

/**
 *  native广告加载成功回调
 *
 */
-(void)onHMNativeAdSucessToLoad:(HMNativeAdData *)nativeAdData;

/**
 *  native广告请求失败回调
 *
 */
-(void)onHMNativeAdFailToLoad:(NSError *)error;

/**
 *  打开落地页后被关闭回调
 *
 */
-(void)onHMNativeAdClosed;

@end


/**
 *  信息流视频广告统计项
 *
 */
typedef NS_ENUM(NSInteger, HMNativeVideoType) {
    /**
     * 播放事件
     *
     */
    nativeViedoPlay,
    /**
     * 暂停事件
     *
     */
    nativeViedoPause,
    /**
     * 重新播放事件
     *
     */
    nativeViedoReplay,
    /**
     * 进入全屏播放事件
     *
     */
    nativeViedoFullscreen,
    /**
     * 退出全屏播放事件
     *
     */
    nativeViedoUnfullscreen,
    /**
     * 向上滑动事件
     *
     */
    nativeViedoScrollup,
    /**
     * 向下滑动事件
     *
     */
    nativeViedoScrolldown,
    /**
     * 播放进度事件，请在播放到25，50，75，100时上报
     *
     */
    nativeViedoPlaypercent,
    /**
     * 错误码  -1300：“videourl” 字段为空      -1303：视频播放失败
     * 统计错误类型的时候，请将错误码传error加上 其他统计可传nil
     */
    nativeViedoError
};

@interface HMNativeAd : NSObject


/** 导航栏背景颜色或者背景图片 */
@property (nonatomic, strong) UIImage *navBackgroundImage;

/** 导航栏按钮颜色 */
@property (nonatomic, strong) UIColor *navButtonTitleColor;

/** 导航栏标题大小 */
@property (nonatomic, assign) NSInteger fontNum;

/** 导航栏标题颜色 */
@property (nonatomic, strong) UIColor *navTitleColor;


/**
 * 视频界面各个按钮的点击事件统计类型
 *
 */
@property(nonatomic ,assign) HMNativeVideoType nativeVideoType;


/**
 * 事件通知delegate
 *
 */
@property(nonatomic,weak) id<HMNativeAdDelegate> delegate;

/**
 * 请求超时时长(单位秒,默认为5秒)
 * 
 */
@property(nonatomic, assign) NSInteger fetchDelay;
/**
 * 用户的标签
 *
 */
@property(nonatomic, strong) NSMutableArray *tags;

/**
 *  注册
 *
 */
+ (instancetype) newInstance;

/**
 *  通过spaceId加载广告
 *  @param spaceId spaceId
 */
-(void)loadAd:(NSString *)spaceId;

/**
 *  通过spaceId加载广告
 *
 *  @param spaceId spaceId  广告位
 *  @param currentController 用来弹出目标页的ViewController，一般为当前ViewController
 */
-(void)loadAd:(NSString *)spaceId inController:(UIViewController *)currentController;

/**
 *  视频播放事件统计方法
 *  @param percent 用来进行播放进度上报，videoType 为nativeViedoPlaypercent时，请填写percent字段（25，50，75，100），其他填写0
 */
-(void)clickNativeVideoAd:(HMNativeAdData *)nativeAdData nativeVideoType:(HMNativeVideoType)videoType playPercent:(NSInteger)percent error:(NSString*)errorCode;

/**
 *  曝光广告
 */
-(void)attachAd:(HMNativeAdData *)nativeAdData;

/**
 *  点击广告
 *  @param point 点击时，按下的坐标点x轴像素（广告左上角为原点，无法获取时请填写-999,Eg:CGPointMake(-999, -999)）
 *  @param nativeAdWH 广告位的宽和高
 */
-(void)clickAd:(HMNativeAdData *)nativeAdData relativePoint:(CGPoint)point nativeAdWH:(CGSize)nativeAdWH;

@end
