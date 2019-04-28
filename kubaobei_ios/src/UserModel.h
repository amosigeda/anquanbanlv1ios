//
//  UserModel.h
//  KuBaoBei
//
//  Created by 李晓博 on 2017/5/5.
//  Copyright © 2017年 HH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject
@property(nonatomic,assign)BOOL isLogin;
@property(nonatomic,copy)NSString* phoneNumber;
@property(nonatomic,copy)NSString* userID;
@property(nonatomic,copy)NSString* sandBoxPath;
+ (UserModel *)sharedUserInstance;
@end
