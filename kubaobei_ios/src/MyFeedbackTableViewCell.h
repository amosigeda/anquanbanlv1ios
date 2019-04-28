//
//  MyFeedbackTableViewCell.h
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface MyFeedbackTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *problemLabel;
@property (weak, nonatomic) IBOutlet UILabel *answerLabel;
@property (weak, nonatomic) IBOutlet UILabel *problemTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *answerTimeLabel;

@end
