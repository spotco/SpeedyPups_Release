#import "SubBoss.h"
#import "GameEngineLayer.h"
#import "BGLayer.h"
#import "Lab2BGLayerSet.h"
#import "EnemyBomb.h"
#import "UICommon.h"
#import "LauncherRocket.h"
#import "GameRenderImplementation.h"
#import "JumpPadParticle.h"
#import "HitEffect.h"
#import "DazedParticle.h"
#import "ExplosionParticle.h"
#import "BrokenMachineParticle.h"
#import "NRobotBossComponents.h"
#import "GameMain.h"
#import "ScoreManager.h"

@interface FGWater : GameObject {
	CCSprite *body;
}
+(FGWater*)cons;
@property (readwrite,assign) float offset;
@property (readwrite,strong) CSF_CCSprite *periscope;
@end

@implementation FGWater
@synthesize offset;
@synthesize periscope;
+(FGWater*)cons {
	return [[FGWater node] cons_];
}
-(id)cons_ {
	periscope = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_ENEMY_SUBBOSS] rect:[FileCache get_cgrect_from_plist:TEX_ENEMY_SUBBOSS idname:@"spyglass"]];
	[self addChild:periscope];
	[self setScale:1];
	
	body = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_LAB2_WATER_FG]];
	
	ccTexParams par = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_CLAMP_TO_EDGE};
	[body.texture setTexParameters:&par];
	
	[self addChild:body];
	active = YES;
	[periscope csf_setScaleX:-1];
	return self;
}
-(void)water_update:(CGPoint)player_pos {
	player_pos.x *= 0.6;
	float xpos = ((int)(player_pos.x))%body.texture.pixelsWide + ((player_pos.x) - ((int)(player_pos.x)));
	[body setTextureRect:CGRectMake(
		xpos,
		0,
		[Common SCREEN].width*4,
		[body textureRect].size.height
	)];
	
}
-(void)check_should_render:(GameEngineLayer *)g {
	do_render = YES;
}
-(int)get_render_ord {
	return [GameRenderImplementation GET_RENDER_ABOVE_FG_ORD];
}
@end

@implementation SubBoss

+(SubBoss*)cons_with:(GameEngineLayer *)g {
	return [[SubBoss node] cons:g];
}

#define RPOS_CAT_TAUNT_POS ccp(300,250)
#define RPOS_CAT_DEFAULT_POS ccp(1500,500)
#define CENTER_POS ccp(player.position.x,groundlevel)
#define LERP_TO(pos1,pos2,div) ccp(pos1.x+(pos2.x-pos1.x)/div,pos1.y+(pos2.y-pos1.y)/div)

-(id)cons:(GameEngineLayer*)g {
	[self setScale:1];
	
	[self cons_anims];
	body = [CSF_CCSprite node];
	hatch = [CCSprite node];
	[self addChild:body];
	[hatch setAnchorPoint:ccp(0.5,0)];
	[body addChild:hatch];
	
	[hatch setPosition:ccp(215/CC_CONTENT_SCALE_FACTOR(),195/CC_CONTENT_SCALE_FACTOR())];
	
	[self run_body_anim:_anim_body_normal];
	[hatch runAction:_anim_hatch_closed];
	
	active = YES;
	do_render = YES;
	
	bgobj = [[g get_bg_layer] get_subboss_bgobject];
	
	current_mode = SubMode_Intro;
	[bgobj setPosition:ccp(-100,bgobj.position.y)];
	ct = 0;
	pick_ct = int_random(0, 99);
	
	[bgobj csf_setScale:1];
	
	[bgobj setVisible:NO];
	[body setVisible:NO];
	
	fgwater = [FGWater cons];
	fgwater.offset = 1000;
	[g add_gameobject:fgwater];
	
	[AudioManager playsfx:SFX_BOSS_ENTER];
	
	if ([GameMain GET_BOSS_1_HEALTH]) {
		hp = 1;
	} else {
		hp = 4;
	}
	
	cat_body = [NCatBossBody cons];
	[self addChild:cat_body];
	cat_body_rel_pos = ccp(2000,800);
	[cat_body csf_setScale:0.85];
	[cat_body setVisible:YES];
	cat_mode = SubBossCatIntroMode_In;
	cat_anim_done = NO;
	
	return self;
}

-(void)update_cat_body_flyin_to:(CGPoint)tar transition_to:(SubBossCatIntroMode)mode {
	[cat_body stand_anim];
	cat_body_rel_pos = LERP_TO(cat_body_rel_pos, tar, 15.0);
	
	if (CGPointDist(cat_body_rel_pos, tar) < 10) {
		cat_mode = mode;
		[cat_body laugh_anim];
		delay_ct = 80;
	}
}

-(void)update_taunt_transition_to:(SubBossCatIntroMode)mode {
	delay_ct-=[Common get_dt_Scale];
	if (delay_ct <= 0) {
		cat_mode = mode;
		[cat_body stand_anim];
	}
}

-(void)update_robot_body_in_robotpos:(CGPoint)robot_pos catpos:(CGPoint)cat_pos transition_to:(SubBossCatIntroMode)mode {
	cat_body_rel_pos = LERP_TO(cat_body_rel_pos, cat_pos, 15.0);
	if (CGPointDist(cat_body_rel_pos, cat_pos) < 100) {
		cat_mode = mode;
		delay_ct = 20;
	}
}

static CGPoint last_pos;
-(void)update:(Player *)player g:(GameEngineLayer *)g {
	[self set_bounds_and_ground:g];
	
	fgwater.offset += (220-fgwater.offset)/10.0;
	[fgwater setPosition:ccp(player.position.x,groundlevel-fgwater.offset)];
	[fgwater water_update:player.position];
	CCSprite *periscope = fgwater.periscope;
	[periscope setVisible:NO];
	
	
	//[TouchTrackingLayer set_test_pos:];
	
	if ([Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]] && body.visible && !player.dead) {
	
		if (current_mode == SubMode_Flyoff
			|| current_mode == SubMode_DeadExplode
			|| current_mode == SubMode_ToRemove
			|| current_mode == SubMode_DeadAfter) goto NoHit;
	
		if (player.dashing || [player is_armored]) {
			current_mode = SubMode_Flyoff;
			Vec3D playerdir = [VecLib scale:[VecLib normalized_x:player.vx y:player.vy z:0] by:14];
			flyoff_dir = ccp(playerdir.x,playerdir.y);
			[self run_body_anim:_anim_body_normal];
			[body setOpacity:180];
			[AudioManager playsfx:SFX_ROCKBREAK];
			[AudioManager playsfx:SFX_ROCKET_SPIN];
			hp--;
			if (hp <= 0) {
				current_mode = SubMode_DeadExplode;
				ct = 130;
			}
			[g shake_for:10 intensity:4];
			[g freeze_frame:6];
			
		} else {
			[player add_effect:[HitEffect cons_from:[player get_default_params] time:40]];
            [DazedParticle cons_effect:g tar:player time:40];
            [AudioManager playsfx:SFX_HIT];
            [g.get_stats increment:GEStat_ROBOT];
			[g shake_for:15 intensity:6];
			[g freeze_frame:6];
		}
	}
NoHit:
	
	if (current_mode == SubMode_ToRemove) {
		[g remove_gameobject:self];
		[g remove_gameobject:fgwater];
		
	} else if (current_mode == SubMode_DeadAfter) {
		[g remove_gameobject:self];
		
	} else if (current_mode == SubMode_DeadExplode) {
		[bgobj setVisible:NO];
		[body setVisible:YES];
		[body setOpacity:160];
		[body setRotation:body.rotation+15*[Common get_dt_Scale]];
		ct-=[Common get_dt_Scale];
		sub_submode++;
		if (sub_submode%15==0 && sub_submode > 20) {
			[g add_particle:[RelativePositionExplosionParticle cons_x:body.position.x+float_random(-60, 60)
																	y:body.position.y+float_random(-60, 60)
															   player:g.player.position]];
			[AudioManager playsfx:SFX_EXPLOSION];
			[g shake_for:15 intensity:6];
		}
		
		sub_submode%5==0?[g add_particle:[RocketLaunchParticle cons_x:body.position.x
														   y:body.position.y
														  vx:float_random(-7, 7)
														  vy:float_random(-7, 7)]]:0;
		
		[body setPosition:ccp(player.position.x+body_rel_pos.x,groundlevel+body_rel_pos.y)];
		if (ct <= 0) {
			current_mode = SubMode_DeadAfter;
			for(float i = 0; i < 5; i++) {
				[g add_particle:[BrokenCopterMachineParticle cons_sub_x:body.position.x
																  y:body.position.y
																 vx:float_random(-5, 10)
																 vy:float_random(-10, 10)
															   pimg:i]];
			}
			[AudioManager playsfx:SFX_BIG_EXPLOSION];
			[GEventDispatcher push_event:[[GEvent cons_type:GEventType_BOSS2_DEFEATED] add_pt:g.player.position]];
			[g.score increment_score:1000];
			[g shake_for:40 intensity:10];
		}
		
	} else if (current_mode == SubMode_Flyoff) {
		[body setRotation:[body rotation] + 15*[Common get_dt_Scale]];
		body_rel_pos.x += flyoff_dir.x * [Common get_dt_Scale];
		body_rel_pos.y += flyoff_dir.y * [Common get_dt_Scale];
		[body setPosition:ccp(player.position.x+body_rel_pos.x,groundlevel+body_rel_pos.y)];
		
		ct++;
		((int)ct)%3==0?[g add_particle:[RocketLaunchParticle cons_x:body.position.x
														   y:body.position.y
														  vx:-flyoff_dir.x + float_random(-4, 4)
														  vy:-flyoff_dir.y + float_random(-4, 4)
													   scale:float_random(1, 3)]]:0;
		
		if (body_rel_pos.x > 1200 || body_rel_pos.x < -1200 || body_rel_pos.y > 1200 || body_rel_pos.y < -1200) {
			[self pick_next_move];
		}
		
	} else if (current_mode == SubMode_Intro) {
		[bgobj setVisible:YES];
		[body setVisible:NO];
		[bgobj csf_setScaleX:1];
		[g set_target_camera:[Common cons_normalcoord_camera_zoom_x:120 y:110 z:240]];
		[bgobj setPosition:ccp(bgobj.position.x+2*[Common get_dt_Scale],bgobj.position.y)];
		
		if (cat_mode == SubBossCatIntroMode_In) {
			[cat_body csf_setScaleX:-1];
			[self update_cat_body_flyin_to:RPOS_CAT_TAUNT_POS transition_to:SubBossCatIntroMode_Taunt];
			if (cat_mode != SubBossCatIntroMode_In) {
				[AudioManager playsfx:SFX_CAT_LAUGH];
			}
			
			
		} else if (cat_mode == SubBossCatIntroMode_Taunt) {
			[self update_taunt_transition_to:SubBossCatIntroMode_Out];
			
		} else if (cat_mode == SubBossCatIntroMode_Out) {
			[self update_robot_body_in_robotpos:ccp(1500,0) catpos:RPOS_CAT_DEFAULT_POS transition_to:SubBossCatIntroMode_None];
			if (cat_mode != SubBossCatIntroMode_Out) {
				[cat_body setVisible:NO];
				cat_anim_done = YES;
			}
		}
		[cat_body setPosition:CGPointAdd(cat_body_rel_pos,ccp(player.position.x,groundlevel))];
		
		
		if (bgobj.position.x > [Common SCREEN].width+150 && cat_anim_done) {
			[self pick_next_move];
		}
		DO_FOR(2, [bgobj splash_tick:ccp(float_random(-3.5, -1),float_random(2, 8)) offset:ccp(-35,float_random(-17, -13))]);
		
		
	} else if (current_mode == SubMode_BGFireBombs) {
		[g set_target_camera:[Common cons_normalcoord_camera_zoom_x:120 y:110 z:240]];
		[bgobj setVisible:YES];
		[body setVisible:NO];
		[bgobj csf_setScaleX:-1];
		if (bgobj.position.x > [Common SCREEN].width*0.75) {
			[bgobj setPosition:ccp(bgobj.position.x-2*[Common get_dt_Scale],bgobj.position.y)];
			if (bgobj.position.x <= [Common SCREEN].width*0.75) {
				[bgobj anim_hatch_closed_to_cannon];
				sub_submode = 0;
			}
			DO_FOR(2, [bgobj splash_tick:ccp(float_random(1, 3.5),float_random(2, 8)) offset:ccp(35,float_random(-17, -13))]);
			
		} else if (sub_submode >= 0) {
			ct-=[Common get_dt_Scale];
			if (ct <= 0) {
				if (sub_submode > 1) {
					

					
					
					[g add_gameobject:[[RelativePositionEnemyBomb
										cons_pt:[bgobj get_nozzle:g]
										v:ccp(float_random(-13,-4),float_random(5,9))
										player:player.position] do_bg_to_front_anim]];
					[bgobj set_recoil_delta:ccp(10,-10)];
					[bgobj explosion_at_nozzle];
					[AudioManager playsfx:SFX_ROCKET_LAUNCH];
					
					//optional delta time on bombs nah we're good m8
				}
				if (sub_submode%4 == 2 || sub_submode%4 == 3) {
					ct = 20;
				} else {
					ct = 55;
				}
				sub_submode++;
			}
			
			
			if (sub_submode >= 14) {
				sub_submode = -1;
				[bgobj anim_hatch_cannon_to_closed];
			}
			
		} else if (sub_submode < 0) {
			[bgobj setPosition:ccp(bgobj.position.x-2*[Common get_dt_Scale],bgobj.position.y)];
			DO_FOR(2, [bgobj splash_tick:ccp(float_random(1, 3.5),float_random(2, 8)) offset:ccp(35,float_random(-17, -13))]);
			if (bgobj.position.x < -100) {
				[self pick_next_move];
			}
		}
		
	} else if (current_mode == SubMode_BGFireMissiles) {
		[g set_target_camera:[Common cons_normalcoord_camera_zoom_x:120 y:110 z:240]];
		[bgobj setVisible:YES];
		[body setVisible:NO];
		[bgobj csf_setScaleX:-1];
		
		if (bgobj.position.x > -150) {
			ct -= [Common get_dt_Scale];
			if (ct <= 0) {
				sub_submode++;
				if (sub_submode == 2) {
					[bgobj anim_hatch_closed_to_open];
				}
				[bgobj launch_rocket];
				[AudioManager playsfx:SFX_ROCKET_LAUNCH];
				if (sub_submode > 4 && sub_submode%2==0) {
					[g add_gameobject:[[LauncherRocket cons_at:ccp(player.position.x+float_random(900, 1000),groundlevel+600) vel:ccp(0,float_random(-5, -3))] no_vibration]];
				}
				ct = 17;
			}
			DO_FOR(2, [bgobj splash_tick:ccp(float_random(1, 3.5),float_random(2, 8)) offset:ccp(35,float_random(-17, -13))]);
			[bgobj setPosition:CGPointAdd(bgobj.position, ccp(-2*[Common get_dt_Scale],0))];
			
		} else {
			[self pick_next_move];
		}
		
	} else if (current_mode == SubMode_FrontJumpAttack) {
		[g set_target_camera:[Common cons_normalcoord_camera_zoom_x:120 y:110 z:240]];
		[bgobj setVisible:NO];
		[body setVisible:YES];
		[body csf_setScaleX:-1];
		
		float target_rotation = 0;
		
		if (body_rel_pos.x > 500) {
			body_rel_pos.x -= 3 * [Common get_dt_Scale];
			target_rotation = 0;
			[self run_body_anim:_anim_body_normal];
			[self splash_tick:g dir:ccp(float_random(10, 25),float_random(10, 20)) offset:ccp(100,float_random(-50, -30))];
			
			if (body_rel_pos.x <= 500) {
				body_rel_pos.x = 500;
				ct = 50;
				sub_submode = 0;
			}
			
		} else if (sub_submode == 0) {
			target_rotation = 15;
			ct--;
			[self splash_tick:g dir:ccp(float_random(10, 25),float_random(10, 20)) offset:ccp(100,float_random(-50, -30))];
			if (ct <= 0) {
				sub_submode = 1;
				ct = 0;
				[self splash:g at:CGPointAdd(body.position,ccp(60,-15))];
				[AudioManager playsfx:SFX_BOSS_ENTER];
				[AudioManager playsfx:SFX_SPLASH];
				[g shake_for:10 intensity:4];
			}
			
		} else if (sub_submode == 1) {
			body_rel_pos.x -= 6 * [Common get_dt_Scale];
			body_rel_pos.y = (-25.0/5000.0) * (body_rel_pos.x - 500) * (body_rel_pos.x);
			target_rotation = [VecLib get_rotation:[VecLib cons_x:body_rel_pos.x-last_pos.x y:body_rel_pos.y-last_pos.y z:0] offset:0];
			
			ct++;
			if (ct >= 35) {
				[self run_body_anim:_anim_body_bite];
			}
			if (body_rel_pos.x < -50) {
				[self splash:g at:CGPointAdd(body.position,ccp(0,50))];
				[self pick_next_move];
				[AudioManager playsfx:SFX_SPLASH];
				[g shake_for:10 intensity:4];
			}
		}
		
		[body setRotation:body.rotation + (target_rotation - body.rotation)/5];
		[body setPosition:ccp(player.position.x+body_rel_pos.x,groundlevel+body_rel_pos.y)];
		
	} else if (current_mode == SubMode_ScopeQuickJump) {
		[periscope setVisible:YES];
		
		if (sub_submode == 0) {
			[periscope setPosition:ccp(1000,120)];
			sub_submode = 1;
		}
		if (sub_submode == 1) {
			[body setVisible:NO];
			if (periscope.position.x > 400) {
				[periscope setPosition:CGPointAdd(periscope.position, ccp(-5*[Common get_dt_Scale],0))];
				
			} else {
				sub_submode = 2;
				ct = 50;
			}
			
		} else if (sub_submode == 2) {
			ct -= [Common get_dt_Scale];
			if (ct <= 0) sub_submode = 3;
			
		} else if (sub_submode == 3) {
			[body setVisible:NO];
			if (periscope.position.y > -50) {
				[periscope setPosition:CGPointAdd(periscope.position, ccp(0,-6*[Common get_dt_Scale]))];
				
			} else {
				sub_submode = 4;
				ct = 60;
			}
			
		} else if (sub_submode == 4) {
			ct -= [Common get_dt_Scale];
			if (ct <= 0) {
				body_rel_pos = ccp(periscope.position.x,-150);
				[body setPosition:ccp(player.position.x+body_rel_pos.x,groundlevel+body_rel_pos.y)];
				[self splash:g at:CGPointAdd(body.position,ccp(0,150))];
				[AudioManager playsfx:SFX_SPLASH];
				[AudioManager playsfx:SFX_BOSS_ENTER];
				[self run_body_anim:_anim_body_bite];
				sub_submode = 5;
				[g shake_for:10 intensity:4];
			}
			
		} else if (sub_submode == 5) {
			[body setVisible:YES];
			[body csf_setScaleX:-1];
			
			body_rel_pos.x -= 5*[Common get_dt_Scale];
			float x = body_rel_pos.x;
			body_rel_pos.y = -0.006*(x*x)+2.08*x-17.8;
			//quadratic fit through (400,-150), (200,150), (0,0), (-50,-150)
			
			float target_rotation = [VecLib get_rotation:[VecLib cons_x:body_rel_pos.x-last_pos.x y:body_rel_pos.y-last_pos.y z:0] offset:0];
			[body setRotation:body.rotation + (target_rotation - body.rotation)/5];
			
			[body setPosition:ccp(player.position.x+body_rel_pos.x,groundlevel+body_rel_pos.y)];
			
			if (body_rel_pos.x < -50) {
				[self splash:g at:CGPointAdd(body.position,ccp(0,50))];
				[self pick_next_move];
			}
			
		}
		

		
	}
	
	last_pos = body_rel_pos;
}

-(void)splash_tick:(GameEngineLayer*)g dir:(CGPoint)dir offset:(CGPoint)offset {
	CGPoint spot = CGPointAdd(body.position, offset);
	StreamParticle *sp = [[[[StreamParticle cons_x:spot.x
												 y:spot.y
												vx:dir.x
												vy:dir.y]
							set_scale:float_random(1.5, 3)]
						   set_ctmax:16]
						   set_gravity:ccp(0,float_random(-4, -2))];
	[sp setColor:ccc3(200,220,250)];
	[sp set_final_color:ccc3(120+arc4random_uniform(40), 170+arc4random_uniform(20), 220+arc4random_uniform(30))];
	[g add_particle:sp];
}

-(void)splash:(GameEngineLayer*)g at:(CGPoint)pt {
	DO_FOR(30,
		StreamParticle *sp = [[[[StreamParticle cons_x:pt.x + float_random(-40, 40)
													 y:pt.y
													vx:float_random(-12.5, 20)
													vy:float_random(10, 20)]
								set_scale:float_random(0.5, 3)]
							   set_ctmax:25]
							  set_gravity:ccp(0,float_random(-1.5, -1))];
		[sp setColor:ccc3(200,220,250)];
		[sp set_final_color:ccc3(120+arc4random_uniform(40), 170+arc4random_uniform(20), 220+arc4random_uniform(30))];
		[g add_particle:sp];
	);
}

static int pick_mod = 4;
-(void)pick_next_move {
	pick_ct++;
	[body setRotation:0];
	[body setOpacity:255];
	sub_submode = 0;
	if ([self is_broken]) [bgobj set_broken];
	
	if (pick_ct%pick_mod == 0) {
		current_mode = SubMode_BGFireBombs;
		[bgobj setPosition:ccp([Common SCREEN].width+150,bgobj.position.y)];
		ct = 0;
		[bgobj anim_hatch_closed];
		[AudioManager playsfx:SFX_BOSS_ENTER];
		
	} else if (pick_ct%pick_mod == 1) {
		current_mode = SubMode_ScopeQuickJump;
		body_rel_pos = ccp(1000,0);
		[self run_body_anim:_anim_body_normal];
		
	} else if (pick_ct%pick_mod == 2) {
		current_mode = SubMode_BGFireMissiles;
		[bgobj setPosition:ccp([Common SCREEN].width+150,bgobj.position.y)];
		ct = 0;
		[bgobj anim_hatch_closed];
		[AudioManager playsfx:SFX_BOSS_ENTER];
		
	} else if (pick_ct%pick_mod == 3) {
		current_mode = SubMode_FrontJumpAttack;
		body_rel_pos = ccp(1000,0);
		sub_submode = 0;
		ct = 0;
		[self run_body_anim:_anim_body_normal];
		[AudioManager playsfx:SFX_BOSS_ENTER];
		
	}
}

-(void)set_bounds_and_ground:(GameEngineLayer*)g {
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

-(HitRect)get_hit_rect {
	return [Common hitrect_cons_x1:body.position.x-100 y1:body.position.y-50 wid:200 hei:120];
}

-(void)check_should_render:(GameEngineLayer *)g {
	do_render = YES;
}

-(void)reset {
	current_mode = SubMode_ToRemove;
	_current_anim = NULL;
}

-(void)cons_anims {
	_anim_body_normal = [Common cons_anim:@[@"body_normal"] speed:24 tex_key:TEX_ENEMY_SUBBOSS];
	_anim_body_broken = [Common cons_anim:@[@"broken"] speed:25 tex_key:TEX_ENEMY_SUBBOSS];
	_anim_body_bite = [Common cons_nonrepeating_anim:@[@"body_bite0",
										  @"body_bite1",
										  @"body_bite2"]
								  speed:0.1
								tex_key:TEX_ENEMY_SUBBOSS];
	
	_anim_hatch_closed = [Common cons_anim:@[@"hatch_0"] speed:26 tex_key:TEX_ENEMY_SUBBOSS];
	_anim_hatch_closed_to_cannon = [Common cons_anim:@[@"hatch_0",
													   @"hatch_1",
													   @"hatch_cannon_0",
													   @"hatch_cannon_1",
													   @"hatch_cannon_2"]
											   speed:0.1
											 tex_key:TEX_ENEMY_SUBBOSS];
	_anim_hatch_closed_to_cannon = [Common cons_anim:@[@"hatch_cannon_2",
													   @"hatch_cannon_1",
													   @"hatch_cannon_0",
													   @"hatch_1",
													   @"hatch_0"]
											   speed:0.1
											 tex_key:TEX_ENEMY_SUBBOSS];
	
}

-(BOOL)is_broken {
	return hp <= 2;
}

-(void)run_body_anim:(CCAction*)anim {
	if (anim == _anim_body_normal && [self is_broken]) anim = _anim_body_broken;
	if (_current_anim == NULL) {
		_current_anim = anim;
		[body runAction:anim];
		
	} else if (anim != _current_anim) {
		[body stopAllActions];
		_current_anim = anim;
		[body runAction:anim];
		
	}
}

@end
