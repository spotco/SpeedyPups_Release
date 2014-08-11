#import <Foundation/Foundation.h>
#import <AdColony/AdColony.h>

@interface AdColony_integration : NSObject <AdColonyDelegate, AdColonyAdDelegate>

+(void)preload;
+(BOOL)is_ads_loaded;
+(void)show_ad;

@end