#import "Common.h"
#import "Resource.h"
#import "FileCache.h"
#import "NRobotBossComponents.h"
#import "AudioManager.h"
#import "Particle.h"
#import "GameEngineLayer.h"

@implementation NRobotBossBody
@synthesize body,frontarm,backarm;

+(NRobotBossBody*)cons {
	return [NRobotBossBody node];
}

-(void)cons_anims {
	_robot_body = [Common cons_anim:@[@"body_0",@"body_1"] speed:0.1 tex_key:TEX_ENEMY_ROBOTBOSS];
	_robot_body_hurt = [Common cons_anim:@[@"body_hurt"] speed:10 tex_key:TEX_ENEMY_ROBOTBOSS];
	_robot_body_headless = [Common cons_anim:@[@"body_headless"] speed:10 tex_key:TEX_ENEMY_ROBOTBOSS];
	
	_arm_none = [Common cons_anim:@[@"arm_0"] speed:10 tex_key:TEX_ENEMY_ROBOTBOSS];
	_arm_load = [Common cons_nonrepeating_anim:@[@"arm_0",@"arm_1",@"arm_2",@"arm_3"] speed:0.05 tex_key:TEX_ENEMY_ROBOTBOSS];
	_arm_ready = [Common cons_anim:@[@"arm_3"] speed:10 tex_key:TEX_ENEMY_ROBOTBOSS];
	_arm_fire = [Common cons_nonrepeating_anim:@[@"arm_3",@"arm_4",@"arm_5",@"arm_3"] speed:0.05 tex_key:TEX_ENEMY_ROBOTBOSS];
	_arm_unload = [Common cons_nonrepeating_anim:@[@"arm_3",@"arm_2",@"arm_1",@"arm_0"] speed:0.05 tex_key:TEX_ENEMY_ROBOTBOSS];
	
	_backarm = [Common cons_anim:@[@"backarm"] speed:10 tex_key:TEX_ENEMY_ROBOTBOSS];
}

-(id)init {
	self = [super init];
	[self cons_anims];
	
	self.backarm = [CCSprite node];
	self.body = [CCSprite node];
	self.frontarm = [CCSprite node];
	
	frontarm_anchor = [CCSprite node];
	body_anchor = [CCSprite node];
	hopanchor = [CCSprite node];
	
	[body_anchor addChild:self.backarm];
	[body_anchor addChild:self.body];
	[frontarm_anchor addChild:self.frontarm];
	
	[hopanchor addChild:body_anchor];
	[hopanchor addChild:frontarm_anchor];
	
	[self addChild:hopanchor];
	
	CGRect body_rect = [FileCache get_cgrect_from_plist:TEX_ENEMY_ROBOTBOSS idname:@"body_0"];
	
	[self.backarm setAnchorPoint:ccp(0.45,0.8)];
	[self.backarm setPosition:ccp(body_rect.size.width*0.15,body_rect.size.height*0.55)];
	
	[self.body setAnchorPoint:ccp(0.5,0.1)];
	
	[self.frontarm setAnchorPoint:ccp(0.15,0.835)];
	[self.frontarm setPosition:ccp(-body_rect.size.width*0.35,body_rect.size.height*0.55)];
	
	[self.backarm runAction:_backarm];
	[self.body runAction:_robot_body];
	current_body_anim = _robot_body;
	hurt_anim_ct = 0;
	[self.frontarm runAction:_arm_none];
	current_front_arm_anim = _arm_none;
	
	passive_arm_rotation_theta = 0;
	
	[self setScaleX:-1];
	
	firing = NO;
	passive_arm_rotation_theta_speed = 0.09;
	
	cur_swing_state = NRBCSwingState_NONE;
	
	stop_rotate = NO;
	return self;
}

-(void)play_anim:(CCAction*)anim {
	if (current_body_anim != anim) {
		[body stopAllActions];
		[body runAction:anim];
		current_body_anim = anim;
	}
}

-(void)hurt_anim {
	hurt_anim_ct = 50;
}

-(void)headless_anim {
	headless_anim_ct = 200;
}

-(void)reset_anim {
	hurt_anim_ct = 0;
	headless_anim_ct = 0;
}

-(void)update:(CGPoint)body_rel_pos g:(GameEngineLayer *)g{
	
	if (headless_anim_ct > 0) {
		[self play_anim:_robot_body_headless];
		headless_anim_ct--;
		
	} else if (hurt_anim_ct > 0) {
		[self play_anim:_robot_body_hurt];
		hurt_anim_ct--;
		
	} else {
		[self play_anim:_robot_body];
		
	}
		
	[self swing_update];
	if (cur_swing_state != NRBCSwingState_NONE) return;
	
	if (current_body_anim == _robot_body_hurt) {
		frontarm_anchor.position = ccp(float_random(-2, 2),float_random(-2, 2));
		body_anchor.position = frontarm_anchor.position;
		return;
	}

	frontarm_anchor.position = ccp(frontarm_anchor.position.x*0.5,frontarm_anchor.position.y*0.5);
	body_anchor.position = ccp(body_anchor.position.x*0.8,body_anchor.position.y*0.8);
	
	if (hopanchor.position.y > 0 && hopanchor.position.y + hop_vy*[Common get_dt_Scale] <= 0) {
		[g shake_for:15 intensity:4];
	}
	
	hopanchor.position = ccp(0,MAX(hopanchor.position.y+hop_vy*[Common get_dt_Scale], 0));
	hop_vy-=1*[Common get_dt_Scale];
	
	if (!firing) {
		if (stop_rotate) return;
		passive_arm_rotation_theta+=passive_arm_rotation_theta_speed*[Common get_dt_Scale];
		[self.backarm setRotation:cosf(passive_arm_rotation_theta)*15];
		[self.frontarm setRotation:-cosf(passive_arm_rotation_theta)*15];
	} else {
		[self.backarm setRotation:0];
		[self.frontarm setRotation:0];
	}
}

-(void)hop {
	hop_vy = 8;
	[AudioManager playsfx:SFX_ROCKBREAK];
}

-(void)set_passive_rotation_theta_speed:(float)t {
	passive_arm_rotation_theta_speed = t;
}

-(void)do_fire {
	if (firing) return;
	[frontarm stopAllActions];
	[frontarm runAction:[CCSequence actions:(CCFiniteTimeAction*)_arm_load,[CCCallFunc actionWithTarget:self selector:@selector(arm_loaded)], nil]];
	firing = YES;
}

-(void)arm_loaded {
	[frontarm stopAllActions];
	[frontarm runAction:_arm_ready];
}

-(void)arm_fire {
	[frontarm stopAllActions];
	[frontarm runAction:_arm_fire];
	frontarm_anchor.position = ccp(-15,0);
	body_anchor.position = ccp(-7,0);
}

-(void)stop_fire {
	if (!firing) return;
	[frontarm stopAllActions];
	[frontarm runAction:[CCSequence actions:(CCFiniteTimeAction*)_arm_unload,[CCCallFunc actionWithTarget:self selector:@selector(arm_unloaded)], nil]];
	firing = NO;
}

-(void)arm_unloaded {
	[frontarm stopAllActions];
	[frontarm runAction:_arm_none];
}

-(void)swing_update {
	if (cur_swing_state == NRBCSwingState_SWINGING) {
		swing_theta += [Common get_dt_Scale] * 3.14 * 0.035;
		[self.backarm setRotation:-110*sinf(swing_theta)];
		if (swing_theta >= 3.14/2) cur_swing_state = NRBCSwingState_PEAK;
		
	} else if (cur_swing_state == NRBCSwingState_PEAK) {
		//wait for swing_peak_throw
		
	} else if (cur_swing_state == NRBCSwingState_RETURN) {
		swing_theta += [Common get_dt_Scale] * 3.14 * 0.035;
		[self.backarm setRotation:-110*sinf(swing_theta)];
		if (swing_theta >= 3.14) cur_swing_state = NRBCSwingState_NONE;
		
	}
}
-(NRBCSwingState)get_swing_state {
	return cur_swing_state;
}
-(void)swing_peak_throw {
	if (cur_swing_state == NRBCSwingState_PEAK) {
		cur_swing_state = NRBCSwingState_RETURN;
	}
}
-(void)do_swing {
	if (cur_swing_state == NRBCSwingState_NONE) {
		cur_swing_state = NRBCSwingState_SWINGING;
		swing_theta = 0;
	}
}
-(void)reset_swing_state {
	cur_swing_state = NRBCSwingState_NONE;
}


-(BOOL)headless {
	return headless_anim_ct > 0;
}
-(void)headless_flyoff {
	headless_anim_ct = 1000;
	
}
-(void)end_headless {
	headless_anim_ct = 0;
}
-(void)stop_rotate {
	stop_rotate = YES;
}
@end

@implementation NRobotBossHeadFlyoffParticle

+(NRobotBossHeadFlyoffParticle*)cons_pos:(CGPoint)pos vel:(CGPoint)vel player:(CGPoint)player {
	return [[NRobotBossHeadFlyoffParticle spriteWithTexture:[Resource get_tex:TEX_ENEMY_ROBOTBOSS]
													   rect:[FileCache get_cgrect_from_plist:TEX_ENEMY_ROBOTBOSS idname:@"head"]] cons_pos:pos vel:vel player:player];
}

-(id)cons_pos:(CGPoint)pos vel:(CGPoint)vel player:(CGPoint)player {
	[self setPosition:pos];
	rel_pos = ccp(pos.x-player.x,pos.y-player.y);
	self.vx = vel.x;
	self.vy = vel.y;
	off_screen = false;
	return self;
}

-(void)update:(GameEngineLayer *)g {
	
	rel_pos.x += self.vx * [Common get_dt_Scale];
	rel_pos.y += self.vy * [Common get_dt_Scale];
	
	[self setPosition:CGPointAdd(g.player.position, rel_pos)];
	[self setRotation:self.rotation+20*[Common get_dt_Scale]];
	if (![Common hitrect_touch:[g get_viewbox] b:[Common hitrect_cons_x1:[self position].x y1:[self position].y wid:5 hei:5]]) {
		off_screen = true;
	}
}

-(BOOL)should_remove {
	return off_screen;
}

-(int)get_render_ord {
	return [GameRenderImplementation GET_RENDER_FG_ISLAND_ORD];
}

@end


@implementation NCatBossBody
@synthesize base,cape,top;
+(NCatBossBody*)cons {
	return [NCatBossBody node];
}

-(void)cons_anims {
	_cat_tail_base = [Common cons_anim:@[@"cat_tail_0",@"cat_tail_1",@"cat_tail_2",@"cat_tail_3"] speed:0.1 tex_key:TEX_ENEMY_ROBOTBOSS];
	_cat_cape = [Common cons_anim:@[@"cat_cape_0",@"cat_cape_1",@"cat_cape_2",@"cat_cape_3"] speed:0.1 tex_key:TEX_ENEMY_ROBOTBOSS];
	_cat_stand = [Common cons_anim:@[@"cat_laugh_0"] speed:10 tex_key:TEX_ENEMY_ROBOTBOSS];
	_cat_laugh = [Common cons_anim:@[
									 @"cat_laugh_0",
									 @"cat_laugh_1",
									 @"cat_laugh_2",
									 @"cat_laugh_3",
									 @"cat_laugh_2",
									 @"cat_laugh_3",
									 @"cat_laugh_2",
									 @"cat_laugh_3",
									 @"cat_laugh_2",
									 @"cat_laugh_3",
									 @"cat_laugh_2",
									 @"cat_laugh_3",
									 @"cat_laugh_2",
									 @"cat_laugh_3",
									 @"cat_laugh_2",
									 @"cat_laugh_3",
									 @"cat_laugh_0"] speed:0.1 tex_key:TEX_ENEMY_ROBOTBOSS];
	_cat_hurt = [Common cons_anim:@[@"cat_hurt_0",@"cat_hurt_1",@"cat_hurt_2"] speed:0.1 tex_key:TEX_ENEMY_ROBOTBOSS];
	_cat_damage = [Common cons_anim:@[@"cat_damage"] speed:10 tex_key:TEX_ENEMY_ROBOTBOSS];
}

-(id)init {
	self = [super init];
	[self cons_anims];
	
	vib_base = [CCSprite node];
	[self addChild:vib_base];
	
	self.base = [CCSprite node];
	self.cape = [CCSprite node];
	self.top = [CCSprite node];
	
	[vib_base addChild:self.base];
	[vib_base addChild:self.cape];
	[vib_base addChild:self.top];
	
	[self.base runAction:_cat_tail_base];
	[self.cape runAction:_cat_cape];
	[self.top runAction:_cat_stand];
	
	top_anim = _cat_stand;
	
	[self setScaleX:-1];
	
	return self;
}

-(void)update {
	vib_theta+=0.075;
	[vib_base setPosition:ccp(0,10*cosf(vib_theta))];
	if (brownian_ct > 0) {
		brownian_ct--;
		vib_base.position = CGPointAdd(vib_base.position, ccp(float_random(-4, 4),float_random(-4, 4)));
	}
}

static int brownian_ct = 0;
-(void)brownian {
	brownian_ct = 2;
}

-(void)laugh_anim {
	if (top_anim == _cat_laugh) return;
	[self.top stopAllActions];
	[self.top runAction:_cat_laugh];
	top_anim = _cat_laugh;
	
	[base stopAllActions];
	[cape stopAllActions];
	[self.cape runAction:_cat_cape];
	[self.base runAction:_cat_tail_base];
	[cape setVisible:YES];
}

-(void)stand_anim {
	if (top_anim == _cat_stand) return;
	[self.top stopAllActions];
	[self.top runAction:_cat_stand];
	top_anim = _cat_stand;
	
	[base stopAllActions];
	[cape stopAllActions];
	[self.cape runAction:_cat_cape];
	[self.base runAction:_cat_tail_base];
	[cape setVisible:YES];
}

-(void)damage_anim {
	if (top_anim == _cat_damage) return;
	[self.top stopAllActions];
	[self.top runAction:_cat_damage];
	top_anim = _cat_damage;
	[base stopAllActions];
	[cape stopAllActions];
	[cape setVisible:NO];
}

-(void)hurt_anim {
	if (top_anim == _cat_hurt) return;
	[self.top stopAllActions];
	[self.top runAction:_cat_hurt];
	top_anim = _cat_hurt;
	
	[cape setVisible:NO];
	[base stopAllActions];
	[cape stopAllActions];
	[self.base runAction:_cat_tail_base];
}


@end