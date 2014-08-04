#import "AudioManager.h"
#import "Common.h"
#import "BGTimeManager.h"
#import "FISoundEngine.h"
#import "SoundManager.h"

@interface QueuedSfxCallback : NSObject
@property(readwrite,strong) FISound *sound;
@property(readwrite,strong) CallBack *callback;
@property(readwrite,assign) float duration_left;
@end
@implementation QueuedSfxCallback
@synthesize sound;
@synthesize callback;
@synthesize duration_left;
+(QueuedSfxCallback*)cons_sound:(FISound*)sound callback:(CallBack*)callback {
	QueuedSfxCallback *rtv = [[QueuedSfxCallback alloc] init];
	rtv.sound = sound;
	rtv.callback = callback;
	rtv.duration_left = sound.duration;
	return rtv;
}
@end


@implementation AudioManager : NSObject

static NSMutableDictionary *_sounds;
static FISoundEngine *_sound_engine;
static NSDictionary *_bgm_groups;

static NSMutableArray *_queued_callbacks;

+(void)begin_load{
	_sounds = [NSMutableDictionary dictionary];
	_sound_engine = [FISoundEngine sharedEngine];
	
	_queued_callbacks = [NSMutableArray array];
	
	#define enumkey(x) [NSNumber numberWithInt:x]
	_bgm_groups = @{
		enumkey(BGM_GROUP_WORLD1):@[
			   BGMUSIC_GAMELOOP1,
			   BGMUSIC_GAMELOOP1_NIGHT
			],
		enumkey(BGM_GROUP_LAB):@[
			   BGMUSIC_LAB1
			],
		enumkey(BGM_GROUP_MENU):@[
			   BGMUSIC_MENU1
			],
		enumkey(BGM_GROUP_BOSS1):@[
			   BGMUSIC_BOSS1
			],
		enumkey(BGM_GROUP_JINGLE):@[
			   BGMUSIC_JINGLE
			],
		enumkey(BGM_GROUP_WORLD2):@[
			   BGMUSIC_GAMELOOP2,
			   BGMUSIC_GAMELOOP2_NIGHT
			],
		enumkey(BGM_GROUP_WORLD3):@[
			   BGMUSIC_GAMELOOP3,
			   BGMUSIC_GAMELOOP3_NIGHT
			],
		enumkey(BGM_GROUP_CAPEGAME):@[
			   BGMUSIC_CAPEGAMELOOP
			],
		enumkey(BGM_GROUP_INTRO):@[
			   BGMUSIC_INTRO
			]
	};
	
	#define BUFFERMAPGEN(x) [_sounds setObject:[_sound_engine soundNamed:x maxPolyphony:4 error:NULL] forKey:x]
	BUFFERMAPGEN(SFX_BONE);
	BUFFERMAPGEN(SFX_BONE_2);
	BUFFERMAPGEN(SFX_BONE_3);
	BUFFERMAPGEN(SFX_BONE_4);
	BUFFERMAPGEN(SFX_EXPLOSION);
	BUFFERMAPGEN(SFX_HIT);
	BUFFERMAPGEN(SFX_JUMP);
	BUFFERMAPGEN(SFX_SPIN);
	BUFFERMAPGEN(SFX_SPLASH),
	BUFFERMAPGEN(SFX_BIRD_FLY);
	BUFFERMAPGEN(SFX_ROCKBREAK);
	BUFFERMAPGEN(SFX_ELECTRIC);
	BUFFERMAPGEN(SFX_JUMPPAD);
	BUFFERMAPGEN(SFX_ROCKET_SPIN);
	BUFFERMAPGEN(SFX_SPEEDUP);
	BUFFERMAPGEN(SFX_BOP);
	BUFFERMAPGEN(SFX_CHECKPOINT);
	BUFFERMAPGEN(SFX_SWING);
	BUFFERMAPGEN(SFX_POWERUP);
	BUFFERMAPGEN(SFX_POWERDOWN);
	BUFFERMAPGEN(SFX_WHIMPER);
	BUFFERMAPGEN(SFX_ROCKET_LAUNCH);
	BUFFERMAPGEN(SFX_GOAL);
	BUFFERMAPGEN(SFX_ROCKET);
	BUFFERMAPGEN(SFX_SPIKEBREAK);
	BUFFERMAPGEN(SFX_BUY);
	BUFFERMAPGEN(SFX_1UP);
	BUFFERMAPGEN(SFX_BIG_EXPLOSION);
	BUFFERMAPGEN(SFX_FAIL);
	BUFFERMAPGEN(SFX_BARK_LOW);
	BUFFERMAPGEN(SFX_BARK_MID);
	BUFFERMAPGEN(SFX_BARK_HIGH);
	BUFFERMAPGEN(SFX_READY);
	BUFFERMAPGEN(SFX_GO);
	BUFFERMAPGEN(SFX_BOSS_ENTER);
	BUFFERMAPGEN(SFX_COPTER_FLYBY);
	BUFFERMAPGEN(SFX_MENU_DOWN);
	BUFFERMAPGEN(SFX_MENU_UP);
	BUFFERMAPGEN(SFX_FANFARE_WIN);
	BUFFERMAPGEN(SFX_FANFARE_LOSE);
	BUFFERMAPGEN(SFX_INTRO_NIGHT);
	BUFFERMAPGEN(SFX_INTRO_SNORE);
	BUFFERMAPGEN(SFX_INTRO_SURPRISE);
	BUFFERMAPGEN(SFX_CAT_LAUGH);
	BUFFERMAPGEN(SFX_CAT_HIT);
	BUFFERMAPGEN(SFX_CAPE_UP);
	BUFFERMAPGEN(SFX_HOMING_BEEP);
	BUFFERMAPGEN(SFX_THUNDER);
	BUFFERMAPGEN(SFX_FIREWORKS);
	BUFFERMAPGEN(SFX_CHEER);
}

static BOOL _playsfx = YES;
static BOOL _playbgm = YES;

static BGM_GROUP _curgroup;

+(void)schedule_update{
	[[CCScheduler sharedScheduler] scheduleSelector:@selector(update:) forTarget:self interval:0.05 paused:NO];
}

static Sound *_bgm_1, *_bgm_2, *_bgm_3;
static float _bgm_1_tar_gain, _bgm_2_tar_gain, _bgm_3_tar_gain;

+(void)playbgm_imm:(BGM_GROUP)tar{
	[self todos_remove_all];
	if (_curgroup != tar) {
		[self bgm_stop];
		_curgroup = tar;
		NSArray *srcs = [_bgm_groups objectForKey:enumkey(tar)];
		if (srcs.count >= 1) {
			_bgm_1 = [Sound soundNamed:srcs[0]];
		} else {
			_bgm_1 = NULL;
		}
		if (srcs.count >= 2) {
			_bgm_2 = [Sound soundNamed:srcs[1]];
		} else {
			_bgm_2 = NULL;
		}
		_bgm_3 = [Sound soundNamed:BGMUSIC_INVINCIBLE];
		[self conditional_mute];
		
		_bgm_1.looping = YES;
		_bgm_2.looping = YES;
		_bgm_3.looping = YES;
		
		if ((([BGTimeManager get_global_time] == MODE_NIGHT) || [BGTimeManager get_global_time] == MODE_NIGHT_TO_DAY) && _bgm_2) {
			_bgm_1_tar_gain = 0;
			_bgm_2_tar_gain = 1;
			_bgm_3_tar_gain = 0;
			
			_bgm_1.volume = 0;
			_bgm_2.volume = 1;
			_bgm_3.volume = 0;
		} else {
			_bgm_1_tar_gain = 1;
			_bgm_2_tar_gain = 0;
			_bgm_3_tar_gain = 0;
			
			_bgm_1.volume = 1;
			_bgm_2.volume = 0;
			_bgm_3.volume = 0;
		}
		
		if (_playbgm) {
			[_bgm_1 play];
			[_bgm_2 play];
			[_bgm_3 play];
		}

	}
}
+(void)playbgm_file:(NSString*)file{
	[self bgm_stop];
	_bgm_1 = [Sound soundNamed:file];
	[_bgm_1 play];
	[self conditional_mute];
}


+(void)playsfx:(NSString*)tar{
	if (!_playsfx) return;
	FISound *snd = [_sounds objectForKey:tar];
	if (snd) [snd play];
}

+(void)playsfx:(NSString*)tar after_do:(CallBack*)cb{
	FISound *snd = [_sounds objectForKey:tar];
	if (snd) {
		[_queued_callbacks addObject:[QueuedSfxCallback cons_sound:snd callback:cb]];
		if (_playsfx) [snd play];
	}
}

+(void)update:(ccTime)dt {
	NSMutableArray *to_remove = [NSMutableArray array];
	for (QueuedSfxCallback *i in _queued_callbacks) {
		i.duration_left -= dt;
		if (i.duration_left <= 0) {
			[to_remove addObject:i];
			[Common run_callback:i.callback];
		}
	}
	[_queued_callbacks removeObjectsInArray:to_remove];
	
	if ((([BGTimeManager get_global_time] == MODE_NIGHT) || [BGTimeManager get_global_time] == MODE_NIGHT_TO_DAY) && _bgm_2) {
		_bgm_1_tar_gain = 0;
		_bgm_2_tar_gain = 1;
		_bgm_3_tar_gain = 0;

	} else {
		_bgm_1_tar_gain = 1;
		_bgm_2_tar_gain = 0;
		_bgm_3_tar_gain = 0;
		
	}
	
	float use_bgm_1_tar_gain = _bgm_1_tar_gain;
	float use_bgm_2_tar_gain = _bgm_2_tar_gain;
	float use_bgm_3_tar_gain = _bgm_3_tar_gain;
	
	if (_mute_ct > 0) {
		_mute_ct--;
		use_bgm_1_tar_gain = 0;
		use_bgm_2_tar_gain = 0;
		use_bgm_3_tar_gain = 0;
	
	} else if (_invincible_ct > 0) {
		_invincible_ct--;
		use_bgm_1_tar_gain = 0;
		use_bgm_2_tar_gain = 0;
		use_bgm_3_tar_gain = 1;
	}
	
	_bgm_1.volume = drp(_bgm_1.volume, use_bgm_1_tar_gain, 10);
	_bgm_2.volume = drp(_bgm_2.volume, use_bgm_2_tar_gain, 10);
	_bgm_3.volume = drp(_bgm_3.volume, use_bgm_3_tar_gain, 10);
	
	[self conditional_mute];
}

+(void)conditional_mute {
	if (!_playbgm) {
		_bgm_1.volume = 0;
		_bgm_2.volume = 0;
		_bgm_3.volume = 0;
	}
}

+(void)bgm_stop{
	if (_bgm_1) [_bgm_1 stop];
	if (_bgm_2) [_bgm_2 stop];
	if (_bgm_3) [_bgm_3 stop];
}

+(BGM_GROUP) get_cur_group{
	return _curgroup;
}

+(void)set_play_bgm:(BOOL)t{
	_playbgm = t;
	if (_playbgm && !_bgm_1.playing) {
		[_bgm_1 play];
	}
}
+(void)set_play_sfx:(BOOL)t{
	_playsfx = t;
}

+(BOOL)get_play_bgm{return _playbgm;}
+(BOOL)get_play_sfx{return _playsfx;}

static int _mute_ct = 0;
+(void)mute_music_for:(int)ct{
	_mute_ct = ct;
}

static int _invincible_ct = 0;
+(void)play_invincible_for:(int)t{
	_invincible_ct = t;
}

+(void)play_jingle{
	[self playbgm_imm:BGM_GROUP_JINGLE];
}
+(void)todos_remove_all{
	[_queued_callbacks removeAllObjects];
}

static BGM_GROUP _prev_group;
+(void)sto_prev_group {
	_prev_group = [self get_cur_group];
}
+(void)play_prev_group {
	[self playbgm_imm:_prev_group];
}
@end