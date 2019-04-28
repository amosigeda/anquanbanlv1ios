//
//  MylocationAnnotationView.m
//  关爱通
//
//  Created by Yiwen23 on 16/1/15.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "MylocationAnnotationView.h"

@implementation MylocationAnnotationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createUI];
    }
    return self;
}
-(void)createUI{
    
    self.canShowCallout = YES;
    //    self.backgroundColor = [UIColor redColor];
    self.bounds = CGRectMake(0, 0, 44, 44);
    self.centerOffset = CGPointMake(0, -22);
    
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 20, 25, 25)];
    imageView.image = [UIImage imageNamed:@"myLocation_icon"];
    //[self addSubview:imageView];
}

@end
