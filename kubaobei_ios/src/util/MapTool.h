//
//  MapTool.h
//  xss
//
//  Created by wzh on 2017/8/14.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@class MapTool;
@interface MapTool : NSObject


+ (MapTool *)sharedMapTool;

/**
 调用三方导航
 
 @param coordinate 经纬度
 @param name 地图上显示的名字
 @param tager 当前控制器
 */
- (void)navigationActionWithCoordinate:(CLLocationCoordinate2D)coordinate WithENDName:(NSString *)name tager:(UIViewController *)tager;

//根据经纬度换算出直线距离
+(float)getDistance:(float)lat1 lng1:(float)lng1 lat2:(float)lat2 lng2:(float)lng2;

+(NSMutableArray*)getRange:(float)lon lat:(float)lat:(float)r;

@end
