//
//  NSString+Tools.h
//  QLife
//
//  Created by 李晓博 on 2017/7/19.
//  Copyright © 2017年 李晓博. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Tools)
/*MEI号码验证
 MODIFIED BY HELENSONG*/

-(BOOL)isValidateIMEI:(NSString *)mobile;
/*邮箱验证
 MODIFIED BY HELENSONG*/

-(BOOL)isValidateEmail:(NSString *)email;

/*手机号码验证
 MODIFIED BY HELENSONG*/

-(BOOL)isValidateMobile:(NSString *)mobile;
/*车牌号验证
 MODIFIED BY HELENSONG*/

-(BOOL) validateCarNo:(NSString*)carNo;
//车型

+ (BOOL) validateCarType:(NSString *)CarType;

- (CGSize)sizeWithFont:(UIFont *)font maxW:(CGFloat)maxW;
@end
