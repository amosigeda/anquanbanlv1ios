//
//  BookOneTableViewCell.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "BookOneTableViewCell.h"

@implementation BookOneTableViewCell

- (void)awakeFromNib {
    self.headImageView.layer.cornerRadius = 35;
    self.headImageView.layer.masksToBounds = YES;
    self.headImageView.layer.borderWidth = 2;
    self.headImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.contentView.backgroundColor = navigationBarColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
