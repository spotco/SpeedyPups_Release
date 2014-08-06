#ifdef ANDROID
#else
#import "AdColony_integration.h"
#import "AudioManager.h"
#import "DataStore.h"
#import "UserInventory.h"

@implementation AdColony_integration {
	BOOL sto_play_bgm;
}
#define DEFAULT_ZONE @"vzfac9afa4884142e1a9"

static AdColony_integration *instance;

+(void)preload {
	instance = [[AdColony_integration alloc] init];
	[AdColony configureWithAppID:@"appc84b6d02c6a148218e"
                         zoneIDs:@[DEFAULT_ZONE]
                        delegate:instance
                         logging:YES];
}
+(BOOL)is_ads_loaded {
	return [AdColony zoneStatusForZone:DEFAULT_ZONE] != ADCOLONY_ZONE_STATUS_LOADING;
}
+(void)show_ad {
	if ([UserInventory get_ads_disabled]) return;
	
	[AdColony playVideoAdForZone:DEFAULT_ZONE withDelegate:instance];
}

-(void) onAdColonyAdStartedInZone:( NSString * )zoneID {
	sto_play_bgm = [AudioManager get_play_bgm];
	[AudioManager set_play_bgm:NO];
}

-(void) onAdColonyAdAttemptFinished:(BOOL)shown inZone:( NSString * )zoneID {
	[AudioManager set_play_bgm:sto_play_bgm];
	[AudioManager playbgm_imm:BGM_GROUP_MENU];
}
@end
#endif
