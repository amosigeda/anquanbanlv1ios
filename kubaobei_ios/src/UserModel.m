//
//  UserModel.m
//  KuBaoBei
//
//  Created by 李晓博 on 2017/5/5.
//  Copyright © 2017年 HH. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel
+ (UserModel *)sharedUserInstance
{
    static UserModel *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[self alloc] init];
        
    });
    return sharedAccountManagerInstance;
}

@end
