//
//  OpenAndCloseViewController.h
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OpenAndCloseViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *openTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *openTime;
@property (weak, nonatomic) IBOutlet UILabel *closeTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *closeTime;
@property (weak, nonatomic) IBOutlet UILabel *AttentionLabel;
@property (weak, nonatomic) IBOutlet UILabel *noticeLabel;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickView;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;

@end
