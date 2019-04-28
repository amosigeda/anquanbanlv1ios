//
//  UIColor+mcnAddition.h
//
//

#import <UIKit/UIKit.h>

@interface UIColor (MCNAddition)

/// 使用 16 进制数字创建颜色，例如 0xFF0000 创建红色
///
/// @param hex 16 进制无符号32位整数
///
/// @return 颜色
+ (instancetype)mcn_colorWithHex:(uint32_t)hex;

/// 生成随机颜色
///
/// @return 随机颜色
+ (instancetype)mcn_randomColor;

/// 使用 R / G / B 数值创建颜色
///
/// @param red   red
/// @param green green
/// @param blue  blue
///
/// @return 颜色
+ (instancetype)mcn_colorWithRed:(uint8_t)red green:(uint8_t)green blue:(uint8_t)blue;
//
/**
 使用两种颜色混合

 @param color1 颜色1
 @param color2 颜色2
 @param ratio 混合度
 @return 返回颜色 0~1
 */
+(UIColor *)mcn_mixColor1:(UIColor*)color1 color2:(UIColor *)color2 ratio:(CGFloat)ratio;
@end
