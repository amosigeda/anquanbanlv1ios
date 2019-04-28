//
//  NSString+Tools.m
//  QLife
//
//  Created by 李晓博 on 2017/7/19.
//  Copyright © 2017年 李晓博. All rights reserved.
//

#import "NSString+Tools.h"
#import "CommUtil.h"
@implementation NSString (Tools)

/*邮箱验证
 MODIFIED BY HELENSONG*/

-(BOOL)isValidateEmail:(NSString *)email

{
    
    NSString *emailRegex = @"^.+?@.+?\\.[a-zA-Z]{1,6}$";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailRegex];
    return [emailTest evaluateWithObject:email];
    
}

/*MEI号码验证
 MODIFIED BY HELENSONG*/

-(BOOL)isValidateIMEI:(NSString *)mobile

{
    
    /**
     * 
     */
    //    NSString *phoneRegex = @"^\\d{3,16}$";
//    NSString*  phoneRegex = @"^[0-9]*$";
    NSString *phoneRegex = @"^\\d{15}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    
    //
    //    DebugLog(@"phoneTest is %@",phoneTest);
    
    return [phoneTest evaluateWithObject:mobile];
    
}
/*手机号码验证
 MODIFIED BY HELENSONG*/

-(BOOL)isValidateMobile:(NSString *)mobile

{
    
    /**
     * 国际手机号格式
     */
//    NSString *phoneRegex = @"^\\d{3,16}$";
//    NSString*  phoneRegex = @"^\\+?\\d{1,16}$";
    //NSString *phoneRegex = @"^((13[0-9])|(14[5,7,9])|(15[^4])|(18[0-9])|(17[0,1,3,5,6,7,8]))\\d{8}$";
    //NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    
    //
//    DebugLog(@"phoneTest is %@",phoneTest);
    
    //return [phoneTest evaluateWithObject:mobile];
    
    if (mobile!=nil && mobile.length>=11) {
        return  YES;
    }
    
    return NO;
    
}
/*车牌号验证
 MODIFIED BY HELENSONG*/

-(BOOL) validateCarNo:(NSString*)carNo

{
    
    NSString *carRegex = @"^[A-Za-z]{1}[A-Za-z_0-9]{5}$";
    
    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];
    
//    DebugLog(@"carTestis %@",carTest);
    
    return [carTest evaluateWithObject:carNo];
                      
}
//车型


+ (BOOL) validateCarType:(NSString *)CarType


{
    
    
    NSString *CarTypeRegex = @"^[\u4E00-\u9FFF]+$";
    
    
    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",CarTypeRegex];
    
    
    return [carTest evaluateWithObject:CarType];
    
    
}
//用户名


+ (BOOL) validateUserName:(NSString *)name


{
    
    
    NSString *userNameRegex = @"^[A-Za-z0-9]{6,20}+$";
    
    
    NSPredicate *userNamePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",userNameRegex];
    
    
    BOOL B = [userNamePredicate evaluateWithObject:name];
    
    
    return B;
    
    
}
//密码


+ (BOOL) validatePassword:(NSString *)passWord


{
    
    
    NSString *passWordRegex = @"^[a-zA-Z0-9]{6,20}+$";
    
    
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passWordRegex];
    
    
    return [passWordPredicate evaluateWithObject:passWord];
    
    
}
//昵称


+ (BOOL) validateNickname:(NSString *)nickname


{
    
    
    NSString *nicknameRegex = @"^[\u4e00-\u9fa5]{4,8}$";
    
    
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",nicknameRegex];
    
    
    return [passWordPredicate evaluateWithObject:nickname];
    
    
}
//身份证号


+ (BOOL) validateIdentityCard: (NSString *)identityCard


{
    
    
    BOOL flag;
    
    
    if (identityCard.length <= 0) {
        
        
        flag = NO;
        
        
        return flag;
        
        
    }
    NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    
    
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    
    
    return [identityCardPredicate evaluateWithObject:identityCard];
    
    
}

// 根据文字和字体和最大宽度,计算尺寸
- (CGSize)sizeWithFont:(UIFont *)font maxW:(CGFloat)maxW
{
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSFontAttributeName] = font;
    CGSize maxSize = CGSizeMake(maxW, MAXFLOAT);
    return [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

@end
