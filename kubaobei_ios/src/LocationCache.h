//
//  LocationCache.h
//  酷宝贝
//
//  Created by yangkang on 16/9/19.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocationCache : NSObject

@property (nonatomic,strong)NSString *LatitudeCache;
@property (nonatomic,strong)NSString *LongitudeCache;
@property (nonatomic,strong)NSString *LocationAddress;
@property (nonatomic,strong)NSString *LocationCacheType;
@property (nonatomic,strong)NSString *ServerTimeCache;
@end
