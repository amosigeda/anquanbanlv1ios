//
// Created by 李晓博 on 2017/5/18.
// Copyright (c) 2017 HH. All rights reserved.
//

#import "CommUtil.h"

@implementation CommUtil
+ (bool)isBlank:(NSObject *)obj {
    if (obj == nil || [(NSNull *) obj isEqual:[NSNull null]]) {
        return true;
    }
    NSString *str;
    if ([obj isKindOfClass:[NSString class]]) {
        str = (NSString *) obj;
    } else {
        str = [NSString stringWithFormat:@"%@", obj];
    }
    if ([str length] == 0) {
        return true;
    }
    if ([[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
        return true;
    }
    return false;
}

+ (bool)isNotBlank:(NSObject *)obj {
    return ![CommUtil isBlank:obj];
}

+ (void)runBlockAfterDelay:(NSTimeInterval)delay
                     queue:(dispatch_queue_t)queue block:(void (^)(void))block {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * delay),
            queue, block);
}
@end
