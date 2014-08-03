#import <Foundation/Foundation.h>

@interface ObjectPool : NSObject

+(void)prepool;
+(id)depool:(Class)c;
+(void)repool:(id)obj class:(Class)c;

+(void)print_info;

@end
