//
//  PhotoLocationViewController.h
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface PhotoLocationViewController : UIViewController
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *address_Label;
@property (nonatomic,strong)NSString *address;
@property (nonatomic,strong)NSString *time;
@property (nonatomic,strong)NSString *image;
@property (nonatomic,strong)NSString *lat;
@property (nonatomic,strong)NSString *lng;
@property (nonatomic,strong)NSString *source;
@property (weak, nonatomic) IBOutlet UILabel *source_Label;
@property (weak, nonatomic) IBOutlet UILabel *time_Label;

@end
