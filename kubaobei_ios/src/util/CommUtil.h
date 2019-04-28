//
// Created by 李晓博 on 2017/5/18.
// Copyright (c) 2017 HH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CommUtil : NSObject

+ (bool) isBlank:(NSObject *)obj;
+ (bool) isNotBlank:(NSObject *)obj;
+ (void)runBlockAfterDelay:(NSTimeInterval)delay queue:(dispatch_queue_t)queue block:(void (^)(void))block;
@end
