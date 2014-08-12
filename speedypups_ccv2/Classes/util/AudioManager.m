#ifdef ANDROID
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
	_curgroup = -1;
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

#else

#import "AudioManager.h"
#import "ObjectAL.h"
#import "Common.h"
#import "BGTimeManager.h"

@implementation AudioManager

static ALChannelSource* channel;

static OALAudioTrack *bgm_1;
static OALAudioTrack *bgm_2;
static OALAudioTrack *bgm_invincible;

static NSMutableDictionary *sfx_buffers;
static NSDictionary *bgm_groups;

static BOOL playsfx = YES;
static BOOL playbgm = YES;

+(void)initialize {
	ALDevice* device = [ALDevice deviceWithDeviceSpecifier:nil];
	ALContext* context = [ALContext contextOnDevice:device attributes:nil];
	[OpenALManager sharedInstance].currentContext = context;
	[OALAudioSession sharedInstance].handleInterruptions = YES;
	[OALAudioSession sharedInstance].allowIpod = NO;
	[OALAudioSession sharedInstance].honorSilentSwitch = YES;
	channel = [ALChannelSource channelWithSources:32];
	
	todos = [NSMutableDictionary dictionary];
}


+(void)begin_load {
#define enumkey(x) [NSNumber numberWithInt:x]
	bgm_groups = @{
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
	
	
#define BUFFERMAPGEN(x) x: [[OpenALManager sharedInstance] bufferFromFile:x]
	sfx_buffers = [[NSMutableDictionary alloc] init];
	[sfx_buffers addEntriesFromDictionary:@{
											BUFFERMAPGEN(SFX_BONE),
											BUFFERMAPGEN(SFX_BONE_2),
											BUFFERMAPGEN(SFX_BONE_3),
											BUFFERMAPGEN(SFX_BONE_4),
											
											BUFFERMAPGEN(SFX_EXPLOSION),
											BUFFERMAPGEN(SFX_HIT),
											BUFFERMAPGEN(SFX_JUMP),
											BUFFERMAPGEN(SFX_SPIN),
											BUFFERMAPGEN(SFX_SPLASH),
											BUFFERMAPGEN(SFX_BIRD_FLY),
											BUFFERMAPGEN(SFX_ROCKBREAK),
											BUFFERMAPGEN(SFX_ELECTRIC),
											BUFFERMAPGEN(SFX_JUMPPAD),
											BUFFERMAPGEN(SFX_ROCKET_SPIN),
											BUFFERMAPGEN(SFX_SPEEDUP),
											BUFFERMAPGEN(SFX_BOP),
											BUFFERMAPGEN(SFX_CHECKPOINT),
											BUFFERMAPGEN(SFX_SWING),
											BUFFERMAPGEN(SFX_POWERUP),
											BUFFERMAPGEN(SFX_POWERDOWN),
											BUFFERMAPGEN(SFX_WHIMPER),
											BUFFERMAPGEN(SFX_ROCKET_LAUNCH),
											BUFFERMAPGEN(SFX_GOAL),
											BUFFERMAPGEN(SFX_ROCKET),
											BUFFERMAPGEN(SFX_SPIKEBREAK),
											BUFFERMAPGEN(SFX_BUY),
											BUFFERMAPGEN(SFX_1UP),
											BUFFERMAPGEN(SFX_BIG_EXPLOSION),
											BUFFERMAPGEN(SFX_FAIL),
											
											BUFFERMAPGEN(SFX_BARK_LOW),
											BUFFERMAPGEN(SFX_BARK_MID),
											BUFFERMAPGEN(SFX_BARK_HIGH),
											
											BUFFERMAPGEN(SFX_READY),
											BUFFERMAPGEN(SFX_GO),
											
											BUFFERMAPGEN(SFX_BOSS_ENTER),
											BUFFERMAPGEN(SFX_COPTER_FLYBY),
											
											BUFFERMAPGEN(SFX_MENU_DOWN),
											BUFFERMAPGEN(SFX_MENU_UP),
											
											BUFFERMAPGEN(SFX_FANFARE_WIN),
											BUFFERMAPGEN(SFX_FANFARE_LOSE),
											
											BUFFERMAPGEN(SFX_INTRO_NIGHT),
											BUFFERMAPGEN(SFX_INTRO_SNORE),
											BUFFERMAPGEN(SFX_INTRO_SURPRISE),
											
											BUFFERMAPGEN(SFX_CAT_LAUGH),
											BUFFERMAPGEN(SFX_CAT_HIT),
											BUFFERMAPGEN(SFX_CAPE_UP),
											BUFFERMAPGEN(SFX_HOMING_BEEP),
											BUFFERMAPGEN(SFX_THUNDER),
											BUFFERMAPGEN(SFX_FIREWORKS),
											BUFFERMAPGEN(SFX_CHEER)
											}];
	
	bgm_1 = [OALAudioTrack track];
	bgm_2 = [OALAudioTrack track];
	bgm_invincible = [OALAudioTrack track];
	
	for (NSNumber *key in [bgm_groups keyEnumerator]) {
		NSArray *val = bgm_groups[key];
		if (val.count >= 1) [bgm_1 preloadFile:val[0]];
		if (val.count >= 2) [bgm_2 preloadFile:val[1]];
	}
	[bgm_invincible preloadFile:BGMUSIC_INVINCIBLE];
}

+(void)schedule_update {
	[[CCScheduler sharedScheduler] scheduleSelector:@selector(update) forTarget:self interval:0.2 paused:NO];
}

+(void)set_play_bgm:(BOOL)t {
	playbgm = t;
	if (t == NO) {
		[self stop_bgm];
	}
}

+(void)stop_bgm {
	[bgm_1 stop];
	[bgm_2 stop];
}

+(void)set_play_sfx:(BOOL)t {
	playsfx = t;
}

+(BOOL)get_play_bgm {
	return playbgm;
}

+(BOOL)get_play_sfx {
	return playsfx;
}

static BGM_GROUP curgroup;
static float bgm_1_gain_tar;
static float bgm_2_gain_tar;

//static BGM_GROUP transition_target;

+(BGM_GROUP) get_cur_group { return curgroup; }

//im pretty sure this is broken lol
/*
 +(void)playbgm:(BGM_GROUP)tar {
 if (playbgm == NO) return;
 if (curgroup == tar) return;
 
 curgroup = tar;
 
 if (![bgm_1 playing] && ![bgm_2 playing]) {
 [self playbgm_imm:tar];
 } else {
 transition_target = tar;
 transition_ct = 10;
 }
 }
 */

+(void)playbgm_imm:(BGM_GROUP)tar {
	[self todos_remove_all];
	if (playbgm == NO) return;
	
	[bgm_1 stop];
	[bgm_2 stop];
	
	curgroup = tar;
	bgm_1_gain_tar = 1;
	bgm_2_gain_tar = 0;
	
	if (_play_invincible <= 0) {
		[bgm_1 setGain:bgm_1_gain_tar];
		[bgm_2 setGain:bgm_2_gain_tar];
	}
	
	NSArray *val = bgm_groups[enumkey(tar)];
	if (val.count >= 1) [bgm_1 playFile:val[0] loops:-1];
	if (val.count >= 2) [bgm_2 playFile:val[1] loops:-1];
}

+(void)playbgm_file:(NSString *)file {
	[self todos_remove_all];
	if (playbgm == NO) return;
	[bgm_1 stop];
	[bgm_2 stop];
	bgm_1_gain_tar = 1;
	bgm_2_gain_tar = 0;
	_play_invincible = 0;
	[bgm_1 playFile:file loops:-1];
}

+(void)bgm_stop {
	[bgm_1 stop];
	[bgm_2 stop];
}

+(void)transition_mode1 {
	NSArray *val = bgm_groups[enumkey(curgroup)];
	if (val.count >= 1) {
		bgm_1_gain_tar = 1;
		bgm_2_gain_tar = 0;
	} else {
		//NSLog(@"bgm group %d does not have mode1",curgroup);
	}
	
}

+(void)transition_mode2 {
	NSArray *val = bgm_groups[enumkey(curgroup)];
	if (val.count >= 2) {
		bgm_1_gain_tar = 0;
		bgm_2_gain_tar = 1;
	} else {
		//NSLog(@"bgm group %d does not have mode2",curgroup);
	}
}

+(void)playsfx:(NSString*)tar {
	if (playsfx == NO) return;
	if (sfx_buffers[tar]) [channel play:sfx_buffers[tar]];
}

static bool todos_remove_all = NO;
static float audiomanager_time = 0;
static NSMutableDictionary *todos;
+(void)playsfx:(NSString*)tar after_do:(CallBack*)cb {
	[self playsfx:tar];
	todos[[NSNumber numberWithFloat:audiomanager_time+[(ALBuffer*)sfx_buffers[tar] duration]]] = cb;
}

static int mute_music_ct = 0;
static float sto_bgm1_gain = 0, sto_bgm2_gain = 0;
+(void)mute_music_for:(int)ct {
	mute_music_ct = ct;
	sto_bgm1_gain = [bgm_1 gain];
	sto_bgm2_gain = [bgm_2 gain];
}

static int _play_invincible = 0;
static float _invincible_start_bgm1_gain = 0.0, _invincible_start_bgm2_gain;
+(void)play_invincible_for:(int)t {
	if (!playbgm) return;
	int prev_play_invincible = _play_invincible;
	_play_invincible = t;
	_invincible_start_bgm1_gain = [bgm_1 gain];
	_invincible_start_bgm2_gain = [bgm_2 gain];
	if (prev_play_invincible <= 0) {
		[bgm_1 setGain:0];
		[bgm_2 setGain:0];
		[bgm_invincible playFile:BGMUSIC_INVINCIBLE loops:-1];
	}
}

+(void)update {
	if (todos_remove_all) {
		[todos removeAllObjects];
		todos_remove_all = NO;
	}
	
	audiomanager_time += 0.2;
	for (NSNumber *time in [todos keyEnumerator]) {
		if (time.doubleValue <= audiomanager_time) {
			CallBack *cb = todos[time];
			[Common run_callback:cb];
			[todos removeObjectForKey:time];
		}
	}
	
	if (mute_music_ct > 0) {
		mute_music_ct--;
		if (mute_music_ct > 0) {
			[bgm_1 setGain:0];
			[bgm_2 setGain:0];
		} else {
			[bgm_1 setGain:sto_bgm1_gain];
			[bgm_2 setGain:sto_bgm2_gain];
		}
	}
	
	if (_play_invincible > 0) {
		_play_invincible--;
		if (_play_invincible <= 0) {
			[bgm_invincible stop];
			[bgm_1 setGain:_invincible_start_bgm1_gain];
			[bgm_2 setGain:_invincible_start_bgm2_gain];
			
		} else {
			return;
			
		}
	}
	
	if (ABS([bgm_1 gain]-bgm_1_gain_tar) >= 0.01) {
		float sign = [Common sig:bgm_1_gain_tar-[bgm_1 gain]];
		[bgm_1 setGain:[bgm_1 gain] + sign*0.1];
	} else {
		[bgm_1 setGain:bgm_1_gain_tar];
	}
	
	if (ABS([bgm_2 gain]-bgm_2_gain_tar) >= 0.01) {
		float sign = [Common sig:bgm_2_gain_tar-[bgm_2 gain]];
		[bgm_2 setGain:[bgm_2 gain] + sign*0.1];
	} else {
		[bgm_2 setGain:bgm_2_gain_tar];
	}
	
}


+(void)play_jingle{ [AudioManager playbgm_imm:BGM_GROUP_JINGLE]; }

+(void)todos_remove_all {
	todos_remove_all = YES;
}

static BGM_GROUP prev_group;
+(void)sto_prev_group {
	prev_group = [self get_cur_group];
}
+(void)play_prev_group {
	[self playbgm_imm:prev_group];
	if ([BGTimeManager get_global_time] == MODE_NIGHT || [BGTimeManager get_global_time] == MODE_DAY_TO_NIGHT) {
		[AudioManager transition_mode2];
	}
}

@end


#endif