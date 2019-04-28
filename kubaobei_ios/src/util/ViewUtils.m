//
//  ViewUtils.m
//  FAXWIN
//
//  Created by zhanshengshu on 2018/12/5.
//  Copyright © 2018年 zhanshengshu. All rights reserved.
//

#import "ViewUtils.h"

@implementation ViewUtils

+ (UIView *)cutCircleWithView:(UIView *)view radius:(CGFloat)radius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor{
    //切圆半径
    view.layer.cornerRadius = radius;
    //开启切圆功能
    view.layer.masksToBounds = YES;
    //给图层添加一个有色边框
    view.layer.borderWidth = borderWidth;
    //有色边框颜色
    view.layer.borderColor = borderColor.CGColor;
    return view;
}



@end
