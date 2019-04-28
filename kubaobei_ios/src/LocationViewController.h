//
//  LocationViewController.h
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
@interface LocationViewController : UIViewController
@property (weak, nonatomic) IBOutlet MKMapView *mapVIew;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *LocationTypeImage;
@property (weak, nonatomic) IBOutlet UIButton *mapType;
@property (weak, nonatomic) IBOutlet UIButton *zoomOut;
@property (weak, nonatomic) IBOutlet UIButton *zoomIn;
@property (weak, nonatomic) IBOutlet UIButton *refreshBtn;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
