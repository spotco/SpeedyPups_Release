#import "PlayerEffectParams.h"
#import "GameEngineLayer.h"

@implementation PlayerEffectParams

@synthesize cur_gravity,cur_airjump_count,time_left,cur_dash_count;
@synthesize noclip;
@synthesize player;


+(PlayerEffectParams*)cons_copy:(PlayerEffectParams*)p {
    PlayerEffectParams *n = [[PlayerEffectParams alloc] init];
    [PlayerEffectParams copy_params_from:p to:n];
    return n;
}

+(void)copy_params_from:(PlayerEffectParams *)a to:(PlayerEffectParams *)b {
    b.cur_gravity = -0.5;
    b.cur_airjump_count = a.cur_airjump_count;
    b.cur_dash_count = a.cur_dash_count;
	b.player = a.player;
}

-(void)decrement_timer {
    if (time_left > 0) {
        time_left--;
    }
}

-(void)add_airjump_count {
    if ([Player current_character_has_power:CharacterPower_TRIPLEJUMP]) {
        cur_airjump_count = 3;
    } else {
        cur_airjump_count = 2;
    }
    if ([Player current_character_has_power:CharacterPower_DOUBLEDASH]) {
        cur_dash_count = 2;
    } else {
        cur_dash_count = 1;
    }
}

-(void)decr_dash_count {
	if (player != NULL) {
		if ([player get_current_params] != NULL && [player get_current_params] != [player get_default_params]) {
			PlayerEffectParams *p = [player get_current_params];
			if (p.cur_dash_count > 0) p.cur_dash_count--;
		}
		if ([player get_default_params] != NULL) {
			PlayerEffectParams *p = [player get_default_params];
			if (p.cur_dash_count > 0) p.cur_dash_count--;
		}
	} else {
		NSLog(@"decr_dash_count player null please set it in update");
	}
}

-(void)decr_airjump_count {
	if ([player get_current_params] != NULL && [player get_current_params] != [player get_default_params]) {
		PlayerEffectParams *p = [player get_current_params];
		if (p.cur_airjump_count > 0) p.cur_airjump_count--;
	}
	if ([player get_default_params] != NULL) {
		PlayerEffectParams *p = [player get_default_params];
		if (p.cur_airjump_count > 0) p.cur_airjump_count--;
	} else {
		NSLog(@"decr_airjump_count player please set it in update");
	}
}

-(player_anim_mode)get_anim {
    return player_anim_mode_RUN_FAST;
}

-(void)update:(Player*)p g:(GameEngineLayer *)g{
	player = p;
}

-(NSString*)info {
    return [NSString stringWithFormat:@"DefaultEffect(timeleft:%i)",time_left];
}

-(void)effect_end{
}

-(BOOL)is_also_dashing {
    return NO;
}

-(void)effect_begin:(Player *)p {}

@end
