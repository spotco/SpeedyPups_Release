#import "GameControlImplementation.h"
#import "GameEngineLayer.h"
#import "GEventDispatcher.h"
#import "SwingVine.h"
#import "JumpParticle.h"
#import "DogRocketEffect.h"
#import "Cannon.h"
#import "LauncherRobot.h"
#import "ScoreManager.h"

#define JUMP_HOLD_TIME 15
#define JUMP_POWER 9
#define HIGHER_JUMP_POWER 10.5
#define JUMP_FLOAT_SCALE 1

@implementation GameControlImplementation

static bool itembutton_hold = NO;
+(BOOL)get_clockbutton_hold {
	return itembutton_hold;
}
+(void)set_clockbutton_hold:(BOOL)hold {
	if (hold) {
		[AudioManager playsfx:SFX_POWERUP];
	} else {
		[AudioManager playsfx:SFX_POWERDOWN];
	}
	itembutton_hold = hold;
}

static BOOL queue_swipe = NO;
static CGPoint swipe_dir;
static BOOL queue_jump = NO;
static int jump_hold_timer = 0;

static BOOL is_touch_down = NO;
static int touch_timer = 0;
static int touch_move_counter = 0;
static float touch_dist_sum = 0;
static CGPoint prev;

+(void)touch_begin:(CGPoint)pt {
    is_touch_down = YES;
    touch_move_counter = 0;
    touch_dist_sum = 0;
    touch_timer = 0;
    prev = pt;
    
    queue_jump = YES;
	
	post_swipe_drag = CGPointZero;
	
	this_swipe_dashed = NO;
}

static float avg_x;
static float avg_y;

static CGPoint post_swipe_drag;
static int last_jump;
static BOOL this_swipe_dashed = NO;

+(CGPoint)get_post_swipe_drag {
	return post_swipe_drag;
}

+(void)touch_move:(CGPoint)pt {
    touch_move_counter++;
    touch_dist_sum += [Common distanceBetween:prev and:pt];
    
    avg_x += pt.x-prev.x;
    avg_y -= pt.y-prev.y;
	post_swipe_drag.x += pt.x-prev.x;
	post_swipe_drag.y -= pt.y-prev.y;
    
    if(touch_move_counter == 3) {
        float avg = touch_dist_sum/touch_move_counter;
        if (avg > 6) {
            Vec3D v = [VecLib cons_x:avg_x y:avg_y z:0];
            v = [VecLib normalize:v];
            
            if (ABS([VecLib get_angle_in_rad:v]) < M_PI*(3.0/4.0) && this_swipe_dashed == NO) {
                queue_swipe = YES;
                swipe_dir = ccp(ABS(v.x),v.y);
				post_swipe_drag = CGPointZero;
            }
        }
		
        touch_move_counter = 0;
        touch_dist_sum = 0;
        avg_x = 0;
        avg_y = 0;
	}
    prev = pt;
}

+(void)touch_end:(CGPoint)pt {
    is_touch_down = NO;
    touch_timer = 0;
	post_swipe_drag = CGPointZero;
}

float nodash_time = 0;
+(void)set_nodash_time:(int)t {
	nodash_time = t;
}

+(void)control_update_player:(GameEngineLayer*)g {
    Player* player = g.player;
	
	nodash_time = nodash_time <= 0 ? 0 : nodash_time - [Common get_dt_Scale];
	
    if (player.dead){
        return;
    }
	
	if ([[player get_current_params] class] == [DogRocketEffect class]) {
		if (is_touch_down && player.current_island == NULL) {
			player.vy = clampf(player.vy+1*[Common get_dt_Scale], player.vy, 9);
		
		} else if (is_touch_down && player.current_island != NULL) {
			[self player_jump_from_island:player override:YES override_power:3];
			
		}
	}
	
	if (player.current_cannon != NULL && (queue_jump)) {
		
		[g.score increment_multiplier:0.001];
		[g.score increment_score:5];
		
		[AudioManager playsfx:SFX_ROCKET_LAUNCH];
		Vec3D dir = [VecLib cons_x:player.current_cannon.dir.x y:player.current_cannon.dir.y z:0];
		dir = [VecLib scale:dir by:25];
		player.vx = dir.x;
		player.vy = dir.y;
		[LauncherRobot explosion:g at:[player.current_cannon get_nozzel_position:player]];
		[player.current_cannon detach_player];
		[player.current_cannon deactivate_for:20];
		player.current_cannon = NULL;
		player.up_vec  = [VecLib cons_x:0 y:1 z:0];
		[player remove_temp_params:g];
		[player add_effect:[[DashEffect cons_from:[player get_default_params] vx:dir.x/12.0 vy:dir.y/12.0] set_no_post_track]];
		queue_jump = NO;
		queue_swipe = NO;
		[GEventDispatcher push_event:[GEvent cons_type:GEventType_JUMP]];
		
		return;
	}
	if (player.current_cannon != NULL) return;
    
    if (player.current_swingvine != NULL && (queue_jump || queue_swipe)) {
        CGPoint t_vel = [player.current_swingvine get_tangent_vel];
        [player.current_swingvine temp_disable];
        player.current_swingvine = NULL;
        player.up_vec  = [VecLib cons_x:0 y:1 z:0];
        
        player.vx = t_vel.x;
        player.vy = t_vel.y;
        
        [[player get_current_params] add_airjump_count];
		
		queue_jump = NO;
		queue_swipe = NO;
    }
    
    if (player.current_island != NULL) {
        [[player get_current_params] add_airjump_count];
    }
    
    if (queue_swipe == YES &&
		player.current_island == NULL &&
		[player get_current_params].cur_dash_count > 0 &&
		player.dashing == NO &&
		nodash_time <= 0) {
		
		if (last_jump < 10) {
			[[player get_current_params] decr_airjump_count];
			if ([player get_current_params] != NULL && [player get_current_params] != [player get_default_params]) {
				PlayerEffectParams *p = [player get_current_params];
				p.cur_airjump_count++;
				
			} else if ([player get_default_params] != NULL) {
				PlayerEffectParams *p = [player get_default_params];
				p.cur_airjump_count++;
			}
		}
		
        [GameControlImplementation player_dash:player];
        [GEventDispatcher push_event:[GEvent cons_type:GEventType_DASH]];
        [g.get_stats increment:GEStat_DASHED];
		this_swipe_dashed = YES;
    }
    queue_swipe = NO;
    
    
    if (queue_jump == YES &&
		![[player get_current_params] isKindOfClass:[DashEffect class]] &&
		[[player get_current_params] class] != [DogRocketEffect class]) {
        
        if (player.current_island != NULL) {
			
			[g add_particle:[JumpParticle cons_pt:player.position
											  vel:ccp([player.current_island get_tangent_vec].x,[player.current_island get_tangent_vec].y)
											   up:ccp([player.current_island get_normal_vecC].x,[player.current_island get_normal_vecC].y)]];
            
            [GameControlImplementation player_jump_from_island:player];
            
            jump_hold_timer = JUMP_HOLD_TIME;
            
            
            [[player get_current_params] decr_airjump_count];
            [GEventDispatcher push_event:[GEvent cons_type:GEventType_JUMP]];
            [g.get_stats increment:GEStat_JUMPED];
			
			last_jump = 0;
			
        } else if ([player get_current_params].cur_airjump_count > 0) {
            [GameControlImplementation player_double_jump:player];
            
            jump_hold_timer = JUMP_HOLD_TIME;
            
            [[player get_current_params] decr_airjump_count];
            [GEventDispatcher push_event:[GEvent cons_type:GEventType_JUMP]];
			[g add_particle:[JumpParticle cons_pt:player.position vel:ccp(player.vx,player.vy) up:ccp(player.up_vec.x,player.up_vec.y)]];
			[g.get_stats increment:GEStat_JUMPED];
			
			last_jump = 0;
            
        }
    }
	last_jump++;
	
    queue_jump = NO;
    
    
    
    if (is_touch_down && jump_hold_timer > 0) { //hold to jump higher
        jump_hold_timer--;
        float pct_left = ((float)jump_hold_timer)/((float)JUMP_HOLD_TIME);
        float scale = JUMP_FLOAT_SCALE;
        player.vx += player.up_vec.x *pct_left*scale;
        player.vy += player.up_vec.y *pct_left*scale;
        player.floating = NO;
    } 
    
    if (player.current_island != NULL) {
        touch_timer = 0;
    } else if (is_touch_down) {
        touch_timer++;
    }
        
    if (is_touch_down && touch_timer > (23/[Common get_dt_Scale]) && player.current_island == NULL) { //hold to float
        player.floating = YES;
    } else {
        player.floating = NO;
    }
}

+(void)player_dash:(Player*)player {
    [AudioManager playsfx:SFX_SPIN];
    [[player get_current_params] decr_dash_count];
    [player add_effect:[DashEffect cons_from:[player get_default_params] vx:swipe_dir.x vy:swipe_dir.y]];
}


+(void)player_double_jump:(Player*)player {
    [AudioManager playsfx:SFX_JUMP];
    
    if ([Player current_character_has_power:CharacterPower_HIGHERJUMP]) {
        player.vx += player.up_vec.x*JUMP_POWER;
        player.vy = player.up_vec.y*HIGHER_JUMP_POWER;
        
    } else {
        player.vx += player.up_vec.x*JUMP_POWER;
        player.vy = player.up_vec.y*JUMP_POWER;
        
    }
    player.current_swingvine = NULL;
}

+(void)reset_control_state {
    queue_swipe = NO;
    queue_jump = NO;
    jump_hold_timer = 0;
    
    is_touch_down = NO;
    touch_timer = 0;
    touch_move_counter = 0;
    touch_dist_sum = 0;
}

+(void)player_jump_from_island:(Player*)player {
	[self player_jump_from_island:player override:NO override_power:0];
}

+(void)player_jump_from_island:(Player*)player override:(BOOL)override override_power:(float)override_power {
    [AudioManager playsfx:SFX_JUMP];
    
    float mov_speed = sqrtf(powf(player.vx, 2) + powf(player.vy, 2));
    
    Vec3D tangent = [player.current_island get_tangent_vec];
    Vec3D up = [VecLib cross:[VecLib Z_VEC] with:tangent];
    tangent = [VecLib normalize:tangent];
    up = [VecLib normalize:up];
    if (player.current_island.ndir == -1) {
        up = [VecLib scale:up by:-1];
    }
    
    tangent = [VecLib scale:tangent by:mov_speed];
	if (override) {
		up = [VecLib scale:up by:override_power];
    } else if ([Player current_character_has_power:CharacterPower_HIGHERJUMP]) {
        up = [VecLib scale:up by:HIGHER_JUMP_POWER];
    } else {
        up = [VecLib scale:up by:JUMP_POWER];
    }

    Vec3D combined = [VecLib add:up to:tangent];
    Vec3D cur_tangent_vec = [player.current_island get_tangent_vec];
    Vec3D calc_up = [VecLib cross:[VecLib Z_VEC] with:cur_tangent_vec];
    calc_up = [VecLib scale:calc_up by:2];
    player.position = [VecLib transform_pt:player.position by:calc_up];
	
    combined.x = SIG(combined.x)*MIN(14,ABS(combined.x));
	combined.y = SIG(combined.y)*MIN(14,ABS(combined.y));
    //combined.x = MAX(tangent.x,combined.x);
    
    player.vx = combined.x;
    player.vy = combined.y;
    player.current_island = NULL;
    player.current_swingvine = NULL;
    
    
}

@end
