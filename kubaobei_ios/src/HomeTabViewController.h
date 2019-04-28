//
//  HomeTabViewController.h
//  KuBaoBei
//
//  Created by zhanshengshu on 2019/1/9.
//  Copyright © 2019年 HH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMAD/HMNativeAd.h"
#import "SDCycleScrollView.h"

@interface HomeTabViewController : UIViewController<HMNativeAdDelegate,SDCycleScrollViewDelegate,UIGestureRecognizerDelegate>

@property (strong, nonatomic) HMNativeAd *nativeAd;
@property (strong, nonatomic) HMNativeAdData *nativeAdData;
@property UIImageView *adImageView;
@property SDCycleScrollView *cycleScrollView;

@property (weak, nonatomic) IBOutlet UILabel *lbFunction;
@property (weak, nonatomic) IBOutlet UILabel *lbSet;

@property (weak, nonatomic) IBOutlet UILabel *lbFirst;
@property (weak, nonatomic) IBOutlet UILabel *lbSecond;
@property (weak, nonatomic) IBOutlet UILabel *lbThird;
@property (weak, nonatomic) IBOutlet UILabel *lbFourth;
@property (weak, nonatomic) IBOutlet UILabel *lbFifth;
@property (weak, nonatomic) IBOutlet UILabel *lbSixth;
@property (weak, nonatomic) IBOutlet UILabel *lbSeventh;
@property (weak, nonatomic) IBOutlet UILabel *lbEighth;
@property (weak, nonatomic) IBOutlet UILabel *lbNinth;
@property (weak, nonatomic) IBOutlet UILabel *lbTenth;
@property (weak, nonatomic) IBOutlet UILabel *lbEleventh;
@property (weak, nonatomic) IBOutlet UILabel *lbTwelveth;
@property (weak, nonatomic) IBOutlet UIView *bannerView;

- (IBAction)firstAction:(id)sender;
- (IBAction)secondAction:(id)sender;
- (IBAction)thirdAction:(id)sender;
- (IBAction)fourthAction:(id)sender;
- (IBAction)fifthAction:(id)sender;
- (IBAction)sixthAction:(id)sender;
- (IBAction)seventhAction:(id)sender;
- (IBAction)eighthAction:(id)sender;
- (IBAction)ninthAction:(id)sender;
- (IBAction)tenthAction:(id)sender;
- (IBAction)eleventhAction:(id)sender;
- (IBAction)twelvethAction:(id)sender;

@end
