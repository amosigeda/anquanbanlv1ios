//
//  YCHomeAnnotationView.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "YCHomeAnnotationView.h"

@implementation YCHomeAnnotationView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //[self createUI];
    }
    return self;
}
-(void)createUI{
    
    self.canShowCallout = YES;
    //    self.backgroundColor = [UIColor redColor];
    self.bounds = CGRectMake(0, 0, 44, 44);
    self.centerOffset = CGPointMake(0, -22);
    
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 20, 22, 28)];
    imageView.image = [UIImage imageNamed:@"home_pin"];
    [self addSubview:imageView];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
