//
//  CenterViewController.h
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MapTool.h"

@interface CenterViewController : UIViewController<CLLocationManagerDelegate,MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *audioBtn;
@property (weak, nonatomic) IBOutlet UIImageView *headView;
@property (weak, nonatomic) IBOutlet UIImageView *batImage;
@property (weak, nonatomic) IBOutlet UIImageView *typeImage;
@property (weak, nonatomic) IBOutlet UIImageView *cirCleImage;
@property (weak, nonatomic) IBOutlet UIButton *locationBtn;
@property (weak, nonatomic) IBOutlet UILabel *second_label;
@property (weak, nonatomic) IBOutlet UILabel *shouhu_label;
@property (weak, nonatomic) IBOutlet UILabel *weilliao_Label;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *mapTypeBtn;
@property (weak, nonatomic) IBOutlet UIButton *photo_btn;
@property (weak, nonatomic) IBOutlet UIButton *shouhuBtn;
@property (weak, nonatomic) IBOutlet UIImageView *cirbgImage;
enum {
    // iPhone 1,3,3GS 标准分辨率(320x480px)
    UIDevice_iPhone3     = 1,
    // iPhone 4,4S 高清分辨率(640x960px)
    UIDevice_iPhone4s           = 2,
    // iPhone 5 高清分辨率(640x1136px)
    UIDevice_iPhone5     = 3,
    // iPhone 6 高清分辨率(750x1334px)
    UIDevice_iPhone6      = 4,
    // iPhone 6 plus 高清分辨率(1242x2208px)
    UIDevice_iPhone6_plus     = 5,
    // iPad 1,2 标准分辨率(1024x768px)
    UIDevice_iPadStandardRes        = 6,
    // iPad 3 High Resolution(2048x1536px)
    UIDevice_iPadHiRes              = 7
}; typedef NSUInteger UIDeviceResolution;
@end
