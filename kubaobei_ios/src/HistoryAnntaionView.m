//
//  HistoryAnntaionView.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "HistoryAnntaionView.h"

@implementation HistoryAnntaionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)createUIWithName:(NSString *)name andType:(NSString *)type andTime:(NSString *)time
{
    self.canShowCallout = NO;
    //    self.backgroundColor = [UIColor redColor];
    self.bounds = CGRectMake(0, 0, 100, 120);
    self.centerOffset = CGPointMake(-23, -52);
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, -5, 100, 91)];
    bgImageView.image =[ UIImage imageNamed:@"bg_infoWindow"];
    [self addSubview:bgImageView];
    
    UILabel *deviceName = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 20)];
    deviceName.text = name;
    deviceName.font = [UIFont systemFontOfSize:13];
    deviceName.textAlignment = UITextAlignmentCenter;
    [self  addSubview:deviceName];
    
    UILabel *deviceType = [[UILabel alloc] initWithFrame:CGRectMake(20, 13, 100, 20)];
    deviceType.text = type;
    deviceType.font = [UIFont systemFontOfSize:13];
    deviceType.textAlignment = UITextAlignmentCenter;
    [self  addSubview:deviceType];
    
    UILabel *deviceTime = [[UILabel alloc] initWithFrame:CGRectMake(20, 21, 100, 50)];
    deviceTime.text = time;
    deviceTime.font = [UIFont systemFontOfSize:13];
    deviceTime.textAlignment = UITextAlignmentCenter;
    deviceTime.numberOfLines = 0;
    [self  addSubview:deviceTime];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(60, 76, 24, 35)];
    imageView.image = [UIImage imageNamed:@"location_watch"];
    [self addSubview:imageView];
}

@end
