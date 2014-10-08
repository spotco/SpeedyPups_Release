#import "AdColony_integration.h"
#import "AudioManager.h"
#import "DataStore.h"
#import "UserInventory.h"
#import "Common.h"

@implementation AdColony_integration {
	BOOL sto_play_bgm;
	void (^sto_onfinish)(void);
	void (^sto_onbegin)(void);
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


static long _last_ad_shown_time = 0;
+(void)show_ad_onbegin:(void (^)())onbegin onfinish:(void (^)())onfinish {
	if ([UserInventory get_ads_disabled] || ((_last_ad_shown_time != 0) && (sys_time() - _last_ad_shown_time < 120))) {
		//NSLog(@"too short time %ld",sys_time() - _last_ad_shown_time);
		onbegin();
		onfinish();
		return;
	}
	//NSLog(@"ok time %ld",sys_time() - _last_ad_shown_time);
	_last_ad_shown_time = sys_time();
	
	[instance set_onbegin:onbegin onfinish:onfinish];
	[AdColony playVideoAdForZone:DEFAULT_ZONE withDelegate:instance];
}

-(void)set_onbegin:(void (^)())onbegin onfinish:(void (^)())onfinish {
	sto_onbegin = onbegin;
	sto_onfinish = onfinish;
	sto_play_bgm = [AudioManager get_play_bgm];
}

-(void) onAdColonyAdStartedInZone:( NSString * )zoneID {
	sto_play_bgm = [AudioManager get_play_bgm];
	[AudioManager set_play_bgm:NO];
	
	if (sto_onbegin != NULL) sto_onbegin();
	sto_onbegin = NULL;
}

-(void) onAdColonyAdAttemptFinished:(BOOL)shown inZone:( NSString * )zoneID {
	[AudioManager set_play_bgm:sto_play_bgm];
	if (sto_onbegin != NULL) sto_onbegin();
	sto_onbegin = NULL;
	if (sto_onfinish != NULL) sto_onfinish();
	sto_onfinish = NULL;
}
@end
