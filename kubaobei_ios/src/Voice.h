//
//  Voice.h
//  广润科技个人
//
//  Created by Landony on 15-6-24.
//  Copyright (c) 2015年 Fw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Voice : NSObject
@property int VoiceId;
@property (retain) NSString * Path;
@property int Source;
@property (retain) NSString * CreateTime;
@property int Length;
@end
