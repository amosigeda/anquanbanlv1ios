#import <Foundation/Foundation.h>

@protocol WebServiceProtocol <NSObject>

- (void)WebServiceGetCompleted:(id)theWebService;
- (void)WebServiceGetError:(id)theWebService error:(NSString *)theError;

@end
