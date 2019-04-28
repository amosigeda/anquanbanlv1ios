//
//  DubbingRootViewController.h
//  DubbingMaster
//
//  Created by  on 2019/3/8.
//  Copyright © 2019年 Damon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMAD/HMNativeAd.h"

@interface DubbingRootViewController : UIViewController<HMNativeAdDelegate>

@property (strong, nonatomic) HMNativeAd *nativeAd;
@property (strong, nonatomic) HMNativeAdData *nativeAdData;
@property UIImageView *adImageView;
@property UIButton *countButton;
@property (nonatomic, strong) NSTimer *countTimer;
@property (nonatomic, assign) NSInteger count;


@property (strong, nonatomic) UIWindow *window;


@end
