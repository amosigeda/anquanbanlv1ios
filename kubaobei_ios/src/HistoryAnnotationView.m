//
//  HistoryAnnotationView.m
//  关爱通
//
//  Created by Yiwen23 on 15/11/26.
//  Copyright © 2015年 YiWen. All rights reserved.
//

#import "HistoryAnnotationView.h"

@implementation HistoryAnnotationView

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
    self.centerOffset = CGPointMake(8, -2);
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 20,10,10)];
    imageView.image = [UIImage imageNamed:@"history_point"];
    [self addSubview:imageView];
}

@end
