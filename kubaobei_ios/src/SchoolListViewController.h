//
//  SchoolListViewController.h
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZHPickView.h"
@interface SchoolListViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *classTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *morningLabel;
@property (weak, nonatomic) IBOutlet UILabel *afternoonLabel;
@property (weak, nonatomic) IBOutlet UIButton *morningStarButton;
@property (weak, nonatomic) IBOutlet UIButton *morningEndButton;
@property (weak, nonatomic) IBOutlet UIButton *afternoonStarButton;
@property (weak, nonatomic) IBOutlet UIButton *afternoonEndButton;
@property (weak, nonatomic) IBOutlet UILabel *weedLabel;
@property (weak, nonatomic) IBOutlet UIButton *monBuoon;
@property (weak, nonatomic) IBOutlet UIButton *tueButton;
@property (weak, nonatomic) IBOutlet UIButton *thurButton;
@property (weak, nonatomic) IBOutlet UIButton *friButton;

@property (weak, nonatomic) IBOutlet UIButton *thrButton;
@property (weak, nonatomic) IBOutlet UIButton *satButton;
@property (weak, nonatomic) IBOutlet UIButton *sunButton;
@property (weak, nonatomic) IBOutlet UIButton *savebutton;

@property (weak, nonatomic) IBOutlet UIPickerView *pickView;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;

@end
