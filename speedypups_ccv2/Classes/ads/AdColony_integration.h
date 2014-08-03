#import <Foundation/Foundation.h>

//@interface AdColony_integration : NSObject <AdColonyDelegate, AdColonyAdDelegate>

@interface AdColony_integration : NSObject;

+(void)preload;
+(BOOL)is_ads_loaded;
+(void)show_ad;

@end
