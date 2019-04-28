//
//  BabySelectTableViewCell.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//
#import "BabySelectTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation BabySelectTableViewCell

- (void)awakeFromNib {
    
    [self.headView.layer setCornerRadius:25];
    self.headView.layer.masksToBounds = YES;
//    self.headView.layer.borderWidth = 1;
//    self.headView.layer.borderColor = [[UIColor whiteColor] CGColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
