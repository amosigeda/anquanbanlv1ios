//
//  WatchPhoneTableViewCell.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "WatchPhoneTableViewCell.h"

@implementation WatchPhoneTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    [self.headView.layer setCornerRadius:20];
    self.headView.layer.masksToBounds = YES;
    self.headView.layer.borderWidth = 1;
    self.headView.layer.borderColor = [navigationBarColor CGColor];

}

- (float) heightForString:(NSString *)value fontSize:(float)fontSize andWidth:(float)width
{
    CGSize sizeToFit = [value sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];//此处的换行类型（lineBreakMode）可根据自己的实际情况进行设置
    return sizeToFit.height;
}

-(void)setIntroductionText:(NSString*)text{
    
    //获得当前cell高度
    
    CGRect frame = [self frame];
    
    //文本赋值
    
    self.listLabel.text = text;
    
    //设置label的最大行数
    
    self.listLabel.numberOfLines = 100;
    
    CGSize size = CGSizeMake(300, 100000000000);
    
    CGSize labelSize = [self.listLabel.text sizeWithFont:self.listLabel.font constrainedToSize:size lineBreakMode:NSLineBreakByClipping];
    
    self.listLabel.frame = CGRectMake(self.listLabel.frame.origin.x, self.listLabel.frame.origin.y, labelSize.width, labelSize.height);
    //计算出自适应的高度
    
    frame.size.height = labelSize.height+180;
    self.frame = frame;
    
}  

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
