#import "CapeGameBossCat.h"
#import "Resource.h"
#import "FileCache.h"
#import "VolleyRobotBossComponents.h"
#import "CapeGameBossBomb.h"
#import "AudioManager.h"
#import "CapeGamePlayer.h"
#import "ExplosionParticle.h"
#import "RocketParticle.h"
#import "GameMain.h"
#import "ScoreManager.h"

@interface CapeGameBossRobotHead : CapeGameObject {
	int particle_ct;
	BOOL flyoff;
	BOOL destroy;
	CGPoint out_vel;
}
+(CapeGameBossRobotHead*)cons;
-(void)do_destroy;
@end

@implementation CapeGameBossRobotHead
+(CapeGameBossRobotHead*)cons {
	return [CapeGameBossRobotHead node];
}
-(id)init {
	self = [super init];
	[self setTexture:[Resource get_tex:TEX_ENEMY_ROBOTBOSS]];
	[self setTextureRect:[FileCache get_cgrect_from_plist:TEX_ENEMY_ROBOTBOSS idname:@"head"]];
	[self csf_setScaleX:-0.45];
	[self csf_setScaleY:0.45];
	[super setPosition:[Common screen_pctwid:1.3 pcthei:float_random(0.1, 0.9)]];
	[AudioManager playsfx:SFX_BOSS_ENTER];
	flyoff = NO;
	destroy = NO;
	return self;
}
-(void)update:(CapeGameEngineLayer *)g {
	if (destroy) {
		if (particle_ct > 0) {
			particle_ct--;
			[self setOpacity:190];
			self.rotation = self.rotation + 20*[Common get_dt_Scale];
			if (particle_ct % 10 == 0) {
				[g add_particle:[ExplosionParticle cons_x:self.position.x+float_random(-40, 40) y:self.position.y + float_random(-40, 40)]];
				[AudioManager playsfx:SFX_EXPLOSION];
			}
			
		} else {
			[g remove_gameobject:self];
			[g add_particle:[[ExplosionParticle cons_x:self.position.x y:self.position.y] set_scale:1.3]];
			[AudioManager playsfx:SFX_EXPLOSION];
		}
		return;
	}
	
	if (flyoff) {
		[self setOpacity:180];
		[self setRotation:self.rotation+20*[Common get_dt_Scale]];
		[super setPosition:ccp(self.position.x+out_vel.x*[Common get_dt_Scale], self.position.y+out_vel.y*[Common get_dt_Scale])];
		
		if (self.position.x > [Common SCREEN].width*1.4) {
			flyoff = NO;
			[super setPosition:[Common screen_pctwid:1.3 pcthei:float_random(0.1, 0.9)]];
		}
		return;
		
	} else {
		[self setOpacity:255];
		[self setRotation:0];
	}
		
	if ([Common hitrect_touch:[self get_hit_rect] b:[g.player get_hitrect]]) {
		if (g.player.is_rocket) {
			[AudioManager playsfx:SFX_ROCKBREAK];
			out_vel = ccp(float_random(3, 5),g.player.vy*0.4);
			flyoff = YES;
			
			[g shake_for:10 intensity:4];
			[g freeze_frame:6];
			
		} else {
			[AudioManager playsfx:SFX_HIT];
			[g do_get_hit];
			[g shake_for:15 intensity:6];
			[g freeze_frame:6];
		}
	}
	
	[super setPosition:ccp(self.position.x-4.5*[Common get_dt_Scale],self.position.y)];
	particle_ct++;
	if (particle_ct%2==0) [g add_particle:
						   [[[RocketParticle cons_x:self.position.x+65*0.45 y:self.position.y-20+float_random(-10, 10)]
										   set_scale:float_random(0.6, 0.8)]
											set_ctmax:25]];
	
	if (self.position.x <= -[Common SCREEN].width*0.4) {
		[super setPosition:[Common screen_pctwid:1.3 pcthei:float_random(0.1, 0.9)]];
		[AudioManager playsfx:SFX_BOSS_ENTER];
	}
}
-(void)do_destroy {
	destroy = YES;
	particle_ct = 50;
}
-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:self.position.x-30 y1:self.position.y-30 wid:60 hei:60];
}
-(void)setPosition:(CGPoint)position{}
@end

@implementation CapeGameBossCat

+(CapeGameBossCat*)cons {
	return [CapeGameBossCat node];
}

#define LERP_TO(pos1,pos2,div) ccp(pos1.x+(pos2.x-pos1.x)/div,pos1.y+(pos2.y-pos1.y)/div)
#define DEFAULT_X_PCT 0.8
#define DEFAULT_POS [Common screen_pctwid:DEFAULT_X_PCT pcthei:0.5]
-(id)init {
	self = [super init];
	[self setScale:1];
	cat_body = [VolleyCatBossBody cons];
	[cat_body setPosition:[Common screen_pctwid:0.4 pcthei:1.5]];
	[cat_body csf_setScaleX:-0.5];
	[cat_body csf_setScaleY:0.5];
	[self addChild:cat_body];
	added_head = NO;
	mode = CapeGameBossCatMode_INITIAL_IN;
	return self;
}

-(void)update:(CapeGameEngineLayer *)g {
	[cat_body update];
	
	if (mode == CapeGameBossCatMode_INITIAL_IN) {
		cat_body.position = LERP_TO(cat_body.position, DEFAULT_POS, 20.0);
		if (CGPointDist(cat_body.position, DEFAULT_POS) < 10) {
			mode = CapeGameBossCatMode_TAUNT;
			delay_ct = 60;
			[cat_body laugh_anim];
			[AudioManager playsfx:SFX_CAT_LAUGH];
			
			if ([GameMain GET_BOSS_1_HEALTH]) {
				next_mode = CapeGameBossCatMode_PATTERN_3;
			} else {
				next_mode = CapeGameBossCatMode_PATTERN_1;
			}
		}
		
	} else if (mode == CapeGameBossCatMode_TAUNT) {
		delay_ct -= [Common get_dt_Scale];
		if (delay_ct <= 0) {
			mode = next_mode;
			[cat_body stand_anim];
			cat_screen_pos = ccp(DEFAULT_X_PCT,0.5);
			delay_ct = 0;
			pos_theta = 0;
		}
		
	} else if (mode == CapeGameBossCatMode_PATTERN_1) {
		[self update_pattern_g:g dtheta:0.02 bombmod:7 next:CapeGameBossCatMode_PATTERN_2 bombdelay:30 end:NO];
		
	} else if (mode == CapeGameBossCatMode_HURT_SPIN) {
		[cat_body hurt_anim];
		cat_body.rotation = cat_body.rotation + 20 * [Common get_dt_Scale];
		delay_ct-=[Common get_dt_Scale];
		cat_body.position = LERP_TO(cat_body.position, DEFAULT_POS, 20.0);
		
		if (delay_ct <= 0) {
			cat_body.rotation = 0;
			mode = CapeGameBossCatMode_TAUNT;
			delay_ct = 60;
			[cat_body laugh_anim];
			[AudioManager playsfx:SFX_CAT_LAUGH];
		}
		
	} else if (mode == CapeGameBossCatMode_PATTERN_2) {
		[self update_pattern_g:g dtheta:0.03 bombmod:15 next:CapeGameBossCatMode_PATTERN_3 bombdelay:10 end:NO];
		if (!added_head) {
			[g add_gameobject:[CapeGameBossRobotHead cons]];
			added_head = YES;
		}

	} else if (mode == CapeGameBossCatMode_PATTERN_3) {
		[self update_pattern_g:g dtheta:0.04 bombmod:25 next:CapeGameBossCatMode_END_OUT bombdelay:0 end:YES];
		
	} else if (mode == CapeGameBossCatMode_END_OUT) {
		if (added_head) {
			for (CapeGameObject *o in [g get_gameobjs]) {
				if ([o class] == [CapeGameBossRobotHead class]) {
					[((CapeGameBossRobotHead*)o) do_destroy];
				}
			}
			added_head = NO;
		}
		delay_ct -= 1;
		
		if (delay_ct > 0) {
			[cat_body damage_anim];
			cat_body.rotation = cat_body.rotation + 23*[Common get_dt_Scale];
			cat_body.rotation = (((int)cat_body.rotation)%360) + (cat_body.rotation - floor(cat_body.rotation));
			if (((int)delay_ct)%10==0) {
				[g add_particle:[[ExplosionParticle cons_x:cat_body.position.x+float_random(-20, 20) y:cat_body.position.y + float_random(-30, 30)] set_scale:0.7]];
				[AudioManager playsfx:SFX_EXPLOSION];
				[g shake_for:15 intensity:4];
			}
			
		} else if (ABS(cat_body.rotation) > 10) {
			cat_body.rotation*=0.95;
			[cat_body hurt_anim];
			if (((int)delay_ct)%20==0) {
				[g add_particle:[[ExplosionParticle cons_x:cat_body.position.x+float_random(-20, 20) y:cat_body.position.y + float_random(-30, 30)] set_scale:0.7]];
				[AudioManager playsfx:SFX_EXPLOSION];
				[g shake_for:15 intensity:4];
			}
			
		} else if (cat_body.position.y > -[Common SCREEN].height * 0.3) {
			cat_body.position=ccp(cat_body.position.x,cat_body.position.y-3*[Common get_dt_Scale]);
			cat_body.rotation*=0.95;
			[cat_body hurt_anim];
			if (((int)delay_ct)%30==0) {
				[g add_particle:[[ExplosionParticle cons_x:cat_body.position.x+float_random(-20, 20) y:cat_body.position.y + float_random(-30, 30)] set_scale:0.7]];
				[AudioManager playsfx:SFX_EXPLOSION];
				[g shake_for:15 intensity:4];
			}
			
		} else {
			[[g get_main_game].score increment_score:1000];
			[g boss_end];
			mode = CapeGameBossCatMode_TO_REMOVE;
			
		}
	}
}

-(void)update_pattern_g:(CapeGameEngineLayer*)g dtheta:(float)dtheta bombmod:(int)bombmod next:(CapeGameBossCatMode)next bombdelay:(float)bombdelay end:(BOOL)end {
	cat_screen_pos.y = sinf(pos_theta) * 0.35 + 0.5;
	pos_theta+=dtheta*[Common get_dt_Scale];
	[cat_body setPosition:[Common screen_pctwid:cat_screen_pos.x pcthei:cat_screen_pos.y]];
	
	if ([g.player is_rocket] && [Common hitrect_touch:[self get_hit_rect] b:[g.player get_hitrect]]) {
		[g add_particle:[ExplosionParticle cons_x:cat_body.position.x y:cat_body.position.y]];
		[AudioManager playsfx:SFX_EXPLOSION];
		[AudioManager playsfx:SFX_CAT_HIT];
		
		[g shake_for:15 intensity:6];
		[g freeze_frame:6];
		
		delay_ct = 130;
		pos_theta = 0;
		bomb_count = 0;
		if (end) {
			mode = CapeGameBossCatMode_END_OUT;
		} else {
			mode = CapeGameBossCatMode_HURT_SPIN;
			next_mode = next;
		}

		
	} else if (delay_ct <= 0) {
		if (![cat_body get_throw_in_progress]) {
			[cat_body throw_anim_force:YES];
			
		} else if ([cat_body get_throw_finished]) {
			bomb_count++;
			if (bomb_count%bombmod==0) {
				[AudioManager playsfx:SFX_POWERUP];
				[g add_gameobject:[CapeGameBossPowerupRocket cons_pos:cat_body.position]];
			} else {
				[AudioManager playsfx:SFX_BOP];
				[g add_gameobject:[CapeGameBossBomb cons_pos:cat_body.position]];
			}
			
			delay_ct = bombdelay;
			[cat_body stand_anim];
		}
		
	} else {
		delay_ct -= [Common get_dt_Scale];
	}
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:cat_body.position.x-40 y1:cat_body.position.y-45 wid:80 hei:95];
}

-(void)setPosition:(CGPoint)position{}

@end
