#import "DogRocketEffect.h"
#import "GEventDispatcher.h"
#import "GameItemCommon.h"
#import "AudioManager.h"

@implementation DogRocketEffect

+(DogRocketEffect*)cons_from:(PlayerEffectParams*)base time:(int)time {
    DogRocketEffect *n = [[DogRocketEffect alloc] init];
    [PlayerEffectParams copy_params_from:base to:n];
    n.time_left = time;
    [n recft];
    n.cur_airjump_count = 2;
	n.cur_dash_count = 2;
    n.cur_gravity = -0.5;
    return n;
}

-(void)recft {
    fulltime = time_left;
}

-(void)update:(Player*)p g:(GameEngineLayer *)g{
	self.player = p;
	
	[AudioManager play_invincible_for:2];
	
	Vec3D vdir_vec = [VecLib cons_x:30 y:p.vy z:0];
	if (p.current_island == NULL) [p setRotation:[VecLib get_rotation:vdir_vec offset:0]+180];
	
    if (p.vx < 20) {
        p.vx += 1 * [Common get_dt_Scale];
		
    } else if (p.vx > 20) {
		p.vx -= (p.vx-20)/10.0;
		
	}
	
	sound_ct -= [Common get_dt_Scale];
	if (sound_ct <= 0) {
		[AudioManager playsfx:SFX_ROCKET];
		sound_ct = 20;
	}
	
    [GEventDispatcher push_event:[[[GEvent cons_type:GEventType_ITEM_DURATION_PCT] add_f1:((float)time_left)/fulltime f2:0] add_i1:Item_Rocket i2:0]];
}

-(void)effect_end {
    [GEventDispatcher push_event:[[[[GEvent cons_type:GEventType_ITEM_DURATION_PCT] add_f1:0 f2:0] add_i1:Item_Rocket i2:0] add_i1:Item_Rocket i2:0]];
	[AudioManager playsfx:SFX_POWERDOWN];
}

-(player_anim_mode)get_anim {
    return player_anim_mode_ROCKET;
}

-(NSString*)info {
    return [NSString stringWithFormat:@"DogRocketEffect(timeleft:%i)",time_left];
}

-(BOOL)is_also_dashing {
    return YES;
}

@end
