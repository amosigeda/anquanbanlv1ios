//
//  UncaughtExceptionHandler.m
//  酷宝贝
//
//  Created by yangkang on 16/9/1.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "MyUncaughtExceptionHandler.h"
#import "AppDelegate.h"
#import "WebService.h"
#import "WebServiceParameter.h"

NSString * path;

NSString * applicationDocumentsDirectory()
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

void UncaughtExceptionHandler(NSException * exception)
{
    NSArray * arr = [exception callStackSymbols];
    NSString * reason = [exception reason];
    NSString * name = [exception name];
    NSArray *callStack = [exception callStackSymbols];
    NSString * url = [NSString stringWithFormat:@"========异常错误报告========\nname:%@\nreason:\n%@\ncallStackSymbols:\n%@",name,reason,[arr componentsJoinedByString:@"\n"]];
    path = [applicationDocumentsDirectory() stringByAppendingPathComponent:@"Exception.txt"];
    [url writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    /*
     NSString *urlStr = [NSString stringWithFormat:@"mailto:261548886@qq.com?subject=客户端bug报告&body=很抱歉应用出现故障,感谢您的配合!发送这封邮件可协助我们改善此应用<br>"
     "错误详情:<br>%@<br>--------------------------<br>%@<br>---------------------<br>%@",
     name,reason,[arr componentsJoinedByString:@"<br>"]];
     
     NSURL *url2 = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
     [[UIApplication sharedApplication] openURL:url2];
     */
    /**
     *  把异常崩溃信息发送至开发者邮件
     */
    /*
    NSString *content = [NSString stringWithFormat:@"========异常错误报告========\nname:%@\nreason:\n%@\ncallStackSymbols:\n%@",name,reason,[callStack componentsJoinedByString:@"\n"]];
    
    NSMutableString *mailUrl = [NSMutableString string];
    [mailUrl appendString:@"mailto:261548886@qq.com"];
    [mailUrl appendString:@"?subject=程序异常崩溃，麻烦配合发送异常报告，帮助开发者解决问题，谢谢了！"];
    [mailUrl appendFormat:@"&body=%@", content];
    // 打开地址
    NSString *mailPath = [mailUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailPath]];
    */
}

@implementation MyUncaughtExceptionHandler

-(NSString *)applicationDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+ (void)setDefaultHandler
{
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
    
    /*
    WebService *webService = [WebService newWithWebServiceAction:@"ExceptionError" andDelegate:self];
    webService.tag = 0;
    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"error" andValue:path];
    
    NSArray *parameter = @[loginParameter1];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    //[webService getWebServiceResult:@"ExceptionErrorResult"];
    */
}

+ (NSUncaughtExceptionHandler *)getHandler
{
    return NSGetUncaughtExceptionHandler();
}

+ (void)TakeException:(NSException *)exception
{
    NSArray * arr = [exception callStackSymbols];
    NSString * reason = [exception reason];
    NSString * name = [exception name];
    NSString * url = [NSString stringWithFormat:@"========异常错误报告========\nname:%@\nreason:\n%@\ncallStackSymbols:\n%@",name,reason,[arr componentsJoinedByString:@"\n"]];
    NSString * path = [applicationDocumentsDirectory() stringByAppendingPathComponent:@"Exception.txt"];
    [url writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    NSLog(@"%s:%d %@", __FUNCTION__, __LINE__, url);
}

@end

