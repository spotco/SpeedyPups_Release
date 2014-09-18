#import <Foundation/Foundation.h>
#import "SimpleAudioEngine.h"

typedef enum {
	BGM_GROUP_WORLD1 = 0,
	BGM_GROUP_LAB = 1,
	BGM_GROUP_MENU = 2,
	BGM_GROUP_BOSS1 = 3,
	BGM_GROUP_JINGLE = 4,
	BGM_GROUP_WORLD2 = 5,
	BGM_GROUP_WORLD3 = 6,
	BGM_GROUP_CAPEGAME = 7,
	BGM_GROUP_INTRO = 8
} BGM_GROUP;

//afconvert -f caff -d LEI16 DOG_Music_019b.mp3 test.aiff

//bgm_1
#define BGMUSIC_MENU1 @"menu1.mp3"
#define BGMUSIC_BOSS1 @"boss1.mp3"
#define BGMUSIC_LAB1 @"lab1.mp3"
#define BGMUSIC_JINGLE @"jingle.mp3"
#define BGMUSIC_CAPEGAMELOOP @"capegameloop.mp3"
#define BGMUSIC_INTRO @"intro.mp3"

#define BGMUSIC_GAMELOOP1 @"gameloop1.mp3"
#define BGMUSIC_GAMELOOP2 @"gameloop2.mp3"
#define BGMUSIC_GAMELOOP3 @"gameloop3.mp3"

//bgm_2
#define BGMUSIC_GAMELOOP1_NIGHT @"gameloop1_night.mp3"
#define BGMUSIC_GAMELOOP2_NIGHT @"gameloop2_night.mp3"
#define BGMUSIC_GAMELOOP3_NIGHT @"gameloop3_night.mp3"

#define BGMUSIC_INVINCIBLE @"invincible.mp3"

#define SFX_BONE @"sfx_bone_1.wav"
#define SFX_BONE_2 @"sfx_bone_2.wav"
#define SFX_BONE_3 @"sfx_bone_3.wav"
#define SFX_BONE_4 @"sfx_bone_4.wav"

#define SFX_EXPLOSION @"sfx_explosion.wav" 
#define SFX_HIT @"sfx_hit.wav"
#define SFX_JUMP @"sfx_jump.wav"
#define SFX_SPIN @"sfx_spin.wav"
#define SFX_SPLASH @"sfx_splash.wav"
#define SFX_BIRD_FLY @"sfx_bird_fly.wav" 
#define SFX_ROCKBREAK @"sfx_rockbreak.wav"
#define SFX_ELECTRIC @"sfx_electric.wav"
#define SFX_JUMPPAD @"sfx_jumppad.wav"
#define SFX_ROCKET_SPIN @"sfx_rocket_spin.wav"
#define SFX_SPEEDUP @"sfx_speedup.wav"
#define SFX_BOP @"sfx_bop.wav"
#define SFX_CHECKPOINT @"sfx_checkpoint.wav" 
#define SFX_SWING @"sfx_swing.wav" 
#define SFX_POWERUP @"sfx_powerup.wav"
#define SFX_POWERDOWN @"sfx_powerdown.wav"
#define SFX_1UP @"sfx_1up.wav"
#define SFX_BIG_EXPLOSION @"sfx_big_explosion.wav"
#define SFX_FAIL @"sfx_fail.wav"

#define SFX_WHIMPER @"sfx_whimper.wav"
#define SFX_ROCKET_LAUNCH @"sfx_rocket_launch.wav"
#define SFX_GOAL @"sfx_goal.wav"
#define SFX_ROCKET @"sfx_rocket.wav"
#define SFX_SPIKEBREAK @"sfx_spikebreak.wav"
#define SFX_BUY @"sfx_buy.wav"

#define SFX_BARK_LOW @"bark_low.wav"
#define SFX_BARK_MID @"bark_mid.wav"
#define SFX_BARK_HIGH @"bark_high.wav"

#define SFX_READY @"sfx_ready.wav"
#define SFX_GO @"sfx_go.wav"

#define SFX_BOSS_ENTER @"sfx_boss_enter.wav"
#define SFX_COPTER_FLYBY @"sfx_copter_flyby.wav"

#define SFX_MENU_UP @"sfx_menu_up.wav" 
#define SFX_MENU_DOWN @"sfx_menu_down.wav"

#define SFX_FANFARE_WIN @"sfx_fanfare_win.wav"
#define SFX_FANFARE_LOSE @"sfx_fanfare_lose.wav"

#define SFX_INTRO_NIGHT @"sfx_intro_night.wav"
#define SFX_INTRO_SNORE @"sfx_intro_snore.wav"
#define SFX_INTRO_SURPRISE @"sfx_intro_surprise.wav"

#define SFX_CAT_LAUGH @"sfx_cat_laugh.wav"
#define SFX_CAT_HIT @"sfx_cat_hit.wav" 
#define SFX_CAPE_UP @"sfx_cape_up.wav" 
#define SFX_HOMING_BEEP @"sfx_homing_beep.wav" 
#define SFX_THUNDER @"sfx_thunder.wav" 
#define SFX_FIREWORKS @"sfx_fireworks.wav"

#define SFX_CHEER @"sfx_cheer.wav" 

@class CallBack;

@interface AudioManager : NSObject

+(void)begin_load;
+(void)schedule_update; //do this on main thread

//+(void)playbgm:(BGM_GROUP)tar;
+(void)playbgm_imm:(BGM_GROUP)tar;
+(void)playbgm_file:(NSString*)file;
+(void)playsfx:(NSString*)tar;
+(void)playsfx:(NSString*)tar after_do:(CallBack*)cb;

+(void)bgm_stop;

+(BGM_GROUP) get_cur_group;

+(void)set_play_bgm:(BOOL)t;
+(void)set_play_sfx:(BOOL)t;

+(BOOL)get_play_bgm;
+(BOOL)get_play_sfx;

+(void)mute_music_for:(int)ct;

+(void)play_jingle;
+(void)todos_remove_all;
+(void)sto_prev_group;
+(void)play_prev_group;

+(void)play_invincible_for:(int)t;

#ifndef ANDROID
+(void)transition_mode1;
+(void)transition_mode2;
#endif

@end
