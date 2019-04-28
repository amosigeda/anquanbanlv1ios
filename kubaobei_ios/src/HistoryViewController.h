//
//  HistoryViewController.h
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "JTCalendar.h"

@interface HistoryViewController : UIViewController
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet JTCalendarMenuView *MouthView;
@property (weak, nonatomic) IBOutlet JTCalendarContentView *ContentView;
@property (weak, nonatomic) IBOutlet UIView *bottomBgView;
@property (weak, nonatomic) IBOutlet UIProgressView *uiProgress_index;
@property (weak, nonatomic) IBOutlet UISlider *uiSlider_Speed;
@property (weak, nonatomic) IBOutlet UIButton *mapType;
@property (weak, nonatomic) IBOutlet UIButton *startbtn;
@property (strong, nonatomic) JTCalendar *calendar;
@property (weak, nonatomic) IBOutlet UISwitch *gensuiSwitch;

@property (weak, nonatomic) IBOutlet UILabel *pross_Label;
@property (weak, nonatomic) IBOutlet UILabel *speed_Label;
@property (weak, nonatomic) IBOutlet UIButton *stop_Btn;
@property (weak, nonatomic) IBOutlet UIButton *follow_Btn;
@property (weak, nonatomic) IBOutlet UIButton *forward_Btn;
@property (weak, nonatomic) IBOutlet UIButton *back_Btn;
@property (weak, nonatomic) IBOutlet UIButton *hidelbs_Btn;
@property (weak, nonatomic) IBOutlet UISwitch *hidelbsSwitch;

@end
