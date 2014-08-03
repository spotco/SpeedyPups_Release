#import "NRobotBoss.h"
#import "NRobotBossComponents.h"
#import "GameEngineLayer.h"
#import "JumpParticle.h"
#import "LauncherRocket.h"
#import "CannonFireParticle.h"
#import "VolleyRobotBossFistProjectile.h"
#import "ExplosionParticle.h"
#import "HitEffect.h"
#import "DazedParticle.h"
#import "BrokenMachineParticle.h"
#import "GameMain.h"
//#import "FireworksParticleA.h"

@implementation NRobotBoss

+(NRobotBoss*)cons_with:(GameEngineLayer*)g {
	return [[NRobotBoss node] cons:g];
}

#define RPOS_CAT_TAUNT_POS ccp(400,300)
#define RPOS_CAT_DEFAULT_POS ccp(1500,500)
#define RPOS_ROBOT_DEFAULT_POS ccp(725,0)
#define LPOS_ROBOT_DEFAULT_POS ccp(-650,0)
#define CAPE_WAIT_POS ccp(500,300)
#define CENTER_POS ccp(player.position.x,groundlevel)
#define LERP_TO(pos1,pos2,div) ccp(pos1.x+(pos2.x-pos1.x)/div,pos1.y+(pos2.y-pos1.y)/div)

-(id)cons:(GameEngineLayer*)_g {
	g = _g;
	[self setScale:1];
	
	robot_body = [NRobotBossBody cons];
	[self addChild:robot_body];
	
	cat_body = [NCatBossBody cons];
	[self addChild:cat_body];
	
	[self set_bounds_and_ground:g];
	
	cat_body_rel_pos = ccp(2000,800);
	robot_body_rel_pos = ccp(1500,0);
	
	head_chaser = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_ENEMY_ROBOTBOSS]
															rect:[FileCache get_cgrect_from_plist:TEX_ENEMY_ROBOTBOSS idname:@"head"]];
	[self addChild:head_chaser];
	[head_chaser setVisible:NO];
	
	fist_projectiles = [NSMutableArray array];
	
	cur_mode = NRobotBossMode_CAT_IN_RIGHT1;
	
	if ([GameMain GET_BOSS_1_HEALTH]) {
		hp = 1;
	} else {
		hp = 3;
	}
	
	cape_item_body = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_ITEM_SS] rect:[FileCache get_cgrect_from_plist:TEX_ITEM_SS idname:@"pickup_dogcape"]];
	[cape_item_body csf_setScale:1.75];
	[cape_item_body setVisible:NO];
	[self addChild:cape_item_body];
	
	self.active = YES;
	return self;
}

#define ZOOMOUT 270
-(void)update:(Player *)player g:(GameEngineLayer *)_g {
	[self set_bounds_and_ground:g];
	
	[robot_body setPosition:CGPointAdd(CENTER_POS, robot_body_rel_pos)];
	[robot_body update:robot_body_rel_pos g:g];
	
	[cat_body setPosition:CGPointAdd(CENTER_POS, cat_body_rel_pos)];
	[cat_body update];
	
	if (last_robot_body_rel_pos.x != robot_body_rel_pos.x) {
		float delta = ABS(last_robot_body_rel_pos.x - robot_body_rel_pos.x);
		if (delta > 10) {
			spark_emit_rate = 1;
		} else if (delta > 2) {
			spark_emit_rate = 5;
		} else if (delta > 1) {
			spark_emit_rate = 10;
		} else if (delta > 0.5) {
			spark_emit_rate = 20;
		
		} else {
			spark_emit_rate += 100;
		}
		
	} else if (spark_emit_rate < 99999) {
		spark_emit_rate+=1000;
	}
	
	if (int_random(0, (int)spark_emit_rate) == 0) {
		[g add_particle:[[[[[[StreamParticle cons_x:robot_body.position.x + float_random(-125, -95)
												  y:robot_body.position.y
												 vx:float_random(-8, -3)
												 vy:float_random(0.5, 12)]
							 set_color:ccc3(251,232,52)]
							set_scale_x:0.75 y:2]
						   set_ctmax:10]
						  set_vel_rotation_facing]
						 set_relpos:player.position]];
	}
	if (int_random(0, (int)spark_emit_rate) == 0) {
		[g add_particle:[[[[[[[StreamParticle cons_x:robot_body.position.x + float_random(95, 125)
												   y:robot_body.position.y
												  vx:float_random(3, 8)
												  vy:float_random(0.5, 12)]
							  set_color:ccc3(251,232,52)]
							 set_scale_x:0.75 y:2]
							set_ctmax:10]
						   set_vel_rotation_facing]
						  set_relpos:player.position]
						 set_render_ord:[GameRenderImplementation GET_RENDER_ABOVE_FG_ORD]]];
	}
	
	last_robot_body_rel_pos = robot_body_rel_pos;
	
	if (cur_mode == NRobotBossMode_TOREMOVE) {
		[g remove_gameobject:self];
		return;
		
	} else if (cur_mode == NRobotBossMode_CAT_IN_RIGHT1) {
		[g set_target_camera:[Common cons_normalcoord_camera_zoom_x:94 y:38 z:131]];
		[cat_body csf_setScaleX:-1];
		[robot_body csf_setScaleX:-1];
		[self update_cat_body_flyin_to:RPOS_CAT_TAUNT_POS transition_to:NRobotBossMode_CAT_TAUNT_RIGHT1];
		if (cur_mode != NRobotBossMode_CAT_IN_RIGHT1) {
			[AudioManager playsfx:SFX_CAT_LAUGH];
		}
		
	} else if (cur_mode == NRobotBossMode_CAT_TAUNT_RIGHT1) {
		[self update_taunt_transition_to:NRobotBossMode_CAT_ROBOT_IN_RIGHT1];
		
	} else if (cur_mode == NRobotBossMode_CAT_ROBOT_IN_RIGHT1) {
		[self update_robot_body_in_robotpos:ccp(1500,0) catpos:RPOS_CAT_DEFAULT_POS transition_to:NRobotBossMode_CHOOSING];
		if (cur_mode != NRobotBossMode_CAT_ROBOT_IN_RIGHT1) {
			
			//attack_ct = 0;
			attack_ct = int_random(0, 10);
			if (attack_ct%2==1) {
				[self attack_throwfist_right];
			} else {
				[self attack_wallrockets_right];
			}
			//[self attack_wallrockets_right];
			//[self attack_throwfist_right];
			//cur_mode = NRobotBossMode_ATTACK_CHARGE_LEFT;
			//robot_body_rel_pos = LPOS_ROBOT_DEFAULT_POS;
			//cur_mode = NRobotBossMode_ATTACK_CHARGE_RIGHT;
			
			[AudioManager playsfx:SFX_BOSS_ENTER];
		}

	} else if (cur_mode == NRobotBossMode_ATTACK_WALLROCKETS_IN) {
		[robot_body csf_setScaleX:-1];
		[g set_target_camera:[Common cons_normalcoord_camera_zoom_x:54 y:54 z:ZOOMOUT]];
		[self update_robot_body_in_robotpos:RPOS_ROBOT_DEFAULT_POS catpos:RPOS_CAT_DEFAULT_POS transition_to:NRobotBossMode_CHOOSING];
		if (cur_mode != NRobotBossMode_ATTACK_WALLROCKETS_IN) {
			cur_mode = NRobotBossMode_ATTACK_WALLROCKETS;
			delay_ct = 100;
		}
		
	} else if (cur_mode == NRobotBossMode_ATTACK_WALLROCKETS) {
		[robot_body csf_setScaleX:-1];
		[g set_target_camera:[Common cons_normalcoord_camera_zoom_x:54 y:54 z:ZOOMOUT]];
		if (delay_ct < 75) {
			[robot_body do_fire];
		}
		delay_ct-=[Common get_dt_Scale];
		if (delay_ct <= 0) {
			float mvx = -7, mvy = 2 * sinf(tmp_ct/8.0 * 3.14 * 3 - 3.14/2 + pattern_ct * 3.14/2) + float_random(-2.5, 2.5);
			if (tmp_ct > 0) {
				delay_ct = 20;
				tmp_ct--;
				
			} else {
				delay_ct = 80;
				tmp_ct = 8;
				pattern_ct--;
				if (pattern_ct <= 0) {
					delay_ct = 200;
					pattern_ct = 5;
					cur_mode = NRobotBossMode_ATTACK_CHARGE_LEFT;
					[AudioManager playsfx:SFX_BOSS_ENTER];
				}
			}
			[robot_body arm_fire];
			[AudioManager playsfx:SFX_ROCKET_LAUNCH];
			[g add_particle:[[CannonFireParticle cons_x:[self get_arm_fire_position].x+75 y:[self get_arm_fire_position].y+15] set_scale:1.4]];
			[g add_gameobject:(GameObject*)[[[RelativePositionLauncherRocket cons_at:[self get_arm_fire_position]
																player:player.position
																   vel:ccp(mvx,mvy)] set_remlimit:1000] set_scale:1.4]];
		}
		
	} else if (cur_mode == NRobotBossMode_ATTACK_CHARGE_LEFT) {
		delay_ct-=[Common get_dt_Scale];
		[robot_body stop_fire];
		[robot_body csf_setScaleX:-1];
		[g set_target_camera:[Common cons_normalcoord_camera_zoom_x:54 y:54 z:ZOOMOUT]];
		if (delay_ct < 170) {
			[robot_body set_passive_rotation_theta_speed:0.2];
		}
		if (delay_ct <= 120 && pattern_ct >= 5) {
			[robot_body hop];
			pattern_ct--;
		} else if (delay_ct <= 55 && pattern_ct >= 4) {
			[robot_body hop];
			pattern_ct--;
		} else if (delay_ct <= 35 & pattern_ct >= 3) {
			[robot_body hop];
			pattern_ct--;
		} else if (delay_ct <= 15 && pattern_ct >= 2) {
			[robot_body hop];
			pattern_ct--;
		} else if (delay_ct <= 5 && pattern_ct >= 1) {
			pattern_ct--;
			[AudioManager playsfx:SFX_BOSS_ENTER];
			
		} else if (delay_ct <= 0) {
			robot_body_rel_pos.x -= 12.5*[Common get_dt_Scale];
			if (robot_body_rel_pos.x < -500) {
				if ([robot_body headless]) {
					delay_ct = 1;
					cur_mode = NRobotBossMode_HEAD_CHASE_LEFT;
				} else {
					[self attack_stream_homing_left];
				}
				[robot_body end_headless];
				[robot_body set_passive_rotation_theta_speed:0.09];
				robot_body_rel_pos.x = -1500;
			}
		}
		
		if (!robot_body.headless && [Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]) {
			if (player.dashing || player.is_armored) {
				[robot_body headless_flyoff];
				[g add_particle:[[RelativePositionExplosionParticle cons_x:robot_body.position.x y:robot_body.position.y+290 player:player.position] set_scale:2.5]];
				[g add_particle:[NRobotBossHeadFlyoffParticle cons_pos:CGPointAdd(robot_body.position, ccp(0,290))
																   vel:CGPointAdd(ccp(player.vx*1.3,player.vy*1.3), ccp(0,5)) player:player.position]];
				[AudioManager playsfx:SFX_EXPLOSION];
				hp--;
				if (hp <= 0) {
					delay_ct = 0;
					cur_mode = NRobotBossMode_EXPLODE_OUT;
				}
				[g shake_for:10 intensity:4];
				[g freeze_frame:6];
				
			} else if (!player.dead) {
				[DazedParticle cons_effect:g tar:player time:40];
				[player add_effect:[HitEffect cons_from:[player get_default_params] time:40]];
				[AudioManager playsfx:SFX_HIT];
				[g.get_stats increment:GEStat_ROBOT];
				cur_mode = NRobotBossMode_WAIT;
				[g shake_for:15 intensity:6];
				[g freeze_frame:6];
			}
		}
		
	} else if (cur_mode == NRobotBossMode_HEAD_CHASE_LEFT) {
		if (delay_ct > 0) {
			delay_ct = -20;
			head_chaser_rel_pos = ccp(2000,500);
			[AudioManager playsfx:SFX_BOSS_ENTER];
			[AudioManager playsfx:SFX_ROCKET];
		}
		
		delay_ct+=[Common get_dt_Scale];
		if (delay_ct > 0) {
			delay_ct = -20;
			[AudioManager playsfx:SFX_ROCKET];
		}
		
		
		[head_chaser csf_setScaleX:-1];
		[head_chaser setVisible:YES];
		head_chaser_rel_pos.x -= 20*[Common get_dt_Scale];
		[g add_particle:[RocketParticle cons_x:head_chaser.position.x+65 y:head_chaser.position.y-20+float_random(-10, 10)]];
		
		[head_chaser setPosition:CGPointAdd(CENTER_POS, head_chaser_rel_pos)];
		if (head_chaser_rel_pos.x < -1000) {
			[self attack_stream_homing_left];
		}
		
		
	} else if (cur_mode == NRobotBossMode_ATTACK_STREAMHOMING_IN) {
		[g set_target_camera:[Common cons_normalcoord_camera_zoom_x:320 y:54 z:ZOOMOUT]];
		[robot_body csf_setScaleX:1];
		[self update_robot_body_in_robotpos:LPOS_ROBOT_DEFAULT_POS catpos:RPOS_CAT_DEFAULT_POS transition_to:NRobotBossMode_CHOOSING];
		if (cur_mode != NRobotBossMode_ATTACK_STREAMHOMING_IN) {
			cur_mode = NRobotBossMode_ATTACK_STREAMHOMING;
			delay_ct = 100;
		}
		
	} else if (cur_mode == NRobotBossMode_ATTACK_STREAMHOMING) {
		[g set_target_camera:[Common cons_normalcoord_camera_zoom_x:320 y:54 z:ZOOMOUT]];
		if (delay_ct < 75) {
			[robot_body do_fire];
		}
		[robot_body csf_setScaleX:1];
		delay_ct-=[Common get_dt_Scale];
		if (delay_ct <= 0) {
			float mvx = 6, mvy = 0;
			if (tmp_ct == 2) {
				mvy = 3;
			} else if (tmp_ct == 1) {
				mvy = 0;
			} else {
				mvy = -3;
			}
			
		
			if (tmp_ct > 0) {
				delay_ct = 40;
				tmp_ct--;
				
			} else {
				delay_ct = 230;
				tmp_ct = 2;
				pattern_ct--;
				if (pattern_ct <= 0) {
					delay_ct = 200;
					pattern_ct = 5;
					cur_mode = NRobotBossMode_ATTACK_CHARGE_RIGHT;
				}
			}
			[robot_body arm_fire];
			[AudioManager playsfx:SFX_ROCKET_LAUNCH];
			[g add_particle:[[CannonFireParticle cons_x:[self get_arm_fire_position].x+75 y:[self get_arm_fire_position].y+15] set_scale:1.4]];
			[g add_gameobject:[(RelativePositionLauncherRocket*)[[[RelativePositionLauncherRocket cons_at:[self get_arm_fire_position2]
																			  player:player.position
																				 vel:ccp(mvx,mvy)] set_remlimit:300] set_scale:1.4] set_homing]];
		}
	} else if (cur_mode == NRobotBossMode_ATTACK_CHARGE_RIGHT) {
		delay_ct-=[Common get_dt_Scale];
		[robot_body stop_fire];
		[robot_body csf_setScaleX:1];
		[g set_target_camera:[Common cons_normalcoord_camera_zoom_x:320 y:54 z:ZOOMOUT]];
		if (delay_ct < 170) {
			[robot_body set_passive_rotation_theta_speed:0.2];
		}
		if (delay_ct <= 120 && pattern_ct >= 5) {
			[robot_body hop];
			pattern_ct--;
		} else if (delay_ct <= 55 && pattern_ct >= 4) {
			[robot_body hop];
			pattern_ct--;
		} else if (delay_ct <= 35 & pattern_ct >= 3) {
			[robot_body hop];
			pattern_ct--;
		} else if (delay_ct <= 15 && pattern_ct >= 2) {
			[robot_body hop];
			pattern_ct--;
		} else if (delay_ct <= 5 && pattern_ct >= 1) {
			pattern_ct--;
			[AudioManager playsfx:SFX_BOSS_ENTER];
			
		} else if (delay_ct <= 0) {
			robot_body_rel_pos.x += 12.5*[Common get_dt_Scale];
			if (robot_body_rel_pos.x > 800) {
				attack_ct++;
				
				if ([robot_body headless]) {
					delay_ct = 1;
					cur_mode = NRobotBossMode_HEAD_CHASE_RIGHT;
				} else {
					if (attack_ct%2==1) {
						[self attack_throwfist_right];
					} else {
						[self attack_wallrockets_right];
					}
				}
				[robot_body end_headless];
				
				[robot_body set_passive_rotation_theta_speed:0.09];
				robot_body_rel_pos.x = 1500;
			}
		}
		
		if (!robot_body.headless && [Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]) {
			if (player.dashing || player.is_armored) {
				[robot_body headless_flyoff];
				[g add_particle:[[RelativePositionExplosionParticle cons_x:robot_body.position.x y:robot_body.position.y+290 player:player.position] set_scale:2.5]];
				[g add_particle:[NRobotBossHeadFlyoffParticle cons_pos:CGPointAdd(robot_body.position, ccp(0,290))
																   vel:CGPointAdd(ccp(-player.vx*0.6,player.vy*1), ccp(-5,3)) player:player.position]];
				[AudioManager playsfx:SFX_EXPLOSION];
				hp--;
				if (hp <= 0) {
					delay_ct = 0;
					cur_mode = NRobotBossMode_EXPLODE_OUT;
				}
				[g shake_for:10 intensity:4];
				[g freeze_frame:6];
				
			} else if (!player.dead) {
				[DazedParticle cons_effect:g tar:player time:40];
				[player add_effect:[HitEffect cons_from:[player get_default_params] time:40]];
				[AudioManager playsfx:SFX_HIT];
				[g.get_stats increment:GEStat_ROBOT];
				cur_mode = NRobotBossMode_WAIT;
				
				[g shake_for:15 intensity:6];
				[g freeze_frame:6];
			}
		}
		
	} else if (cur_mode == NRobotBossMode_HEAD_CHASE_RIGHT) {
		if (delay_ct > 0) {
			delay_ct = -20;
			head_chaser_rel_pos = ccp(-2000,500);
			[AudioManager playsfx:SFX_BOSS_ENTER];
			[AudioManager playsfx:SFX_ROCKET];
		}
		
		delay_ct+=[Common get_dt_Scale];
		if (delay_ct > 0) {
			delay_ct = -20;
			[AudioManager playsfx:SFX_ROCKET];
		}
		
		
		[head_chaser csf_setScaleX:1];
		[head_chaser setVisible:YES];
		head_chaser_rel_pos.x += 20*[Common get_dt_Scale];
		[g add_particle:[RocketParticle cons_x:head_chaser.position.x-65 y:head_chaser.position.y-20+float_random(-10, 10)]];
		
		[head_chaser setPosition:CGPointAdd(CENTER_POS, head_chaser_rel_pos)];
		if (head_chaser_rel_pos.x > 1000) {
			if (attack_ct%2==1) {
				[self attack_throwfist_right];
			} else {
				[self attack_wallrockets_right];
			}
			[head_chaser setVisible:NO];
		}
		
		
		
	} else if (cur_mode == NRobotBossMode_ATTACK_THROWFIST_IN) {
		[robot_body csf_setScaleX:-1];
		[g set_target_camera:[Common cons_normalcoord_camera_zoom_x:54 y:54 z:ZOOMOUT]];
		[self update_robot_body_in_robotpos:RPOS_ROBOT_DEFAULT_POS catpos:RPOS_CAT_DEFAULT_POS transition_to:NRobotBossMode_CHOOSING];
		if (cur_mode != NRobotBossMode_ATTACK_THROWFIST_IN) {
			cur_mode = NRobotBossMode_ATTACK_THROWFIST;
			delay_ct = 100;
		}
		
	} else if (cur_mode == NRobotBossMode_ATTACK_THROWFIST) {
		
		if (fist_projectiles.count == 0) {
			if ([robot_body get_swing_state] == NRBCSwingState_NONE) {
				[robot_body do_swing];
				
			} else if ([robot_body get_swing_state] == NRBCSwingState_PEAK) {
				volley_ct = 2;
				[robot_body swing_peak_throw];
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
		} else {
			for (int i = (int)fist_projectiles.count-1; i >= 0; i--) {
				VolleyRobotBossFistProjectile *p = fist_projectiles[i];
				
				if ([robot_body get_swing_state] == NRBCSwingState_PEAK) [robot_body swing_peak_throw];
				
				if (volley_ct > 0) {
					if (p.direction == RobotBossFistProjectileDirection_AT_BOSS) {
						if (p.time_left < 20 && [robot_body get_swing_state] == NRBCSwingState_NONE)  {
							[robot_body do_swing];
							
						}
						if (p.time_left <= 15) {
							[AudioManager playsfx:SFX_ROCKBREAK];
							[AudioManager playsfx:SFX_BOSS_ENTER];
							
							p.direction = RobotBossFistProjectileDirection_AT_PLAYER;
							[p mode_parabola_a];
							[p set_startpos:ccp(p.position.x-g.player.position.x,p.position.y-groundlevel)
									 tarpos:ccp(0,0)
								  time_left:60
								 time_total:60];
							[self add_pow:CGPointAdd(p.position, ccp(0,100)) dir:ccp(0.5,-0.5) scx:1];
							volley_ct--;
							
						}
					}
				} else {
					if (p.direction == RobotBossFistProjectileDirection_AT_BOSS && p.time_left <= 5) {
						delay_ct = 20;
						[p force_remove];
						
						[robot_body hurt_anim];
						delay_ct = 200;
						pattern_ct = 5;
						cur_mode = NRobotBossMode_ATTACK_CHARGE_LEFT;
						[AudioManager playsfx:SFX_BOSS_ENTER];
						
						[g freeze_frame:6];
						[g shake_for:15 intensity:4];
					}
				}
				
				if ([p should_remove]) {
					[g add_particle:[[ExplosionParticle cons_x:p.position.x y:p.position.y] set_scale:1.5]];
					[fist_projectiles removeObject:p];
					[g remove_gameobject:p];
					[AudioManager playsfx:SFX_EXPLOSION];
				}
				
			}
			
		}
		
	} else if (cur_mode == NRobotBossMode_EXPLODE_OUT) {
		delay_ct++;
		[robot_body.frontarm setOpacity:200];
		[robot_body.body setOpacity:200];
		[robot_body.backarm setOpacity:200];
		[robot_body stop_rotate];
		
		if (delay_ct > 150) {
			for(float i = 0; i < 5; i++) {
				[g add_particle:[BrokenCopterMachineParticle cons_robot_x:robot_body.position.x + float_random(-130, 130)
																	  y:robot_body.position.y + float_random(0, 350)
																	 vx:float_random(-5, 10)
																	 vy:float_random(-10, 10)
																   pimg:i]];
			}
			[AudioManager playsfx:SFX_BIG_EXPLOSION];
			cur_mode = NRobotBossMode_CAPE_OUT;
			cape_item_rel_pos = ccp(1200,800);
			[robot_body setVisible:NO];
			pattern_ct = 0;
			[g shake_for:40 intensity:10];

		} else if (((int) delay_ct) % 10 == 0) {
			[g add_particle:[RelativePositionExplosionParticle cons_x:robot_body.position.x + float_random(-130, 130)
																	y:robot_body.position.y + float_random(0, 350)
															   player:player.position]];
			[AudioManager playsfx:SFX_EXPLOSION];
			[g shake_for:15 intensity:4];
		}
		
	} else if (cur_mode == NRobotBossMode_CAPE_OUT) {
		tmp_ct += 0.075;
		[cape_item_body setRotation:sinf(tmp_ct)*12.5];
		
		[g set_target_camera:[Common cons_normalcoord_camera_zoom_x:54 y:54 z:ZOOMOUT]];
		[cape_item_body setVisible:YES];
		[robot_body setVisible:NO];
		[cape_item_body setPosition:CGPointAdd(player.position, cape_item_rel_pos)];
		
		if (pattern_ct == 0) {
			cape_item_rel_pos = LERP_TO(cape_item_rel_pos, CAPE_WAIT_POS, 15.0);
			if (CGPointDist(cape_item_rel_pos, CAPE_WAIT_POS) < 20) {
				pattern_ct = 1;
				delay_ct = 75;
			}
			
		} else if (pattern_ct == 1) {
			delay_ct-=[Common get_dt_Scale];
			if (delay_ct <= 0) pattern_ct = 2;
			
		} else {
			cape_item_rel_pos = LERP_TO(cape_item_rel_pos, CGPointZero, 15.0);
			if (CGPointDist(cape_item_body.position, player.position) < 50) {
				[AudioManager playsfx:SFX_POWERUP];
				[cape_item_body setVisible:NO];
				cur_mode = NRobotBossMode_TOREMOVE;
				[GEventDispatcher push_event:[GEvent cons_type:GEventType_BEGIN_BOSS_CAPE_GAME]];
			}
		}
	
	}
}

-(void)add_pow:(CGPoint)pos dir:(CGPoint)dir scx:(float)scx {
	[g add_particle:[[[JumpParticle cons_pt:pos
										vel:dir
										 up:ccp(0,1)
										tex:[Resource get_tex:TEX_ENEMY_ROBOTBOSS]
									   rect:[FileCache get_cgrect_from_plist:TEX_ENEMY_ROBOTBOSS idname:@"pow"] relpos:YES] set_scale:0.3] set_scx:scx]];
}

-(CGPoint)get_arm_fire_position {
	return CGPointAdd(robot_body.position, ccp(-200,120));
}

-(CGPoint)get_arm_fire_position2 {
	return CGPointAdd(robot_body.position, ccp(200,120));
}

-(void)attack_stream_homing_left {
	cur_mode = NRobotBossMode_ATTACK_STREAMHOMING_IN;
	delay_ct = 0;
	tmp_ct = 2;
	pattern_ct = 3;
}

-(void)attack_wallrockets_right {
	cur_mode = NRobotBossMode_ATTACK_WALLROCKETS_IN;
	delay_ct = 0;
	tmp_ct = 8;
	pattern_ct = 3;
}

-(void)attack_throwfist_right {
	cur_mode = NRobotBossMode_ATTACK_THROWFIST_IN;
	delay_ct = 0;
	tmp_ct = 0;
	pattern_ct = 0;
}

-(void)reset {
	[super reset];
	cur_mode = NRobotBossMode_TOREMOVE;
}

-(void)check_should_render:(GameEngineLayer *)g { do_render = YES; }
-(int)get_render_ord{ return [GameRenderImplementation GET_RENDER_BTWN_PLAYER_ISLAND]; }

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

-(void)update_cat_body_flyin_to:(CGPoint)tar transition_to:(NRobotBossMode)mode {
	[cat_body stand_anim];
	cat_body_rel_pos = LERP_TO(cat_body_rel_pos, tar, 15.0);
	
	if (CGPointDist(cat_body_rel_pos, tar) < 10) {
		cur_mode = mode;
		[cat_body laugh_anim];
		delay_ct = 80;
	}
}

-(void)update_taunt_transition_to:(NRobotBossMode)mode {
	delay_ct-=[Common get_dt_Scale];
	if (delay_ct <= 0) {
		cur_mode = mode;
		[cat_body stand_anim];
	}
}

-(void)update_robot_body_in_robotpos:(CGPoint)robot_pos catpos:(CGPoint)cat_pos transition_to:(NRobotBossMode)mode {
	cat_body_rel_pos = LERP_TO(cat_body_rel_pos, cat_pos, 15.0);
	robot_body_rel_pos = LERP_TO(robot_body_rel_pos, robot_pos, 25.0);
	if (CGPointDist(cat_body_rel_pos, cat_pos) < 100 && CGPointDist(robot_body_rel_pos, robot_pos) < 15) {
		cur_mode = mode;
		delay_ct = 20;
	}
}

-(HitRect) get_hit_rect {
	return [Common hitrect_cons_x1:robot_body.position.x-120 y1:robot_body.position.y wid:240 hei:250];
}

@end