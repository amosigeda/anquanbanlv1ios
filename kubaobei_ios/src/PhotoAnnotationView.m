//
//  PhotoAnnotationView.m
//  关爱天使
//
//  Created by Yiwen23 on 16/2/25.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "PhotoAnnotationView.h"
#import "UIImageView+WebCache.h"

@implementation PhotoAnnotationView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
       // [self createUI];
        
        self.canShowCallout = YES;
        //    self.backgroundColor = [UIColor redColor];
        self.bounds = CGRectMake(0, 0, 60,60);
    }
    return self;
}
-(void)createUI:(NSString *)image{
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    [imageView setImageWithURL:[NSURL URLWithString:image]];
    [self addSubview:imageView];
}

@end
