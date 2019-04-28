//
//  AudioModel.h
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioModel : NSObject
@property (nonatomic,strong)NSString *DeviceVoiceId;
@property (nonatomic,strong)NSString *DeviceID;
@property (nonatomic,strong)NSString *State;

@property (nonatomic,strong)NSString *Type;
@property (nonatomic,strong)NSString *ObjectId;
@property (nonatomic,strong)NSString *Mark;
@property (nonatomic,strong)NSString *Path;
@property (nonatomic,strong)NSString *Length;
@property (nonatomic,strong)NSString *MsgType;
@property (nonatomic,strong)NSString *CreateTime;
@property (nonatomic,strong)NSString *UpdateTime;

@end
