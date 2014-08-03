#import "AdColony_integration.h"
#import "AudioManager.h"
#import "DataStore.h"
#import "UserInventory.h"

@implementation AdColony_integration {
	BOOL sto_play_bgm;
}
#define DEFAULT_ZONE @"vzfac9afa4884142e1a9"

+(void)preload{}
+(BOOL)is_ads_loaded{
	return NO;
}
+(void)show_ad{}
@end
