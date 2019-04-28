//
//  PhotoCollectionViewCell.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//
#import "PhotoCollectionViewCell.h"

@implementation PhotoCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    self.image_ImageView.layer.cornerRadius = 10;
    self.image_ImageView.layer.masksToBounds = YES;
    
    self.bg_Image.layer.cornerRadius = 10;
    self.bg_Image.layer.masksToBounds = YES;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self)
    {
        UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        view.layer.borderWidth=0.5;
        view.clipsToBounds=YES;
        view.layer.borderColor=[UIColor lightGrayColor].CGColor;
        [self addSubview:view];
        //删除按钮
        self.deleteBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [self.deleteBtn setBackgroundImage:[UIImage imageNamed:@"Unknown"] forState:UIControlStateNormal];
        self.deleteBtn.frame=CGRectMake(0, 0, 20, 20);
        [self addSubview:self.deleteBtn];
    }
    return self;
}

@end
