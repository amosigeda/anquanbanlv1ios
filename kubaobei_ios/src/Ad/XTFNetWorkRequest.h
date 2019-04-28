//
//  TFNetWorkRequest.h
//  NSURLDoc
//
//  Created by 吴腾飞 on 2018/12/29.
//  Copyright © 2018 Damon. All rights reserved.
//

 
#import <Foundation/Foundation.h>

typedef void (^SuccessBlock)(id responseObject ,NSString *objectStr,NSInteger httpCode);
typedef void (^SuccessBlock2)(id responseObject ,NSDictionary *allHeaderFields,NSString *objectStr,NSInteger httpCode);
typedef void (^SuccessBlock3)(id responseObject,NSString *objectStr,NSInteger httpCode);
typedef void (^FailureBlock)(NSError *error);


@interface XTFNetWorkRequest : NSObject


/**
 *  请求方式
 */
typedef NS_ENUM(NSInteger, HMRequestType) {
    /**
     *  POST方式来进行请求
     */
    HMPOST = 1 << 0,
    /**
     *  GET方式来进行请求
     */
    HMGET  = 1 << 1,
    
    /**
     *  POST方式来进行请求+des加密(自定义)
     */
    HMPOST_DES = 1 << 2,
};


+ (XTFNetWorkRequest *)shareNetWorkManager;


/**
 *  超时时间
 */
@property(nonatomic,assign) NSInteger interval;
/**
 *  网络请求Header
 */
@property(nonatomic,strong) NSDictionary *headerDic;
/**
 *  请求方法
 */
- (void)fetchWithUrl:(NSString *)urlStr httpMedthod:(HMRequestType)httpMethod params:(NSDictionary *)params success:(SuccessBlock)success failure:(FailureBlock)failure;

/**
 *  请求方法
 */
- (void)fetchWithUrl2:(NSString *)urlStr httpMedthod:(HMRequestType)httpMethod params:(NSDictionary *)params success:(SuccessBlock2)success failure:(FailureBlock)failure;

/**
 *  请求方法
 */
- (void)fetchWithUrlData:(NSString *)urlStr httpMedthod:(HMRequestType)httpMethod params:(NSDictionary *)params success:(SuccessBlock3)success failure:(FailureBlock)failure;

@end
