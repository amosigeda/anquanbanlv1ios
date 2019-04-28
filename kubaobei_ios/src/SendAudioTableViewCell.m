//
//  SendAudioTableViewCell.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "SendAudioTableViewCell.h"

@implementation SendAudioTableViewCell

- (void)awakeFromNib {
    [self.headImage.layer setCornerRadius:17.5];
    self.headImage.layer.masksToBounds = YES;
    self.headImage.layer.borderWidth = 1;
    self.headImage.layer.borderColor = [[UIColor whiteColor] CGColor];
    NSLog(@"-----msg-----%@-----------",self.msgLabel);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (float) heightForString1:(NSString *)value fontSize:(float)fontSize andWidth1:(float)width
{
    CGSize sizeToFit = [value sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];//此处的换行类型（lineBreakMode）可根据自己的实际情况进行设置
    return sizeToFit.height;
}

@end
