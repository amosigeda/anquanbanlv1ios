//
//  MainMapViewController.h
//  KuBaoBei
//
//  Created by zhanshengshu on 2019/3/6.
//  Copyright © 2019年 HH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MapTool.h"

@interface MainMapViewController : UIViewController

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *locationBtn;
@property (weak, nonatomic) IBOutlet UIImageView *ivElectricity;
@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UILabel *lbLocationType;
@property (weak, nonatomic) IBOutlet UILabel *lbAddress;
@property (weak, nonatomic) IBOutlet UILabel *lbTime;
@property (weak, nonatomic) IBOutlet UILabel *lbAddWatch;
@property (weak, nonatomic) IBOutlet UILabel *lbChangeWatch;
@property (weak, nonatomic) IBOutlet UILabel *lbCall;
@property (weak, nonatomic) IBOutlet UILabel *lbStreetView;
@property (weak, nonatomic) IBOutlet UILabel *lbNavi;
@property (weak, nonatomic) IBOutlet UILabel *lbElectricity;
@property (weak, nonatomic) IBOutlet UILabel *lbCountDown;

- (IBAction)locationAction:(id)sender;
- (IBAction)findAction:(id)sender;
- (IBAction)watchAction:(id)sender;
- (IBAction)phoneAction:(id)sender;
- (IBAction)addWatchAction:(id)sender;
- (IBAction)changeWatchAction:(id)sender;
- (IBAction)callAction:(id)sender;
- (IBAction)streetViewAction:(id)sender;
- (IBAction)naviAction:(id)sender;
@end
