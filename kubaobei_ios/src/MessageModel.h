//
//  MessageModel.h
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageModel : NSObject
@property (nonatomic,strong)NSString *DeviceID;
@property (nonatomic,strong)NSString *Type;
@property (nonatomic,strong)NSString *AddDevice;
@property (nonatomic,strong)NSString *Content;
@property (nonatomic,strong)NSString *Message;
@property (nonatomic,strong)NSString *CreateTime;
@property (nonatomic,strong)NSString *mId;

@end
