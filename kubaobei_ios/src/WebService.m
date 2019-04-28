#import "WebService.h"
#import "WebServiceParameter.h"
#import "LFCGzipUtility.h"
#import "Constants.h"
#import "JSON.h"
#import "OMGToast.h"
#import "LoginViewController.h"
@import AFNetworking;
#define TimeOut 20

@implementation WebService
{
@private NSUserDefaults *defaults;
    NSString *server;
}
@synthesize tag;
@synthesize delegate;
@synthesize webServiceUrl;
@synthesize webServiceAction;
@synthesize webServiceParameter;
@synthesize webData;
@synthesize soapResults;
@synthesize webServiceResult;
@synthesize timer;
#pragma mark - initialization

- (id)init
{
    return [self initWithWebServiceAction:nil andDelegate:nil];
}

- (id)initWithWebServiceAction:(NSString *)newWebServiceAction andDelegate:(id)newDelegate
{
    if (self = [super init]) {
        defaults=[NSUserDefaults standardUserDefaults];
        self.delegate = newDelegate;
        
        //        server=@"http://192.168.1.199:6699/Client";
        server=@"https://www.etobaogroup.com:6699/Client";
        //        server=@"https://apps.8kk.win:6699/Client";
        [self setWebServiceUrl:server];
        self.webServiceAction = newWebServiceAction;
        self.webData = [[NSMutableData alloc] init];
    }
    
    return self;
}

+ (id)newWithWebServiceAction:(NSString *)newWebServiceAction andDelegate:(id)newDelegate
{
    return [[WebService alloc] initWithWebServiceAction:newWebServiceAction andDelegate:newDelegate];
}

-(AFHTTPSessionManager *)manager{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    // 超时时间
    manager.requestSerializer.timeoutInterval = TimeOut;
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    return manager;
}

#pragma mark - WebService

- (void)getWebServiceResult:(NSString *)aWebServiceResult{
    self.webServiceResult = aWebServiceResult;
    if(webServiceParameter == nil || webServiceParameter.count == 0){
        if(delegate && [delegate respondsToSelector:@selector(WebServiceGetError:error:)]){
            [delegate WebServiceGetError:self error:@"request error"];
        }
        return;
    }
    WebServiceParameter *requestParmeter = webServiceParameter[0];
    if(!([@"POST" isEqualToString:requestParmeter.key] || [@"GET" isEqualToString:requestParmeter.key])){
        if(delegate && [delegate respondsToSelector:@selector(WebServiceGetError:error:)]){
            [delegate WebServiceGetError:self error:@"request error"];
        }
        return;
    }
    NSString *requestAddr = [requestParmeter.value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *ip;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults stringForKey:MAIN_USER_IP].length && ([requestAddr hasPrefix:@"controllerDevice"] || [requestAddr hasPrefix:@"phonebook/addfriend"] || [requestAddr hasPrefix:@"phonebook/deletePhoneBook"] || [requestAddr hasPrefix:@"phonebook/updatePhoneBook"] || [requestAddr hasPrefix:@"watchset/setLocationFrequency"] || [requestAddr hasPrefix:@"watchset/set"] || [requestAddr hasPrefix:@"watchuser/factory"] || [requestAddr hasPrefix:@"tk/tkToDevice"]) || [requestAddr hasPrefix:@"watchAppUser/updateAdminPhone"] || [requestAddr hasPrefix:@"app/setdialpad"] || [requestAddr hasPrefix:@"watchuser/reset"] || [requestAddr hasPrefix:@"watchinfo/updateAlarm"]){
        ip = [defaults stringForKey:MAIN_USER_IP];
    }else{
        ip = @"47.92.183.190:80";
    }
    NSString *URLString = [NSString stringWithFormat:@"http://%@/shoubiao/%@",ip,requestAddr];
    NSData *data = nil;
    if(webServiceParameter.count > 1){
        NSMutableDictionary *dict = [NSMutableDictionary new];
        for (int i = 1;i < webServiceParameter.count;i++) {
            WebServiceParameter *parmeter = webServiceParameter[i];
            [dict setObject:parmeter.value forKey:parmeter.key];
        }
        data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
        NSString *parameters = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"request %@:%@\n%@",requestParmeter.key,URLString,parameters);
    }else{
        NSLog(@"request %@:%@",requestParmeter.key,URLString);
    }
    // 创建请求类
    AFHTTPSessionManager *manager = [self manager];
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:requestParmeter.key URLString:URLString parameters:nil error:nil];
    [request setHTTPMethod:requestParmeter.key];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    if(data != nil){
        [request setHTTPBody:data];
    }
    [[manager dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if(error){
            if(delegate && [delegate respondsToSelector:@selector(WebServiceGetError:error:)]){
                [delegate WebServiceGetError:self error:[NSString stringWithFormat:@"%@",error]];
            }
            NSLog(@"%@",error);
        }else if(responseObject){ // 请求成功
            if(delegate && [delegate respondsToSelector:@selector(WebServiceGetCompleted:)]){
                NSString *result = [[NSString alloc] initWithData:responseObject  encoding:NSUTF8StringEncoding];
                self.soapResults = result;
                NSLog(@"response:\n%@",result);
                SBJsonParser *parser = [[SBJsonParser alloc] init];
                NSError *error = nil;
                // 解析成json数据
                id object = [parser objectWithString:result error:&error];
                if (!error && object) {
                    int code = [[object objectForKey:@"Code"] intValue];
                    if(code == -1){
                        UIWindow *window = [UIApplication sharedApplication].keyWindow;
                        if ([window.rootViewController isKindOfClass:[UINavigationController class]]) {
                            UINavigationController *nav = window.rootViewController;
                            for(UIViewController *controller in nav.viewControllers){
                                if([controller isKindOfClass:[LoginViewController class]]){
                                    return;
                                }
                            }
                        }
                        LoginViewController *vc = [[LoginViewController alloc] init];
                        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                        [window setRootViewController:nav];
                        [window makeKeyAndVisible];
                        [OMGToast showWithText:NSLocalizedString(@"login_other_way_tips", nil) bottomOffset:50 duration:3];
                    }else{
                        [delegate WebServiceGetCompleted:self];
                    }
                }else{
                    [delegate WebServiceGetCompleted:self];
                }
            }else{
                NSString *result = [[NSString alloc] initWithData:responseObject  encoding:NSUTF8StringEncoding];
                NSLog(@"response:\n%@",result);
                SBJsonParser *parser = [[SBJsonParser alloc] init];
                NSError *error = nil;
                // 解析成json数据
                id object = [parser objectWithString:result error:&error];
                if (!error && object) {
                    int code = [[object objectForKey:@"Code"] intValue];
                    if(code == -1){
                        UIWindow *window = [UIApplication sharedApplication].keyWindow;
                        if ([window.rootViewController isKindOfClass:[UINavigationController class]]) {
                            UINavigationController *nav = window.rootViewController;
                            for(UIViewController *controller in nav.viewControllers){
                                if([controller isKindOfClass:[LoginViewController class]]){
                                    return;
                                }
                            }
                        }
                        LoginViewController *vc = [[LoginViewController alloc] init];
                        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                        [window setRootViewController:nav];
                        [window makeKeyAndVisible];
                        [OMGToast showWithText:NSLocalizedString(@"login_other_way_tips", nil) bottomOffset:50 duration:3];
                    }
                }
            }
        } else {
            if(delegate && [delegate respondsToSelector:@selector(WebServiceGetError:error:)]){
                [delegate WebServiceGetError:self error:@"暂无数据"];
            }
            NSLog(@"暂无数据");
        }
    }] resume];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [webData setLength:0];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [webData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self WebServiceGetError:@"The Connection is Error"];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    webData=[LFCGzipUtility ungzipData:webData];
    //NSLog([[NSString alloc]initWithData:webData encoding:NSUTF8StringEncoding]);
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:webData];
    [xmlParser setDelegate:self];
    [xmlParser setShouldResolveExternalEntities:YES];
    [xmlParser parse];
}

#pragma mark - WebServiceProtocol

- (void)WebServiceGetCompleted
{    
    if (timer) {
        [timer invalidate];
        self.timer = nil;
    }
    if(NSlog.intValue == 1)
    {
        //        NSLog(soapResults);
        
        //        DLog(@"%@",soapResults);
        
    }
    if (delegate) {
        if ([delegate respondsToSelector:@selector(WebServiceGetCompleted:)]) {
            [delegate WebServiceGetCompleted:self];
        }
    }
}

- (void)WebServiceGetError:(NSString *)theError
{
    if (timer) {
        [timer invalidate];
        self.timer = nil;
    }
    
    if (delegate) {
        if ([delegate respondsToSelector:@selector(WebServiceGetError:error:)])
            [delegate WebServiceGetError:self error:theError];
    }
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:webServiceResult]) {
        self.soapResults = [[NSMutableString alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (soapResults) {
        [self.soapResults appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:webServiceResult]) {
        [self WebServiceGetCompleted];
    }
}

#pragma mark - Time Out Manage

- (void)timeOut
{
    [self WebServiceGetError:@"Time Out."];
}

@end
