//
//  ViewUtils.h
//  FAXWIN
//
//  Created by zhanshengshu on 2018/12/5.
//  Copyright © 2018年 zhanshengshu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ViewUtils : NSObject

+ (UIView *)cutCircleWithView:(UIView *)view radius:(CGFloat)radius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;

@end
