//
//  MapTool.m
//  xss
//
//  Created by wzh on 2017/8/14.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "MapTool.h"
#define WEAKSELF     typeof(self) __weak weakSelf = self;
@implementation MapTool

+ (MapTool *)sharedMapTool{
    static MapTool *mapTool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mapTool = [[MapTool alloc] init];
    });
    return mapTool;
}

/**
 调用三方导航
 
 @param coordinate 经纬度
 @param name 地图上显示的名字
 @param tager 当前控制器
 */
- (void)navigationActionWithCoordinate:(CLLocationCoordinate2D)coordinate WithENDName:(NSString *)name tager:(UIViewController *)tager{
    
    WEAKSELF
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"苹果自带地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf appleNaiWithCoordinate:coordinate andWithMapTitle:name];
        
    }]];
    //判断是否安装了谷歌地图，如果安装了谷歌地图，则使用谷歌地图导航
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
        [alertController addAction:[UIAlertAction actionWithTitle:@"Google地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf googleNaviWithCoordinate:coordinate andWithMapTitle:name];
        }]];
    }
    //判断是否安装了高德地图，如果安装了高德地图，则使用高德地图导航
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
        [alertController addAction:[UIAlertAction actionWithTitle:@"高德地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf aNaviWithCoordinate:coordinate andWithMapTitle:name];
        }]];
    }
    //判断是否安装了百度地图，如果安装了百度地图，则使用百度地图导航
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
        [alertController addAction:[UIAlertAction actionWithTitle:@"百度地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf baiduNaviWithCoordinate:coordinate andWithMapTitle:name];
        }]];
    }
    //判断是否安装了腾讯地图，如果安装了腾讯地图，则使用腾讯地图导航
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"qqmap://"]]) {
        [alertController addAction:[UIAlertAction actionWithTitle:@"腾讯地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf tencentNaviWithCoordinate:coordinate andWithMapTitle:name];
        }]];
    }
    //添加取消选项
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    //显示alertController
    [tager presentViewController:alertController animated:YES completion:nil];
}

//唤醒苹果自带导航
- (void)appleNaiWithCoordinate:(CLLocationCoordinate2D)coordinate andWithMapTitle:(NSString *)map_title{
    
    MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
    MKMapItem *tolocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil]];
    tolocation.name = map_title;
    [MKMapItem openMapsWithItems:@[currentLocation,tolocation] launchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving,
                                                                               MKLaunchOptionsShowsTrafficKey:[NSNumber numberWithBool:YES]}];
}


/**
 高德导航
 */
- (void)aNaviWithCoordinate:(CLLocationCoordinate2D)coordinate andWithMapTitle:(NSString *)map_title{
    
    NSString *urlsting =[[NSString stringWithFormat:@"iosamap://navi?sourceApplication= &backScheme= &lat=%f&lon=%f&dev=0&style=2",coordinate.latitude,coordinate.longitude]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication  sharedApplication]openURL:[NSURL URLWithString:urlsting]];
    
}

- (void)baiduNaviWithCoordinate:(CLLocationCoordinate2D)coordinate andWithMapTitle:(NSString *)map_title{
    NSString *urlsting =[[NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=目的地&mode=driving&coord_type=gcj02",coordinate.latitude,coordinate.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlsting]];
    
}

- (void)googleNaviWithCoordinate:(CLLocationCoordinate2D)coordinate andWithMapTitle:(NSString *)map_title{
    NSString *urlsting = [[NSString stringWithFormat:@"comgooglemaps://?x-source=%@&x-success=%@&saddr=&daddr=%f,%f&directionsmode=driving",map_title,@"nav123456",coordinate.latitude, coordinate.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlsting]];
    
}

- (void)tencentNaviWithCoordinate:(CLLocationCoordinate2D)coordinate andWithMapTitle:(NSString *)map_title{
    NSString *urlsting = [[NSString stringWithFormat:@"qqmap://map/routeplan?from=我的位置&type=drive&tocoord=%f,%f&to=终点&coord_type=1&policy=0",coordinate.latitude, coordinate.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlsting]];
    
}

//根据经纬度换算出直线距离
+(float)getDistance:(float)lat1 lng1:(float)lng1 lat2:(float)lat2 lng2:(float)lng2{
    //地球半径
    int R = 6378137;
    //将角度转为弧度
    float radLat1 = (lat1*3.14159265)/180.0;
    float radLat2 = (lat2*3.14159265)/180.0;
    float radLng1 = (lng1*3.14159265)/180.0;
    float radLng2 = (lng2*3.14159265)/180.0;
    //结果
    float s = acos(cos(radLat1)*cos(radLat2)*cos(radLng1-radLng2)+sin(radLat1)*sin(radLat2))*R;
    //精度
    s = round(s* 10000)/10000;
    return  round(s);
}


static float DEF_PI=3.14159265359;
static float DEF_PI180=0.01745329252;
static float DEF_R=6370693.5;

+(NSMutableArray*)getRange:(float)lon lat:(float)lat:(float)r{
    NSMutableArray *range=[[NSMutableArray alloc] init];
    
    // 角度转换为弧度
    double ns = lat * DEF_PI180;
    
    double sinNs = sin(ns);
    double cosNs = cos(ns);
    double cosTmp = cos(r / DEF_R);
    // 经度的差值
    double lonDif = acos((cosTmp - sinNs * sinNs) / (cosNs * cosNs)) / DEF_PI180;
    // 保存经度
    [range insertObject:@(lon - lonDif) atIndex:0];
    [range insertObject:@(lon + lonDif) atIndex:1];
    //range[0] = lon - lonDif;
    //range[1] = lon + lonDif;
    double m = 0 - 2 * cosTmp * sinNs;
    double n = cosTmp * cosTmp - cosNs * cosNs;
    double o1 = (0 - m - sqrt(m * m - 4 * (n))) / 2;
    double o2 = (0 - m + sqrt(m * m - 4 * (n))) / 2;
    // 纬度
    double lat1 = 180 / DEF_PI * asin(o1);
    double lat2 = 180 / DEF_PI * asin(o2);
    // 保存
     [range insertObject:@(lat1) atIndex:2];
     [range insertObject:@(lat2) atIndex:3];
     //range[2] = lat1;
    //range[3] = lat2;
    return range;
}

@end
