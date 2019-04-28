//
//  GotoSchoolViewController.h
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface GotoSchoolViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *morningLabel;
@property (weak, nonatomic) IBOutlet UILabel *afternoonLabel;
@property (weak, nonatomic) IBOutlet UIButton *morningStarBtn;
@property (weak, nonatomic) IBOutlet UIButton *afternoonEndBtn;
@property (weak, nonatomic) IBOutlet UIButton *morningEndBtn;
@property (weak, nonatomic) IBOutlet UIButton *afternoonStarBtn;
@property (weak, nonatomic) IBOutlet UILabel *weekLabel;
@property (weak, nonatomic) IBOutlet UIButton *thurBtn;

@property (weak, nonatomic) IBOutlet UIButton *satBtn;
@property (weak, nonatomic) IBOutlet UIButton *friBtn;
@property (weak, nonatomic) IBOutlet UIButton *monBtn;
@property (weak, nonatomic) IBOutlet UIButton *thrBtn;
@property (weak, nonatomic) IBOutlet UIButton *tueBtn;
@property (weak, nonatomic) IBOutlet UIButton *sunBtn;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickView;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;

@end
