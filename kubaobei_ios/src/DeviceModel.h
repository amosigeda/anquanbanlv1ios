//
//  DeviceModel.h
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceModel : NSObject
@property (nonatomic,strong)NSString* CloudPlatform;//电话类型
@property (nonatomic,strong)NSString *ActiveDate;//设备运动时间
@property (nonatomic,strong)NSString *BabyName;//宝贝名字
@property (nonatomic,strong)NSString *BindNumber;//绑定号
@property (nonatomic,strong)NSString *CurrentFirmware;//当前固件版本号
@property (nonatomic,strong)NSString *DeviceModelID;//设备类型
@property (nonatomic,strong)NSString *Firmware;//需要升级的固件版本号
@property (nonatomic,strong)NSString *HireExpireDate;//设备到期时间
@property (nonatomic,strong)NSString *Date;//设备激活时间
@property (nonatomic,strong)NSString *IsGuard;//是否开启宝贝守护功能
@property (nonatomic,strong)NSString *PhoneCornet;//是否开启宝贝守护功能
@property (nonatomic,strong)NSString *Gender;//性别
@property (nonatomic,strong)NSString *DeviceType;//设备种类
@property (nonatomic,strong)NSString *Birthday;//生日
@property (nonatomic,strong)NSString *SerialNumber;
@property (nonatomic,strong)NSString *Grade;
@property (nonatomic,strong)NSString *HomeAddress;
@property (nonatomic,strong)NSString *HomeLat;
@property (nonatomic,strong)NSString *HomeLng;
@property (nonatomic,strong)NSString *PhoneNumber;
@property (nonatomic,strong)NSString *Photo;
@property (nonatomic,strong)NSString *SchoolLat;
@property (nonatomic,strong)NSString *SchoolAddress;
@property (nonatomic,strong)NSString *SchoolLng;
@property (nonatomic,strong)NSString *UpdateTime;
@property (nonatomic,strong)NSString *UserId;
@property (nonatomic,strong)NSString *CreateTime;
@property (nonatomic,strong)NSString *DeviceID;
@property (nonatomic,strong)NSString *Password;
@property (nonatomic,strong)NSString *SetVersionNO;
@property (nonatomic,strong)NSString *ContactVersionNO;
@property (nonatomic,strong)NSString *OperatorType;
@property (nonatomic,strong)NSString *SmsNumber;
@property (nonatomic,strong)NSString *SmsBalanceKey;
@property (nonatomic,strong)NSString *SmsFlowKey;
@property (nonatomic,strong)NSString *LatestTime;
@end
