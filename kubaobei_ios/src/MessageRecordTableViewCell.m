//
//  MessageRecordTableViewCell.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "MessageRecordTableViewCell.h"

@implementation MessageRecordTableViewCell

- (void)awakeFromNib {
    [self.iconImage.layer setCornerRadius:25];
    self.iconImage.layer.masksToBounds = YES;
    self.iconImage.layer.borderWidth = 1;
    self.iconImage.layer.borderColor = [[UIColor whiteColor] CGColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
