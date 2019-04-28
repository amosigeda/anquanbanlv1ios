#import <Foundation/Foundation.h>

@interface WebServiceParameter : NSObject
{
    NSString *key;
    NSString *value;
}

@property (strong) NSString *key;
@property (strong) NSString *value;

- (id)init;
- (id)initWithKey:(NSString *)newKey andValue:(NSString *)newValue;
+ (id)newWithKey:(NSString *)newKey andValue:(NSString *)newValue;

@end
