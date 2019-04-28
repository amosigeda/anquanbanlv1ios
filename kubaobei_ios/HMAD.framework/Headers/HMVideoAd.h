//
//  HMVideoAd.h
//  HMAD
//
//  Created by hm on 2017/9/15.
//  Copyright © 2017年 hm. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HMVideoAdDelegate <NSObject>

/**
 *  video广告资源加载成功回调
 *
 */
-(void)onHMVideoAdLoaded;

/**
 *  video广告开始播放
 *
 */
-(void)onHMVideoAdStart;

/**
 *  video广告播放结束
 *
 */
-(void)onHMVideoAdDone;

/**
 *  video广告点击回调
 *
 */
-(void)onHMVideoAdClicked;

/**
 *  video广告关闭回调
 *
 */
-(void)onHMVideoAdClosed;

/**
 *  video广告请求失败回调
 *
 */
-(void)onHMVideoAdFailToLoad:(NSError *)error;

/**
 *  打开落地页后被关闭回调
 *
 */
-(void)onHMVideoAdLandingClosed;

@end

@interface HMVideoAd : NSObject

/**
 * 事件通知delegate
 *
 */
@property(nonatomic,weak) id<HMVideoAdDelegate> delegate;

/**
 * 请求超时时长(单位秒,默认为30秒)
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
 *  通过spaceId触发广告请求
 *
 */
- (void)loadAd:(NSString *)spaceId;

-(void)showAd;


@end
