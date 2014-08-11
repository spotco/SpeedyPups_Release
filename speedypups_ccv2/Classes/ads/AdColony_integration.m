
#import "AdColony_integration.h"
#import "AudioManager.h"
#import "DataStore.h"
#import "UserInventory.h"

@implementation AdColony_integration {
	BOOL sto_play_bgm;
}


static AdColony_integration *instance;

+(void)preload {
	instance = [[AdColony_integration alloc] init];
	
#ifdef ANDROID
	#define DEFAULT_ZONE @"vz08d6e4e01a0b43d3ad"
	[AdColony configureWithAppID:@"appab8fe0dd4e31473ab7"
                         zoneIDs:@[DEFAULT_ZONE]
                        delegate:instance
                         logging:YES];
#else
	#define DEFAULT_ZONE @"vzfac9afa4884142e1a9"
	[AdColony configureWithAppID:@"appc84b6d02c6a148218e"
                         zoneIDs:@[DEFAULT_ZONE]
                        delegate:instance
                         logging:YES];
#endif
}
+(BOOL)is_ads_loaded {
	ADCOLONY_ZONE_STATUS rtv = [AdColony zoneStatusForZone:DEFAULT_ZONE];
	NSLog(@"adstatus: %d %d %d %d %d",rtv==ADCOLONY_ZONE_STATUS_ACTIVE,rtv==ADCOLONY_ZONE_STATUS_LOADING,rtv==ADCOLONY_ZONE_STATUS_NO_ZONE,rtv==ADCOLONY_ZONE_STATUS_OFF,rtv==ADCOLONY_ZONE_STATUS_UNKNOWN);
	return rtv != ADCOLONY_ZONE_STATUS_LOADING;
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
