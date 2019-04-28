//
//  UncaughtExceptionHandler.h
//  酷宝贝
//
//  Created by yangkang on 16/9/1.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyUncaughtExceptionHandler : NSObject

+ (void)setDefaultHandler;
+ (NSUncaughtExceptionHandler *)getHandler;
+ (void)TakeException:(NSException *) exception;
- (void)SendErrorcontent;
@end
