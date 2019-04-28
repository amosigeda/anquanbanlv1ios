//
//  YCHUDView.h
//  Deest
//
//  Created by Yiwen23 on 15/12/17.
//  Copyright © 2015年 Yiwen23. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YCHUDView : UIView


+ (YCHUDView *)setOnView:(UIView *)view withTitle:(NSString *)title withImage:(NSString *)image andTime:(float )time animated:(BOOL)animated;
+ (YCHUDView *)setOnView:(UIView *)view withTitle:(NSString *)title andTime:(float )time withType:(NSString *)type animated:(BOOL)animated;
+ (BOOL)hideFromView:(UIView *)view animated:(BOOL)animated;



- (void)stop;

@end
