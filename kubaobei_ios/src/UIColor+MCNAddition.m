//
//  UIColor+mcnAddition.m
//
//

#import "UIColor+MCNAddition.h"

@implementation UIColor (MCNAddition)

+ (instancetype)mcn_colorWithHex:(uint32_t)hex {
    
    uint8_t r = (hex & 0xff0000) >> 16;
    uint8_t g = (hex & 0x00ff00) >> 8;
    uint8_t b = hex & 0x0000ff;
    
    return [self mcn_colorWithRed:r green:g blue:b];
}

+ (instancetype)mcn_randomColor {
    return [UIColor mcn_colorWithRed:arc4random_uniform(256) green:arc4random_uniform(256) blue:arc4random_uniform(256)];
}

+ (instancetype)mcn_colorWithRed:(uint8_t)red green:(uint8_t)green blue:(uint8_t)blue {
    return [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:1.0];
}
//混合颜色,ratio 0~1
+(UIColor *)mcn_mixColor1:(UIColor*)color1 color2:(UIColor *)color2 ratio:(CGFloat)ratio
{
    if(ratio > 1)
        ratio = 1;
    const CGFloat * components1 = CGColorGetComponents(color1.CGColor);
    const CGFloat * components2 = CGColorGetComponents(color2.CGColor);
        NSLog(@"Red1: %f", components1[0]);
        NSLog(@"Green1: %f", components1[1]);
        NSLog(@"Blue1: %f", components1[2]);
        NSLog(@"Red2: %f", components2[0]);
        NSLog(@"Green2: %f", components2[1]);
        NSLog(@"Blue2: %f", components2[2]);
    
    NSLog(@"ratio = %f",ratio);
    CGFloat r = components1[0]*ratio + 0*(1-ratio);
    CGFloat g = components1[1]*ratio + 0*(1-ratio);
    CGFloat b = components1[2]*ratio + 0*(1-ratio);
    //    CGFloat alpha = components1[3]*ratio + components2[3]*(1-ratio);
    
    return [UIColor colorWithRed:r green:g blue:b alpha:1];
}


@end
