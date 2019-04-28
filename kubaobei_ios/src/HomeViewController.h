//
//  HomeViewController.h
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@interface HomeViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UILabel *adressLabel;
@property (weak, nonatomic) IBOutlet UIButton *mapButton;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property(nonatomic,assign)BOOL isPosition;
@property(nonatomic,assign) CLLocationCoordinate2D myLocation;
@property(nonatomic,strong)NSString* la;
@end
