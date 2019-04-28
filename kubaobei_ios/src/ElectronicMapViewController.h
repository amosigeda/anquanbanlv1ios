//
//  ElectronicMapViewController.h
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
@interface ElectronicMapViewController : UIViewController
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *radiusLabel;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextView;
@property (weak, nonatomic) IBOutlet UISwitch *swip1;
@property (weak, nonatomic) IBOutlet UISwitch *swip2;
@property (nonatomic,strong)NSDictionary *dic;
@property (weak, nonatomic) IBOutlet UISwitch *swip3;
@property (weak, nonatomic) IBOutlet UIButton *delebtn;
@property (weak, nonatomic) IBOutlet UILabel *fence_label;
@property (weak, nonatomic) IBOutlet UILabel *in_fence_Label;
@property (weak, nonatomic) IBOutlet UILabel *out_fence_Label;
@property (weak, nonatomic) IBOutlet UIButton *cancel_Btn;
@property (weak, nonatomic) IBOutlet UILabel *fence_switch_Label;
@property (weak, nonatomic) IBOutlet UIButton *comfire_Btn;
@property (weak, nonatomic) IBOutlet UIButton *del_btn;
@property (weak, nonatomic) IBOutlet UIButton *cancel_btn;
@property (weak, nonatomic) IBOutlet UIButton *submit_btn;
@property (weak, nonatomic) IBOutlet UILabel *fence_name_Label;
@property (weak, nonatomic) IBOutlet UILabel *alarm_mode_Label;

@end
