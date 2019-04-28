//
//  YCHUDView.m
//  Deest
//
//  Created by Yiwen23 on 15/12/17.
//  Copyright © 2015年 Yiwen23. All rights reserved.
//

#import "YCHUDView.h"
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
#define CurrentSystemVersion [[UIDevice currentDevice] systemVersion]
@implementation YCHUDView

+ (YCHUDView *)setOnView:(UIView *)view withTitle:(NSString *)title withImage:(NSString *)image andTime:(float)time animated:(BOOL)animated;
{
    UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    bg.image = [UIImage imageNamed:@"dary_bgView"];
    [view addSubview:bg];
    
    YCHUDView *hud = [[YCHUDView alloc] initWithFrame:CGRectMake(30, SCREEN_HEIGHT/2, SCREEN_WIDTH-60, 120)];
    UIImageView *bgImage = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH-60,120)];
    bgImage.image = [UIImage imageNamed:@"yc_bg_image"];
    [hud addSubview:bgImage];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(hud.frame.size.width/2-25, 10, 50, 50)];
    imageView.image = [UIImage imageNamed:image];
    [hud addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,70,SCREEN_WIDTH-60,30)];
    label.font = [UIFont systemFontOfSize:15.0f];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = title;
    [hud addSubview:label];
    
    [view addSubview:hud];
    float height = [[UIScreen mainScreen] bounds].size.height;
    float width = [[UIScreen mainScreen] bounds].size.width;
    CGPoint center = CGPointMake(width/2, height/2);
    hud.center = center;
    
    double delayInSeconds =(double) time ;
    
    dispatch_time_t popTime = dispatch_time ( DISPATCH_TIME_NOW , delayInSeconds * NSEC_PER_SEC );
    
    dispatch_after (popTime, dispatch_get_main_queue (), ^( void ){
        
        [hud removeFromSuperview];
        [bg removeFromSuperview];
        view.backgroundColor =[[UIColor whiteColor] colorWithAlphaComponent:1];
        
    });
    return hud;
}

+ (YCHUDView *)setOnView:(UIView *)view withTitle:(NSString *)title andTime:(float )time withType:(NSString *)type animated:(BOOL)animated
{
    YCHUDView *hud = [[YCHUDView alloc] initWithFrame:CGRectMake(30, SCREEN_HEIGHT/2, SCREEN_WIDTH-60, 120)];
    UIImageView *bgImage = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH-60,120)];
    bgImage.image = [UIImage imageNamed:@"yc_bg_image"];
    [hud addSubview:bgImage];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(hud.frame.size.width/2-30, 10, 60, 60)];
    if(type.intValue == 1)
    {
        imageView.image = [UIImage imageNamed:@"progress_1"];
    }
    else if(type.intValue == 2)
    {
        imageView.image = [UIImage imageNamed:@"rotating_1"];

    }
    
    [hud addSubview:imageView];
    
    if(IOS_VERSION >= 8.0)
    {
        if(type.intValue == 1)
        {
            UIImage *image1 = [UIImage imageNamed:@"progress_1"];
            UIImage *image2 = [UIImage imageNamed:@"progress_2"];
            UIImage *image3 = [UIImage imageNamed:@"progress_3"];
            UIImage *image4 = [UIImage imageNamed:@"progress_4"];
            UIImage *image5 = [UIImage imageNamed:@"progress_5"];
            UIImage *image6 = [UIImage imageNamed:@"progress_6"];
            UIImage *image7 = [UIImage imageNamed:@"progress_7"];
            UIImage *image8 = [UIImage imageNamed:@"progress_8"];
            imageView.animationDuration = 0.8;
            imageView.animationImages = @[image1,image2,image3,image4,image5,image6,image7,image8];
            
            [imageView startAnimating];
        }
        else if(type.intValue == 2)
        {
            UIImage *image1 = [UIImage imageNamed:@"rotating_1"];
            UIImage *image2 = [UIImage imageNamed:@"rotating_2"];
            UIImage *image3 = [UIImage imageNamed:@"rotating_3"];
            UIImage *image4 = [UIImage imageNamed:@"rotating_4"];
            UIImage *image5 = [UIImage imageNamed:@"rotating_5"];
            UIImage *image6 = [UIImage imageNamed:@"rotating_6"];
            UIImage *image7 = [UIImage imageNamed:@"rotating_7"];
            UIImage *image8 = [UIImage imageNamed:@"rotating_8"];
            imageView.animationDuration = 0.8;
            imageView.animationImages = @[image1,image2,image3,image4,image5,image6,image7,image8];
            
            [imageView startAnimating];
        }
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,80,SCREEN_WIDTH-60,30)];
    label.font = [UIFont systemFontOfSize:16.0f];
    label.textColor = [UIColor colorWithRed:61/255.0 green:180/255.0 blue:188/255.0 alpha:1];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = title;
    [hud addSubview:label];
    
    [view addSubview:hud];
    float height = [[UIScreen mainScreen] bounds].size.height;
    float width = [[UIScreen mainScreen] bounds].size.width;
    CGPoint center = CGPointMake(width/2, height/2);
    hud.center = center;
    

    return hud;
}

+ (BOOL)hideFromView:(UIView *)view animated:(BOOL)animated {
    YCHUDView *hud = [YCHUDView HUDForView:view];
 //   [hud stop];
    if (hud) {
        [hud removeFromSuperview];
        return YES;
    }
    return NO;
}

//------------------------------------
// Perform search for loader and hide it
//------------------------------------
+ (YCHUDView *)HUDForView: (UIView *)view {
    YCHUDView *hud = nil;
    NSArray *subViewsArray = view.subviews;
    Class hudClass = [YCHUDView class];
    for (UIView *aView in subViewsArray) {
        if ([aView isKindOfClass:hudClass]) {
            hud = (YCHUDView *)aView;
        }
    }
    return hud;
}



@end
