//
//  HMNativeAdData.h
//  HMAD
//
//  Created by hm on 2017/6/21.
//  Copyright © 2017年 HM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMNativeAdImg.h"

@interface HMNativeAdData : NSObject

/*
 * 初始化原生广告数据对象
 *
 * @param adData
 *
 */
- (instancetype)initWithAdData:(NSDictionary *)adData spaceId:(NSString *)spaceId;

@property(nonatomic,strong, readonly)NSString *spaceId;
@property(nonatomic,retain, readonly)NSDictionary *adData;
@property(nonatomic, assign) BOOL impressed;//是否已曝光过
@property(nonatomic, assign) BOOL dpclicked;//deeplink是否已被点击过


/**
 * 素材模版类型 template （ 401  402  403 ）
 */
-(NSString *)getHMNativeAdTemplate;

/**
 * 根据标签获取图片对象
 *
 *  @param label img标签
 *
 */
-(HMNativeAdImg *)getHMNativeAdImgByLabel:(NSString *)label;

/**
 * 根据标签获取文本内容
 *
 *  @param label txt标签
 *
 */
-(NSString *)getHMNativeAdTextByLabel:(NSString *)label;

/**
 * 根据标签获取视频url
 *
 *  @param label txt标签
 *
 */
-(NSString *)getHMNativeAdVideoUrlByLabel:(NSString *)label;

/**
 * 根据标签获取视频label
 *
 *  @param label txt标签
 *
 */
-(NSString *)getHMNativeAdVideoLabel:(NSString *)label;

/**
 * 获取广告素材(json格式,开发者可自行解析数据)
 *
 */
-(NSString *)getHMNativeAdAssets;

@end
