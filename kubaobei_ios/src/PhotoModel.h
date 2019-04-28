//
//  PhotoModel.h
//  关爱天使
//
//  Created by Yiwen23 on 16/2/24.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoModel : NSObject
@property (nonatomic,strong)NSString *DevicePhotoId;
@property (nonatomic,strong)NSString *DeviceID;
@property (nonatomic,strong)NSString *Source;
@property (nonatomic,strong)NSString *DeviceTime;
@property (nonatomic,strong)NSString *Latitude;
@property (nonatomic,strong)NSString *Longitude;
@property (nonatomic,strong)NSString *Mark;
@property (nonatomic,strong)NSString *Path;
@property (nonatomic,strong)NSString *Length;
@property (nonatomic,strong)NSString *CreateTime;
@property (nonatomic,strong)NSString *UpdateTime;
@property (nonatomic,strong)NSString *Address;

@end
