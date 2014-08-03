#import "VolleyRobotBoss.h"
#import "VolleyRobotBossComponents.h"
#import "GameEngineLayer.h"
#import "VolleyRobotBossFistProjectile.h"
#import "JumpParticle.h"

@implementation VolleyRobotBoss

+(VolleyRobotBoss*)cons_with:(GameEngineLayer*)g {
	return [[VolleyRobotBoss node] cons:g];
}

#define RPOS_CAT_TAUNT_POS ccp(400,300)
#define RPOS_CAT_DEFAULT_POS ccp(900,500)
#define RPOS_ROBOT_DEFAULT_POS ccp(725,0)

#define LPOS_CAT_TAUNT_POS ccp(-400,300)
#define LPOS_CAT_DEFAULT_POS ccp(-700,500)
#define LPOS_ROBOT_DEFAULT_POS ccp(-525,0)

#define CAPE_WAIT_POS ccp(500,150)

#define CENTER_POS ccp(player.position.x,groundlevel)
#define LERP_TO(pos1,pos2,div) ccp(pos1.x+(pos2.x-pos1.x)/div,pos1.y+(pos2.y-pos1.y)/div)

-(id)cons:(GameEngineLayer*)_g {

	g = _g;
	
	robot_body = [VolleyRobotBossBody cons];
	[self addChild:robot_body];
	
	cat_body = [VolleyCatBossBody cons];
	[self addChild:cat_body];
	
	[self set_bounds_and_ground:g];
	
	cat_body_rel_pos = ccp(2000,800);
	robot_body_rel_pos = ccp(1500,0);
	
	fist_projectiles = [NSMutableArray array];
	
	cur_mode = RobotBossMode_CAT_IN_RIGHT1;
	//cur_mode = RobotBossMode_CAT_IN_RIGHT2;
	
	cape_item_body = [CCSprite spriteWithTexture:[Resource get_tex:TEX_ITEM_SS] rect:[FileCache get_cgrect_from_plist:TEX_ITEM_SS idname:@"pickup_dogcape"]];
	[cape_item_body setScale:1.75];
	[cape_item_body setVisible:NO];
	[self addChild:cape_item_body];
	
	self.active = YES;
	return self;
}

-(void)update:(Player *)player g:(GameEngineLayer *)_g {
	[self set_bounds_and_ground:g];
	
	[robot_body setPosition:CGPointAdd(CENTER_POS, robot_body_rel_pos)];
	[robot_body update];
	
	[cat_body setPosition:CGPointAdd(CENTER_POS, cat_body_rel_pos)];
	[cat_body update];
	
	[cape_item_body setPosition:CGPointAdd(CENTER_POS, cape_item_rel_pos)];
	
	NSMutableArray *to_remove = [NSMutableArray array];
	for (VolleyRobotBossFistProjectile *p in fist_projectiles) {
		if (p.direction == RobotBossFistProjectileDirection_AT_BOSS) {
			if (p.time_left < 20 && ![robot_body swing_in_progress])  {
				[robot_body do_swing];
				[robot_body set_swing_has_thrown_bomb];
			}
			if (p.time_left <= 15) [self volley_return:p];
			
		} else if (p.direction == RobotBossFistProjectileDirection_AT_CAT && p.time_left <= 5) {
			if (cur_mode == RobotBossMode_WHIFF_AT_CAT_RIGHT_1) {
				delay_ct = 40;
				cur_mode = RobotBossMode_CAT_HURT_OUT_1;
				
			} else if (cur_mode == RobotBossMode_WHIFF_AT_CAT_LEFT_1) {
				delay_ct = 40;
				cur_mode = RobotBossMode_CAT_HURT_OUT_LEFT_1;
				
			} else if (cur_mode == RobotBossMode_WHIFF_AT_CAT_RIGHT_2) {
				delay_ct = 40;
				cur_mode = RobotBossMode_CAT_HURT_OUT_RIGHT_2;
			}
		}
			
		
		if ([p should_remove] && (p.direction == RobotBossFistProjectileDirection_AT_PLAYER || p.direction == RobotBossFistProjectileDirection_AT_CAT)) {
			[p do_remove:g];
			[g remove_gameobject:p];
			[to_remove addObject:p];
			[AudioManager playsfx:SFX_ROCKBREAK];
			[AudioManager playsfx:SFX_FAIL];
			
		}
	}
	[fist_projectiles removeObjectsInArray:to_remove];
	
	if (cur_mode == RobotBossMode_TOREMOVE) {
		[g remove_gameobject:self];
		return;
	
	} else if (cur_mode == RobotBossMode_CAT_IN_RIGHT1) {
		[g set_target_camera:[Common cons_normalcoord_camera_zoom_x:54 y:54 z:400]];
		[cat_body setScaleX:-1];
		[robot_body setScaleX:-1];
		[self update_cat_body_flyin_to:RPOS_CAT_TAUNT_POS transition_to:RobotBossMode_CAT_TAUNT_RIGHT1];
		
	} else if (cur_mode == RobotBossMode_CAT_TAUNT_RIGHT1) {
		[self update_taunt_transition_to:RobotBossMode_CAT_ROBOT_IN_RIGHT1];
		
	} else if (cur_mode == RobotBossMode_CAT_ROBOT_IN_RIGHT1) {
		[self update_robot_body_in_robotpos:RPOS_ROBOT_DEFAULT_POS catpos:RPOS_CAT_DEFAULT_POS transition_to:RobotBossMode_VOLLEY_RIGHT_1];
		
	} else if (cur_mode == RobotBossMode_VOLLEY_RIGHT_1) {
		delay_ct -= [Common get_dt_Scale];
		if (fist_projectiles.count == 0 && delay_ct <= 0 && ![robot_body swing_in_progress]) {
			[robot_body do_swing];
			
		} else if (fist_projectiles.count == 0 && [robot_body swing_in_progress] && [robot_body swing_launched]) {
			volley_ct = 2;
			VolleyRobotBossFistProjectile *neu = [[VolleyRobotBossFistProjectile cons_g:g
																	 relpos:CGPointAdd(robot_body_rel_pos, ccp(-140,350))
																	 tarpos:CGPointZero
																	   time:100 groundlevel:groundlevel] mode_parabola_a];
			[neu set_boss_pos:CGPointAdd(RPOS_ROBOT_DEFAULT_POS, ccp(0,200))];
			neu.direction = RobotBossFistProjectileDirection_AT_PLAYER;
			[g add_gameobject:neu];
			[fist_projectiles addObject:neu];
			[AudioManager playsfx:SFX_BOSS_ENTER];
			
		}
		
	} else if (cur_mode == RobotBossMode_CAT_HURT_OUT_1) {
		[self update_cat_hurt_out_catpos:ccp(RPOS_CAT_DEFAULT_POS.x+600,RPOS_CAT_DEFAULT_POS.y+50)
							   robot_pos:ccp(RPOS_ROBOT_DEFAULT_POS.x+1200,0)
						   transition_to:RobotBossMode_CAT_IN_LEFT1
							after_catpos:ccp(-2000,800)
							after_catpos:ccp(-1500,0)];
		
	} else if (cur_mode == RobotBossMode_CAT_IN_LEFT1) {
		[g set_target_camera:[Common cons_normalcoord_camera_zoom_x:320 y:54 z:400]];
		[cat_body setScaleX:1];
		[robot_body setScaleX:1];
		[self update_cat_body_flyin_to:LPOS_CAT_TAUNT_POS transition_to:RobotBossMode_CAT_TAUNT_LEFT1];
		
	} else if (cur_mode == RobotBossMode_CAT_TAUNT_LEFT1) {
		[self update_taunt_transition_to:RobotBossMode_CAT_ROBOT_IN_LEFT1];
		
	} else if  (cur_mode == RobotBossMode_CAT_ROBOT_IN_LEFT1) {
		[self update_robot_body_in_robotpos:LPOS_ROBOT_DEFAULT_POS catpos:LPOS_CAT_DEFAULT_POS transition_to:RobotBossMode_VOLLEY_LEFT_1];
		
	} else if (cur_mode == RobotBossMode_VOLLEY_LEFT_1) {
		delay_ct -= [Common get_dt_Scale];
		if (fist_projectiles.count == 0 && delay_ct <= 0 && ![robot_body swing_in_progress]) {
			[robot_body do_swing];
			
		} else if (fist_projectiles.count == 0 && [robot_body swing_in_progress] && [robot_body swing_launched]) {
			volley_ct = 5;
			VolleyRobotBossFistProjectile *neu = [[VolleyRobotBossFistProjectile cons_g:g
																	 relpos:CGPointAdd(robot_body_rel_pos, ccp(140,350))
																	 tarpos:CGPointZero
																	   time:100 groundlevel:groundlevel] mode_parabola_b];
			[neu set_boss_pos:CGPointAdd(LPOS_ROBOT_DEFAULT_POS, ccp(0,200))];
			neu.direction = RobotBossFistProjectileDirection_AT_PLAYER;
			[g add_gameobject:neu];
			[fist_projectiles addObject:neu];
			[AudioManager playsfx:SFX_BOSS_ENTER];
			
		}
		
	} else if (cur_mode == RobotBossMode_CAT_HURT_OUT_LEFT_1) {
		[self update_cat_hurt_out_catpos:ccp(LPOS_CAT_DEFAULT_POS.x-600,LPOS_CAT_DEFAULT_POS.y+50)
							   robot_pos:ccp(LPOS_ROBOT_DEFAULT_POS.x-1200,0)
						   transition_to:RobotBossMode_CAT_IN_RIGHT2
							after_catpos:ccp(2000,800)
							after_catpos:ccp(1500,0)];
		
	} else if (cur_mode == RobotBossMode_CAT_IN_RIGHT2) {
		[g set_target_camera:[Common cons_normalcoord_camera_zoom_x:54 y:54 z:400]];
		[cat_body setScaleX:-1];
		[robot_body setScaleX:-1];
		[self update_cat_body_flyin_to:RPOS_CAT_TAUNT_POS transition_to:RobotBossMode_CAT_TAUNT_RIGHT2];
		
	} else if (cur_mode == RobotBossMode_CAT_TAUNT_RIGHT2) {
		[self update_taunt_transition_to:RobotBossMode_CAT_ROBOT_IN_RIGHT2];
		
	} else if (cur_mode == RobotBossMode_CAT_ROBOT_IN_RIGHT2) {
		[self update_robot_body_in_robotpos:RPOS_ROBOT_DEFAULT_POS catpos:RPOS_CAT_DEFAULT_POS transition_to:RobotBossMode_VOLLEY_RIGHT_2];
		
	} else if (cur_mode == RobotBossMode_VOLLEY_RIGHT_2) {
		delay_ct -= [Common get_dt_Scale];
		if (fist_projectiles.count == 0 && delay_ct <= 0 && ![robot_body swing_in_progress]) {
			[robot_body do_swing];
			
		} else if (fist_projectiles.count == 1 && delay_ct <= 0 && ![robot_body swing_in_progress]) {
			VolleyRobotBossFistProjectile *p = fist_projectiles[0];
			if (p.direction == RobotBossFistProjectileDirection_AT_PLAYER && (p.time_left < 65 && p.time_left > 30)) {
				[robot_body do_swing];
			}
			
		} else if (fist_projectiles.count <= 1 && [robot_body swing_in_progress] && [robot_body swing_launched] && ![robot_body swing_has_thrown_bomb]) {
			volley_ct = 6;
			[robot_body set_swing_has_thrown_bomb];
			
			VolleyRobotBossFistProjectile *neu = [[VolleyRobotBossFistProjectile cons_g:g
																	 relpos:CGPointAdd(robot_body_rel_pos, ccp(-140,350))
																	 tarpos:CGPointZero
																	   time:120 groundlevel:groundlevel] mode_parabola_a];
			[neu set_boss_pos:CGPointAdd(RPOS_ROBOT_DEFAULT_POS, ccp(0,200))];
			neu.direction = RobotBossFistProjectileDirection_AT_PLAYER;
			[g add_gameobject:neu];
			[fist_projectiles addObject:neu];
			[AudioManager playsfx:SFX_BOSS_ENTER];
			
		}
		
	} else if (cur_mode == RobotBossMode_CAT_HURT_OUT_RIGHT_2) {
		[cat_body hurt_anim];
		[cat_body brownian];
		delay_ct -= [Common get_dt_Scale];
		
		if (delay_ct <= 0) {
			cat_body_rel_pos = LERP_TO(cat_body_rel_pos, RPOS_CAT_TAUNT_POS, 15);
			robot_body_rel_pos = LERP_TO(robot_body_rel_pos, CGPointAdd(RPOS_ROBOT_DEFAULT_POS, ccp(1000,0)), 45);
			if (CGPointDist(cat_body_rel_pos, RPOS_CAT_TAUNT_POS) < 10) {
				cur_mode = RobotBossMode_CAT_HURT_WAIT;
				delay_ct = 40;
				cape_item_rel_pos = cat_body_rel_pos;
			}
		}
		
	} else if (cur_mode == RobotBossMode_CAT_HURT_WAIT) {
		robot_body_rel_pos = LERP_TO(robot_body_rel_pos, CGPointAdd(RPOS_ROBOT_DEFAULT_POS, ccp(1000,0)), 45);
		[cape_item_body setVisible:YES];
		cape_item_rel_pos = LERP_TO(cape_item_rel_pos, CAPE_WAIT_POS, 15.0);
		delay_ct-=[Common get_dt_Scale];
		if (delay_ct <= 0) cur_mode = RobotBossMode_CAT_OUT_TO_CAPEGAME;
		
	} else if (cur_mode == RobotBossMode_CAT_OUT_TO_CAPEGAME) {
		robot_body_rel_pos = LERP_TO(robot_body_rel_pos, CGPointAdd(RPOS_ROBOT_DEFAULT_POS, ccp(1000,0)), 45);
		cat_body_rel_pos = LERP_TO(cat_body_rel_pos, CGPointAdd(RPOS_CAT_TAUNT_POS,ccp(0,1000)), 15);
		cape_item_rel_pos = LERP_TO(cape_item_rel_pos, CGPointZero, 15.0);
		if  (CGPointDist(cape_item_body.position, player.position) < 50) {
			[AudioManager playsfx:SFX_POWERUP];
			[cape_item_body setVisible:NO];
			cur_mode = RobotBossMode_TOREMOVE;
			[GEventDispatcher push_event:[GEvent cons_type:GEventType_BEGIN_BOSS_CAPE_GAME]];
		}
		
	}
}

-(void)volley_return:(VolleyRobotBossFistProjectile*)p {
	[AudioManager playsfx:SFX_ROCKBREAK];
	[AudioManager playsfx:SFX_BOSS_ENTER];
	
	if (cur_mode == RobotBossMode_VOLLEY_RIGHT_1) {
		volley_ct--;
		if (volley_ct == 1) {
			p.direction = RobotBossFistProjectileDirection_AT_PLAYER;
			[p mode_parabola_a];
			[p set_startpos:ccp(p.position.x-g.player.position.x,p.position.y-groundlevel)
					 tarpos:ccp(0,0) time_left:60 time_total:60];
			[self add_pow:CGPointAdd(p.position, ccp(0,100)) dir:ccp(0.5,-0.5) scx:1];
			
		} else {
			p.direction = RobotBossFistProjectileDirection_AT_CAT;
			[p mode_parabola_at_cat];
			[p set_startpos:ccp(p.position.x-g.player.position.x,p.position.y-groundlevel)
					 tarpos:RPOS_CAT_DEFAULT_POS time_left:60 time_total:60];
			cur_mode = RobotBossMode_WHIFF_AT_CAT_RIGHT_1;
			[self add_pow:CGPointAdd(p.position, ccp(0,100)) dir:ccp(0.5,-0.8) scx:1];
			
		}
		
	} else if (cur_mode == RobotBossMode_VOLLEY_LEFT_1) {
		volley_ct--;
		if (volley_ct > 0) {
			float speed = 100;
			if (volley_ct == 4) speed = 80;
			if (volley_ct == 3) speed = 60;
			if (volley_ct == 2) speed = 50;
			if (volley_ct == 1) speed = 90;
			
			p.direction = RobotBossFistProjectileDirection_AT_PLAYER;
			[p mode_parabola_b];
			[p set_startpos:ccp(p.position.x-g.player.position.x,p.position.y-groundlevel)
					 tarpos:ccp(0,0) time_left:speed time_total:speed];
			[self add_pow:CGPointAdd(p.position, ccp(0,100)) dir:ccp(0.5,-0.5) scx:-1];
			
		} else {
			p.direction = RobotBossFistProjectileDirection_AT_CAT;
			[p mode_parabola_at_cat_left];
			[p set_startpos:ccp(p.position.x-g.player.position.x,p.position.y-groundlevel)
					 tarpos:LPOS_CAT_DEFAULT_POS time_left:60 time_total:60];
			cur_mode = RobotBossMode_WHIFF_AT_CAT_LEFT_1;
			[self add_pow:CGPointAdd(p.position, ccp(0,100)) dir:ccp(0.5,-0.5) scx:-1];
			
		}
		
	} else if (cur_mode == RobotBossMode_VOLLEY_RIGHT_2) {
		volley_ct--;
		if (volley_ct > 0) {
			p.direction = RobotBossFistProjectileDirection_AT_PLAYER;
			[p mode_parabola_a];
			[p set_startpos:ccp(p.position.x-g.player.position.x,p.position.y-groundlevel)
					 tarpos:ccp(0,0) time_left:100 time_total:100];
			[self add_pow:CGPointAdd(p.position, ccp(0,100)) dir:ccp(0.5,-0.5) scx:1];
			
		} else {
			p.direction = RobotBossFistProjectileDirection_AT_CAT;
			[p mode_parabola_at_cat];
			[p set_startpos:ccp(p.position.x-g.player.position.x,p.position.y-groundlevel)
					 tarpos:RPOS_CAT_DEFAULT_POS time_left:60 time_total:60];
			cur_mode = RobotBossMode_WHIFF_AT_CAT_RIGHT_2;
			[self add_pow:CGPointAdd(p.position, ccp(0,100)) dir:ccp(0.5,-0.8) scx:1];
		}
		
	} else {
		p.direction = RobotBossFistProjectileDirection_AT_CAT;
		[p mode_parabola_at_cat];
		[p set_startpos:ccp(p.position.x-g.player.position.x,p.position.y-groundlevel)
				 tarpos:RPOS_CAT_DEFAULT_POS time_left:60 time_total:60];
		cur_mode = RobotBossMode_WHIFF_AT_CAT_RIGHT_2;
		[self add_pow:CGPointAdd(p.position, ccp(0,100)) dir:ccp(0.5,-0.8) scx:1];
	}
}

-(void)reset {
	[super reset];
	for (VolleyRobotBossFistProjectile *p in fist_projectiles) {
		[g remove_gameobject:p];
	}
	[fist_projectiles removeAllObjects];
	cur_mode = RobotBossMode_TOREMOVE;
}

-(void)add_pow:(CGPoint)pos dir:(CGPoint)dir scx:(float)scx {
	[g add_particle:[[[JumpParticle cons_pt:pos
									  vel:dir
									   up:ccp(0,1)
									  tex:[Resource get_tex:TEX_ENEMY_ROBOTBOSS]
									  rect:[FileCache get_cgrect_from_plist:TEX_ENEMY_ROBOTBOSS idname:@"pow"] relpos:YES] set_scale:0.3] set_scx:scx]];
}

-(void)check_should_render:(GameEngineLayer *)g { do_render = YES; }
-(int)get_render_ord{ return [GameRenderImplementation GET_RENDER_FG_ISLAND_ORD]; }

-(void)set_bounds_and_ground:(GameEngineLayer*)_g {
    float yl_min = g.player.position.y;
	Island *lowest = NULL;
	for (Island *i in g.islands) {
		if (i.endX > g.player.position.x && i.startX < g.player.position.x) {
			if (lowest == NULL || lowest.startY > i.startY) {
				lowest = i;
			}
		}
	}
	if (lowest != NULL) {
		yl_min = lowest.startY;
	}
	[g frame_set_follow_clamp_y_min:yl_min-500 max:yl_min+300];
	groundlevel = yl_min;
}

-(void)update_cat_body_flyin_to:(CGPoint)tar transition_to:(RobotBossMode)mode {
	[cat_body stand_anim];
	cat_body_rel_pos = LERP_TO(cat_body_rel_pos, tar, 15.0);
	
	if (CGPointDist(cat_body_rel_pos, tar) < 5) {
		cur_mode = mode;
		[cat_body laugh_anim];
		delay_ct = 80;
	}
}

-(void)update_taunt_transition_to:(RobotBossMode)mode {
	delay_ct-=[Common get_dt_Scale];
	if (delay_ct <= 0) {
		cur_mode = mode;
		[cat_body stand_anim];
		[AudioManager playsfx:SFX_BOSS_ENTER];
	}
}

-(void)update_robot_body_in_robotpos:(CGPoint)robot_pos catpos:(CGPoint)cat_pos transition_to:(RobotBossMode)mode {
	cat_body_rel_pos = LERP_TO(cat_body_rel_pos, cat_pos, 15.0);
	robot_body_rel_pos = LERP_TO(robot_body_rel_pos, robot_pos, 25.0);
	if (CGPointDist(robot_body_rel_pos, robot_pos) < 5) {
		cur_mode = mode;
		delay_ct = 20;
	}
}

-(void)update_cat_hurt_out_catpos:(CGPoint)catpos robot_pos:(CGPoint)robotpos transition_to:(RobotBossMode)mode after_catpos:(CGPoint)after_catpos after_catpos:(CGPoint)after_robotpos {
	[cat_body damage_anim];
	delay_ct -= [Common get_dt_Scale];
	if (delay_ct <= 0) {
		CGPoint flyout_pos = catpos;
		cat_body_rel_pos = LERP_TO(cat_body_rel_pos, flyout_pos, 25.0);
		if (CGPointDist(cat_body_rel_pos, flyout_pos) < 100) {
			robot_body_rel_pos.x += ((robotpos.x>robot_body_rel_pos.x)?10:-10)*[Common get_dt_Scale];
			if (CGPointDist(robot_body_rel_pos, robotpos) < 50) {
				cur_mode = mode;
				cat_body_rel_pos = after_catpos;
				robot_body_rel_pos = after_robotpos;
			}
		}
	} else {
		[cat_body brownian];
	}
}

@end
