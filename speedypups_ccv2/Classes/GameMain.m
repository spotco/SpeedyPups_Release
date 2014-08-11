#import "GameMain.h"
#import "GameModeCallback.h"
#import "UserInventory.h"
#import "Challenge.h"
#import "FreeRunStartAtManager.h"
#import "LoadingScene.h"
#import "IntroAnim.h"
#import "TrackingUtil.h"
#import "AdColony_integration.h"

#import "SpeedyPupsIAP.h"
#import "iRate.h"

@implementation GameMain

#define VERSION_STRING @"SpeedyPups RC3 - August 2014"
#define STARTING_LIVES 10

#define TESTLEVEL @"capegame_launcher"
#define USE_BG			 1

#define DEBUG_UI		 0
#define IMMEDIATELY_BOSS 0
#define BOSS_1_HEALTH	 0
#define SET_CONSTANT_DT  0
#define DRAW_HITBOX		 0

/**
 apportable android ads and IAPs
 **/

#define KEY_NTH_MENU @"key_nth_menu_adcolony_play"
+(void)main {
	[[CCDirector sharedDirector] setDisplayFPS:NO];
	//[[CCDirector sharedDirector].openGLView setMultipleTouchEnabled:YES];
	[GEventDispatcher lazy_alloc];
    [DataStore cons];
    [BatchDraw cons];
	
	if ([UserInventory get_bgm_muted]) [AudioManager set_play_bgm:NO];
	if ([UserInventory get_sfx_muted]) [AudioManager set_play_sfx:NO];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL compress_textures = [defaults boolForKey:@"Compress Textures?"];
	if (compress_textures || [Common force_compress_textures]) {
		[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
	} else {
		[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	}
	//[UserInventory set_ads_disabled:YES];
	
	[DataStore set_key:KEY_NTH_MENU int_value:0];
	NSLog(@"UUID:%@ ADS:%d",[Common unique_id], [UserInventory get_ads_disabled]);
	[TrackingUtil track_evt:TrackingEvt_Login];
	
#ifdef ANDROID
#else
	[AdColony_integration preload];
	[SpeedyPupsIAP preload];
#endif

	LoadingScene *loader = [LoadingScene cons];
	[self run_scene:loader];
	//[loader load_with_callback:[Common cons_callback:(NSObject*)self sel:@selector(start_testlevel)]];
	//[loader load_with_callback:[Common cons_callback:(NSObject*)self sel:@selector(start_game_autolevel)]];
	[loader load_with_callback:[Common cons_callback:(NSObject*)self sel:@selector(start_introanim)]];
	//[loader load_with_callback:[Common cons_callback:(NSObject*)self sel:@selector(start_menu)]];
	//[loader load_with_callback:[Common cons_callback:(NSObject*)self sel:@selector(start_ccv2_test_scene)]];
	
	//[FreeRunStartAtManager set_starting_loc:FreeRunStartAt_LAB3];
	
	//[Player set_character:TEX_DOG_RUN_1];
	/*
	for (int ii = 0; ii < 3; ii++) {
		WorldStartAt startat;
		startat.world_num = WorldNum_1;
		startat.tutorial = YES;
		startat.bg_start = BGMode_NORMAL;
		AutoLevelState *state = [AutoLevelState cons_startat:startat];
		DO_FOR(40,
			   NSString *rtv = [state get_level];
			   if (streq(rtv,@"boss1_start")) {
				   [state to_boss_mode];
			   
			   } else if (streq(rtv, @"boss3_area")) {
				   [state to_labexit_mode];
			   }
			   

			   if ([[NSBundle mainBundle] pathForResource:rtv ofType:@"map"] == NULL) {
				   NSLog(@"%@ ERROR MISSING FILE",rtv);
			   }
			   NSLog(@"%d:\'%@\'",i,rtv)
		);
	}
	*/
	
	/*
	[FreeRunStartAtManager set_can_start_at:FreeRunStartAt_WORLD1];
	[FreeRunStartAtManager set_can_start_at:FreeRunStartAt_LAB1];
	[FreeRunStartAtManager set_can_start_at:FreeRunStartAt_WORLD2];
	[FreeRunStartAtManager set_can_start_at:FreeRunStartAt_LAB2];
	[FreeRunStartAtManager set_can_start_at:FreeRunStartAt_WORLD3];
	[FreeRunStartAtManager set_can_start_at:FreeRunStartAt_LAB3];
	*/
	 
	/*
	[UserInventory unlock_character:TEX_DOG_RUN_2];
	[UserInventory unlock_character:TEX_DOG_RUN_3];
	[UserInventory unlock_character:TEX_DOG_RUN_4];
	[UserInventory unlock_character:TEX_DOG_RUN_5];
	[UserInventory unlock_character:TEX_DOG_RUN_6];
	[UserInventory unlock_character:TEX_DOG_RUN_7];
	*/
	/*
	[UserInventory set_item:Item_Rocket owned:YES];
	[UserInventory set_item:Item_Shield owned:YES];
	[UserInventory set_item:Item_Magnet owned:YES];
	*/
	//[ChallengeRecord set_beaten_challenge:35 to:YES];
	
	//[UserInventory set_equipped_gameitem:Item_Shield];
	//[UserInventory add_bones:5000];
	//[UserInventory add_coins:25];
}

+(void)initialize {
#ifdef ANDROID
#else
	[iRate sharedInstance].daysUntilPrompt = 3;
    [iRate sharedInstance].usesUntilPrompt = 10;
#endif
}

+(void)start_introanim {
	[GameMain run_scene:[IntroAnim scene]];
}

+(void)start_game_autolevel {
    [GameMain run_scene:[GameEngineLayer scene_with_autolevel_lives:[Player current_character_has_power:CharacterPower_DOUBLELIVES]?STARTING_LIVES*2:STARTING_LIVES
															  world:[FreeRunStartAtManager get_startingat]]];
}

+(void)start_game_challengelevel:(ChallengeInfo *)info {
	[GameMain run_scene:[GameEngineLayer scene_with_challenge:info world:info.world]];
	
}

+(void)start_menu {
	[self run_scene:[MainMenuLayer scene]];
	
#ifdef ANDROID
#else
	if ([[iRate sharedInstance] shouldPromptForRating]) {
		[[iRate sharedInstance] promptForRating];
	} else if ([AdColony_integration is_ads_loaded] && [DataStore get_int_for_key:KEY_NTH_MENU] > 0) {
		[AdColony_integration show_ad];
	}
#endif
	
	[DataStore set_key:KEY_NTH_MENU int_value:[DataStore get_int_for_key:KEY_NTH_MENU]+1];

}

+(void)start_testlevel {
	//[self start_game_challengelevel:[ChallengeInfo cons_name:@"tutorial_spikes" type:ChallengeType_FIND_SECRET ct:1 reward:1]];
	[self run_scene:[GameEngineLayer scene_with:TESTLEVEL lives:GAMEENGINE_INF_LIVES world:WorldNum_1]];
}

+(void)start_from_callback:(GameModeCallback *)c {
    if (c.mode == GameMode_FREERUN) {
        [self start_game_autolevel];
        
    } else if (c.mode == GameMode_CHALLENGE) {
        [self start_game_challengelevel:[ChallengeRecord get_challenge_number:c.val]];
        
    }
}

+(void)run_scene:(CCScene*)s {
	[UserInventory reset_to_equipped_gameitem];
	[CCDirectorDisplayLink set_framemodct:1];
    [[CCDirector sharedDirector] runningScene]?
    [[CCDirector sharedDirector] replaceScene:s]:
    [[CCDirector sharedDirector] runWithScene:s];
}

+(BOOL)GET_USE_BG {return USE_BG;}
+(BOOL)GET_DRAW_HITBOX {return DRAW_HITBOX;}
+(BOOL)GET_DO_CONSTANT_DT { return SET_CONSTANT_DT; }
+(BOOL)GET_IMMEDIATE_BOSS { return IMMEDIATELY_BOSS; }
+(BOOL)GET_BOSS_1_HEALTH { return BOSS_1_HEALTH; }
+(int)GET_DEFAULT_STARTING_LIVES { return STARTING_LIVES; }
+(NSString*)GET_VERSION_STRING { return VERSION_STRING; }
+(BOOL)GET_DEBUG_UI { return DEBUG_UI; }
@end

@interface CCDirector (Apportable)
@end
@implementation CCDirector (Apportable)

#ifdef APPORTABLE
- (void)buttonUpWithEvent:(UIEvent *)event {
    switch (event.buttonCode)
    {
		case UIEventButtonCodeBack:
			[GEventDispatcher push_event:[GEvent cons_type:GEventType_PAUSE]];
			break;
		case UIEventButtonCodeMenu:
			// show menu if possible.
			break;
		default:
			break;
	}
}

- (BOOL)canBecomeFirstResponder {
	return YES;
}
#endif

@end
