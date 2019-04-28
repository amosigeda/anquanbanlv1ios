//
//  UIImage+Utility.h
//  RoundView
//
//  Created by jhwang on 11-6-16.
//  Copyright 2011 Cybozu, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
typedef enum {
    UIImageRoundedCornerTopLeft = 1,
    UIImageRoundedCornerTopRight = 1 << 1,
    UIImageRoundedCornerBottomRight = 1 << 2,
    UIImageRoundedCornerBottomLeft = 1 << 3
} UIImageRoundedCorner;

@interface UIImage (Utility)

//+ (void)addRoundedRectToPath(CGContextRef context, CGRect rect, float radius, UIImageRoundedCorner cornerMask);

- (UIImage *)roundedRectWith:(float)radius cornerMask:(UIImageRoundedCorner)cornerMask;

@end
