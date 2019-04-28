#import <Foundation/Foundation.h>
#import "WebServiceProtocol.h"
@interface WebService : NSObject <NSXMLParserDelegate>
{
    NSInteger tag;// 区分不同的WebService
    id <WebServiceProtocol> delegate;
    NSString *webServiceUrl;
    NSString *webServiceAction;
    NSArray *webServiceParameter;
    NSMutableData *webData;
    NSMutableString *soapResults;// 调用webservice后返回json数据
    NSString *webServiceResult;
    NSTimer *timer;
}

@property (assign) NSInteger tag;
@property (strong) id <WebServiceProtocol> delegate;
@property (strong) NSString *webServiceUrl;
@property (strong) NSString *webServiceAction;
@property (strong) NSArray *webServiceParameter;
@property (strong) NSMutableData *webData;
@property (strong) NSMutableString *soapResults;
@property (strong) NSString *webServiceResult;
@property (strong) NSTimer *timer;

- (id)init;
- (id)initWithWebServiceAction:(NSString *)newWebServiceAction andDelegate:(id)newDelegate;
+ (id)newWithWebServiceAction:(NSString *)newWebServiceAction andDelegate:(id)newDelegate;
- (void)getWebServiceResult:(NSString *)aWebServiceResult;
@end
