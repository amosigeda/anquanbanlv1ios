//
//  SleepViewController.h
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SleepViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *period1Label;
@property (weak, nonatomic) IBOutlet UILabel *period2Label;
@property (weak, nonatomic) IBOutlet UILabel *sleepLabel;
@property (weak, nonatomic) IBOutlet UILabel *jieguo2Label;
@property (weak, nonatomic) IBOutlet UIButton *morningStarBtn;
@property (weak, nonatomic) IBOutlet UIButton *afternoonEndBtn;
@property (weak, nonatomic) IBOutlet UIButton *morningEndBtn;
@property (weak, nonatomic) IBOutlet UIButton *afternoonStarBtn;

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickView;
@property (weak, nonatomic) IBOutlet UIImageView *ImageView;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@end
