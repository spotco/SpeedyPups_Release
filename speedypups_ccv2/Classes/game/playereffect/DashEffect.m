#import "DashEffect.h"
#import "GameEngineLayer.h"
#import "JumpPadParticle.h"

@implementation DashEffect {
	BOOL no_post_track;
}

@synthesize vx,vy;

+(DashEffect*)cons_from:(PlayerEffectParams*)base vx:(float)vx vy:(float)vy {
    DashEffect *n = [[DashEffect alloc] init];
    [PlayerEffectParams copy_params_from:base to:n];
    
    n.vx = vx;
    n.vy = vy;
    
    n.time_left = [self dash_effect_length];
    n.cur_gravity = 0;
    return n;
}

+(int)dash_effect_length {
    int rtv;
    if ([Player current_character_has_power:CharacterPower_LONGDASH]) {
        rtv = 45 * 1/[Common get_dt_Scale];
    } else {
        rtv = 30 * 1/[Common get_dt_Scale];
    }
	return rtv;
}

-(id)set_no_post_track {
	no_post_track = YES;
	return self;
}

-(void)update:(Player*)p g:(GameEngineLayer *)g{
	self.player = p;
    if (p.current_island != NULL) {
        Vec3D t = [p.current_island get_tangent_vec];
        self.vx = t.x;
        self.vy = t.y;
    } else {
		
		if (no_post_track == NO) {
			if ([GameControlImplementation get_post_swipe_drag].x  != 0 && [GameControlImplementation get_post_swipe_drag].y != 0) {
				Vec3D post_dir = [VecLib normalize:[VecLib cons_x:MAX(0,[GameControlImplementation get_post_swipe_drag].x) y:[GameControlImplementation get_post_swipe_drag].y z:0]];
				Vec3D cur_dir = [VecLib cons_x:self.vx y:self.vy z:0];
				
				Vec3D final_dir = [VecLib normalized_x:cur_dir.x+post_dir.x*0.2 y:cur_dir.y+post_dir.y*0.2 z:0];
				self.vx = final_dir.x;
				self.vy = final_dir.y;
			}
		}
        p.vx = self.vx*12;
        p.vy = self.vy*12;
    }
}



-(player_anim_mode)get_anim {
    return player_anim_mode_DASH;
}

-(NSString*)info {
    return [NSString stringWithFormat:@"DashEffect(timeleft:%i)",time_left];
}


@end
