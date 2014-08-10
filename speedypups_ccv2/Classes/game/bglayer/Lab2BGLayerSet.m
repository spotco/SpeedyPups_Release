#import "Lab2BGLayerSet.h"
#import "ExplosionParticle.h"
#import "SubBoss.h"
#import "JumpPadParticle.h"
#import "BGSubBossRocketParticle.h"
#import "StreamParticle.h"
#import "UICommon.h"

@implementation Lab2BGLayerSet
+(Lab2BGLayerSet*)cons {
	Lab2BGLayerSet *rtv = [Lab2BGLayerSet node];
	return [rtv cons];
}

-(Lab2BGLayerSet*)cons {
	bg_objects = [NSMutableArray array];
	
	sky = [BackgroundObject backgroundFromTex:[Resource get_tex:TEX_BG2_SKY] scrollspd_x:0 scrollspd_y:0];
	[Common scale_to_fit_screen_y:sky];
	[bg_objects addObject:sky];
	
	clouds = [[[CloudGenerator cons] set_speedmult:0.3] set_generate_speed:140];
	[bg_objects addObject:clouds];
	
	BackgroundObject *window_wall = [BackgroundObject backgroundFromTex:[Resource get_tex:TEX_LAB2_WINDOWWALL] scrollspd_x:0.01 scrollspd_y:0];
	[Common scale_to_fit_screen_y:window_wall];
	[bg_objects addObject:window_wall];
	
	BackgroundObject *backwater = [BackgroundObject backgroundFromTex:[Resource get_tex:TEX_LAB2_WATER_BACK] scrollspd_x:0.06 scrollspd_y:0];
	
	subboss = [SubBossBGObject cons_anchor:backwater];
	[bg_objects addObject:subboss];
	
	
	[bg_objects addObject:backwater];
	tankers = [BackgroundObject backgroundFromTex:[Resource get_tex:TEX_LAB2_TANKER_BACK] scrollspd_x:0.08 scrollspd_y:0.0125];
	[bg_objects addObject:tankers];
	
	docks = [BackgroundObject backgroundFromTex:[Resource get_tex:TEX_LAB2_DOCKS] scrollspd_x:0.08 scrollspd_y:0.02];
	[bg_objects addObject:docks];
	
	tankersfront = [BackgroundObject backgroundFromTex:[Resource get_tex:TEX_LAB2_TANKER_FRONT] scrollspd_x:0.08 scrollspd_y:0.02];
	[bg_objects addObject:tankersfront];
	[bg_objects addObject:[BackgroundObject backgroundFromTex:[Resource get_tex:TEX_LAB2_WATER_FRONT] scrollspd_x:0.1 scrollspd_y:0.02]];
	
	particles = [NSMutableArray array];
	particles_tba = [NSMutableArray array];
	tankersfront_particles_tba = [NSMutableArray array];
	behindwater_particles_tba = [NSMutableArray array];
	tankersfront_particleholder = [CCSprite node];
	behindwater_particleholder = [CCSprite node];
	
	[tankersfront addChild:tankersfront_particleholder];
	[tankersfront_particleholder setScale:1/CC_CONTENT_SCALE_FACTOR()];
	
	for (BackgroundObject *o in bg_objects) {
		if (o == backwater) {
			[self addChild:behindwater_particleholder];
		}
		[self addChild:o];
	}
	
	particleholder = [CCSprite node];
	[self addChild:particleholder];
	
	current_state = Lab2BGLayerSetState_Normal;
	
	return self;
}

-(void)explosion_at:(CGPoint)pt {
	for(int i = 0; i < 10; i++) {
        float r = ((float)i);
        r = r/5.0 * M_PI;
        float dvx = cosf(r)*3+float_random(-1, 1);
        float dvy = sinf(r)*3+float_random(-1, 1);
        [self add_particle:[[[RocketExplodeParticle cons_x:pt.x y:pt.y vx:dvx vy:dvy] set_color:ccc3(255, 200, 22)] set_scale:float_random(0.3, 0.6)]];
    }
}

-(void)launch_rocket {
	CGPoint spot = CGPointAdd(subboss.position, ccp(0,45));
	[self add_particle:[BGSubBossRocketParticle cons_pt:spot]];
	
	for (int i = 0; i < 8; i++) {
		[self add_particle:[[[StreamParticle cons_x:spot.x
												  y:spot.y-7.5
												 vx:float_random(-3, 3)+(i%2==0?-3:5)
												 vy:float_random(-1, 1)]
							 set_scale:float_random(0.3, 0.9)]
							set_ctmax:15]];
	}
}

-(void)splash_tick:(CGPoint)dir offset:(CGPoint)offset {
	CGPoint spot = CGPointAdd(subboss.position, offset);
	StreamParticle *sp = [[[[StreamParticle cons_x:spot.x
											   y:spot.y
											  vx:dir.x
											  vy:dir.y]
						   set_scale:float_random(0.4, 1.3)]
						  set_ctmax:16]
						  set_gravity:ccp(0,float_random(-2, -1))];
	[sp setColor:ccc3(200,220,250)];
	[sp set_final_color:ccc3(120+arc4random_uniform(40), 170+arc4random_uniform(20), 220+arc4random_uniform(30))];
	[self add_particle_behind_water:sp];
}

-(SubBossBGObject*)get_subboss_bgobject {
	return subboss;
}

/*
-(void)set_day_night_color:(float)val {
	float pctm = ((float)val) / 100;
	[sky setColor:PCT_CCC3(50,50,90,pctm)];
	[clouds setColor:PCT_CCC3(80, 80, 130, pctm)];
}
*/

static float explosion_ct;
-(void)update:(GameEngineLayer*)g curx:(float)curx cury:(float)cury {
	[self update_particles];
	[self push_added_particles];
	
	if (current_state == Lab2BGLayerSetState_Normal) {
		[tankers setVisible:YES];
		[docks setVisible:YES];
		[tankersfront setVisible:YES];

		
		for (BackgroundObject *o in bg_objects) {
			[o update_posx:curx posy:cury];
		}
		tankers_theta += 0.03 * [Common get_dt_Scale];
		tankers.position = CGPointAdd(ccp(0,sinf(tankers_theta)*2), tankers.position);
		tankersfront.position = CGPointAdd(ccp(0,cosf(tankers_theta)*2), tankersfront.position);
		
	} else if (current_state == Lab2BGLayerSetState_Sinking) {
		[tankers setVisible:YES];
		[docks setVisible:YES];
		[tankersfront setVisible:YES];
		
		explosion_ct-=[Common get_dt_Scale];
		if (explosion_ct <= 0) {
			Particle *p = [ExplosionParticle cons_x:float_random(0, 600) y:float_random(0,350)];
			[self add_tankersfront_particle:p];
			[AudioManager playsfx:SFX_EXPLOSION];
			explosion_ct = 13;
			[g shake_for:13 intensity:4];
		}
		
		for (BackgroundObject *o in bg_objects) {
			if (o == tankers || o == docks || o == tankersfront) {
				float prevy = o.position.y;
				[o update_posx:curx posy:cury];
				[o setPosition:ccp(o.position.x,prevy-1.5*[Common get_dt_Scale])];
				
				if (o == docks && o.position.y <= -350) current_state = Lab2BGLayerSetState_Sunk;
				
			} else {
				[o update_posx:curx posy:cury];
				
			}
			
		}
	} else if (current_state == Lab2BGLayerSetState_Sunk) {
		[tankers setVisible:NO];
		[docks setVisible:NO];
		[tankersfront setVisible:NO];
		for (BackgroundObject *o in bg_objects) {
			[o update_posx:curx posy:cury];
		}
	}
}

-(void)add_particle:(Particle*)p {
    [particles_tba addObject:p];
}
-(void)add_particle_behind_water:(Particle*)p {
	[behindwater_particles_tba addObject:p];
}
-(void)add_tankersfront_particle:(Particle*)p {
	[tankersfront_particles_tba addObject:p];
}
-(void)push_added_particles {
    for (Particle *p in particles_tba) {
        [particles addObject:p];
		[particleholder addChild:p z:[p get_render_ord]];
    }
	for (Particle *p in tankersfront_particles_tba) {
		[particles addObject:p];
		[tankersfront_particleholder addChild:p z:[p get_render_ord]];
	}
	for (Particle *p in behindwater_particles_tba) {
		[particles addObject:p];
		[behindwater_particleholder addChild:p z:[p get_render_ord]];
	}
    [particles_tba removeAllObjects];
	[tankersfront_particles_tba removeAllObjects];
	[behindwater_particles_tba removeAllObjects];
}
-(void)remove_all_particles {
	if ([particles count] != 0) {
		NSMutableArray *toremove = [NSMutableArray array];
		for (Particle *i in particles) {
			[i.parent removeChild:i cleanup:YES];
			[toremove addObject:i];
		}
		[particles removeObjectsInArray:toremove];
	}
}
-(void)update_particles {
    NSMutableArray *toremove = [NSMutableArray array];
    for (Particle *i in particles) {
        [i update:NULL];
        if ([i should_remove]) {
            [i.parent removeChild:i cleanup:YES];
            [toremove addObject:i];
        }
    }
    [particles removeObjectsInArray:toremove];
}

-(void)do_sink_anim {
	current_state = Lab2BGLayerSetState_Sinking;
	tankers_theta = 0;
}

-(void)reset {
	[self remove_all_particles];
	current_state = Lab2BGLayerSetState_Normal;
	[tankers setPosition:CGPointZero];
	[tankersfront setPosition:CGPointZero];
	[docks setPosition:CGPointZero];
	[subboss setPosition:ccp(-[Common SCREEN].width,subboss.position.y)];
	[subboss reset];
}
@end


@implementation SubBossBGObject

+(SubBossBGObject*)cons_anchor:(CCNode*)anchor { return [[SubBossBGObject node] cons_anchor:anchor]; }
-(id)cons_anchor:(CCNode*)tanchor {
	[self cons_anims];
	_body = [CCSprite node];
	_hatch = [CCSprite node];
	[self addChild:_body];
	[_hatch setAnchorPoint:ccp(0.5,0)];
	[_body addChild:_hatch];
	
	[_hatch setPosition:ccp(215*0.35 / CC_CONTENT_SCALE_FACTOR(),195*0.35 / CC_CONTENT_SCALE_FACTOR())];
	
	[_body runAction:_anim_body_normal];
	[_hatch runAction:_anim_hatch_closed];
	
	[_body setRotation:-15];
	
	[self setPosition:ccp(-500,anchor.position.y + 175)];
	anchor = tanchor;
	broken = NO;
	return self;
}

-(void)reset {
	broken = NO;
	[_body stopAllActions];
	[_body runAction:_anim_body_normal];
	[_hatch stopAllActions];
	[_hatch runAction:_anim_hatch_closed];
}

-(void)set_broken {
	if (!broken) {
		[_body stopAllActions];
		[_body runAction:_anim_body_broken];
	}
	broken = YES;
}

#define NOZZLE_OFFSET ccp(20,20)
-(CGPoint)get_nozzle:(GameEngineLayer*)g {
	CGPoint screen_coord = [_hatch convertToWorldSpace:NOZZLE_OFFSET];
	return [g convertToNodeSpace:screen_coord];
}

-(void)set_recoil_delta:(CGPoint)delta {
	recoil_delta = delta;
	[super setPosition:CGPointAdd(actual_position, recoil_delta)];
}

-(void)setPosition:(CGPoint)position {
	actual_position = position;
	[super setPosition:CGPointAdd(actual_position, recoil_delta)];
}

-(CGPoint)position {
	return actual_position;
}

-(void)update_posx:(float)posx posy:(float)posy{
	recoil_delta.x -= recoil_delta.x/5;
	recoil_delta.y -= recoil_delta.y/5;
	[super setPosition:CGPointAdd(actual_position, recoil_delta)];
}

-(void)cons_anims {
	if (_anim_body_normal != NULL) return;
	_anim_body_normal = [Common cons_anim:@[@"bg_body_normal"] speed:21 tex_key:TEX_ENEMY_SUBBOSS];
	_anim_body_broken = [Common cons_anim:@[@"bg_body_broken"] speed:22 tex_key:TEX_ENEMY_SUBBOSS];
	_anim_hatch_closed = [Common cons_anim:@[@"bg_hatch_0"] speed:23 tex_key:TEX_ENEMY_SUBBOSS];
	_anim_hatch_closed_to_cannon = [Common cons_nonrepeating_anim:@[@"bg_hatch_0",
																	@"bg_hatch_1",
																	@"bg_hatch_cannon_0",
																	@"bg_hatch_cannon_1",
																	@"bg_hatch_cannon_2",
																	@"bg_hatch_cannon_default"]
															speed:0.1
														  tex_key:TEX_ENEMY_SUBBOSS];
	_anim_hatch_cannon_to_closed = [Common cons_nonrepeating_anim:@[@"bg_hatch_cannon_default",
																	@"bg_hatch_cannon_2",
																	@"bg_hatch_cannon_1",
																	@"bg_hatch_cannon_0",
																	@"bg_hatch_1",
																	@"bg_hatch_0"]
															speed:0.1
														  tex_key:TEX_ENEMY_SUBBOSS];
	_anim_hatch_closed_to_open = [Common cons_nonrepeating_anim:@[@"bg_hatch_0",
																  @"bg_hatch_1",
																  @""]
														  speed:0.1
														tex_key:TEX_ENEMY_SUBBOSS];
}

-(void)anim_hatch_closed {
	[_hatch stopAllActions];
	[_hatch runAction:_anim_hatch_closed];
}

-(void)anim_hatch_closed_to_cannon {
	[_hatch stopAllActions];
	[_hatch runAction:_anim_hatch_closed_to_cannon];
}

-(void)anim_hatch_cannon_to_closed {
	[_hatch stopAllActions];
	[_hatch runAction:_anim_hatch_cannon_to_closed];
}

-(void)anim_hatch_closed_to_open {
	[_hatch stopAllActions];
	[_hatch runAction:_anim_hatch_closed_to_open];
}

-(void)explosion_at_nozzle {
	if ([[self parent] class] == [Lab2BGLayerSet class]) {
		[((Lab2BGLayerSet*)[self parent]) explosion_at:[_hatch convertToWorldSpace:NOZZLE_OFFSET]];
	}
}

-(void)launch_rocket {
	if ([[self parent] class] == [Lab2BGLayerSet class]) {
		[((Lab2BGLayerSet*)[self parent]) launch_rocket];
	}
}

-(void)splash_tick:(CGPoint)dir offset:(CGPoint)offset {
	if ([[self parent] class] == [Lab2BGLayerSet class]) {
		[((Lab2BGLayerSet*)[self parent]) splash_tick:dir offset:offset];
	}
}
@end
