#import "VolleyRobotBossComponents.h"
#import "Common.h" 
#import "Resource.h"
#import "FileCache.h"

@implementation VolleyRobotBossBody
@synthesize body,frontarm,backarm;
#define RobotBossBodyMode_STAND 0
#define RobotBossBodyMode_SWING 1

-(void)cons_anims {
	_robot_body = [Common cons_anim:@[@"body_0",@"body_1"] speed:0.1 tex_key:TEX_ENEMY_ROBOTBOSS];
	_robot_body_hurt = [Common cons_anim:@[@"body_hurt"] speed:10 tex_key:TEX_ENEMY_ROBOTBOSS];
	_robot_arm_front_loaded = [Common cons_anim:@[@"arm_front_fist"] speed:10 tex_key:TEX_ENEMY_ROBOTBOSS];
	_robot_arm_front_unloaded = [Common cons_anim:@[@"arm_front_empty"] speed:10 tex_key:TEX_ENEMY_ROBOTBOSS];
	_robot_arm_back = [Common cons_anim:@[@"back_arm"] speed:10 tex_key:TEX_ENEMY_ROBOTBOSS];
}

+(VolleyRobotBossBody*)cons {
	return [VolleyRobotBossBody node];
}

-(id)init {
	self = [super init];
	[self cons_anims];
	
	mode = RobotBossBodyMode_STAND;
	
	self.backarm = [CCSprite node];
	self.body = [CCSprite node];
	self.frontarm = [CCSprite node];
	
	[self addChild:self.backarm];
	[self addChild:self.body];
	[self addChild:self.frontarm];
	
	CGRect body_rect = [FileCache get_cgrect_from_plist:TEX_ENEMY_ROBOTBOSS idname:@"body_0"];
	
	[self.backarm setAnchorPoint:ccp(0.45,0.8)];
	[self.backarm setPosition:ccp(body_rect.size.width*0.15,body_rect.size.height*0.55)];
	
	[self.body setAnchorPoint:ccp(0.5,0.1)];
	
	[self.frontarm setAnchorPoint:ccp(0.35,0.8)];
	[self.frontarm setPosition:ccp(-body_rect.size.width*0.35,body_rect.size.height*0.55)];
	
	[self.backarm runAction:_robot_arm_back];
	[self.body runAction:_robot_body];
	[self.frontarm runAction:_robot_arm_front_loaded];
	
	passive_arm_rotation_theta = 0;
	
	swing_has_thrown_bomb = NO;
	
	[self setScaleX:-1];
	
	return self;
}

-(void)update {
	if (mode == RobotBossBodyMode_STAND) {
		passive_arm_rotation_theta+=0.09*[Common get_dt_Scale];
		[self.backarm setRotation:cosf(passive_arm_rotation_theta)*15];
		[self.frontarm setRotation:-cosf(passive_arm_rotation_theta)*15];
	
	} else if (mode == RobotBossBodyMode_SWING) {
		swing_theta += [Common get_dt_Scale] * 3.14 * 0.035;
		[self.frontarm setRotation:-110*sinf(swing_theta)];
		[self.backarm setRotation:-110*sinf(swing_theta)-5];
		
		if (swing_theta > 3.14) {
			mode = RobotBossBodyMode_STAND;
		}
	}
}

-(void)do_swing {
	mode = RobotBossBodyMode_SWING;
	swing_theta = 0;
	swing_has_thrown_bomb = NO;
}

-(void)set_swing_has_thrown_bomb {
	swing_has_thrown_bomb = YES;
}

-(BOOL)swing_has_thrown_bomb {
	return swing_has_thrown_bomb;
}

-(BOOL)swing_launched {
	return swing_theta > 3.14/2;
}

-(BOOL)swing_in_progress {
	return mode == RobotBossBodyMode_SWING;
}

@end

@implementation VolleyCatBossBody
@synthesize base,cape,top;
+(VolleyCatBossBody*)cons {
	return [VolleyCatBossBody node];
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
	_cat_throw = [Common cons_nonrepeating_anim:@[
												  @"throw_0",
												  @"throw_1",
												  @"throw_2",
												  @"throw_3",
												  @"throw_4",
												  @"throw_5",
												  @"throw_6"] speed:0.1 tex_key:TEX_ENEMY_ROBOTBOSS];
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
	throw_in_progress = NO;
	throw_finished = NO;
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
	throw_in_progress = NO;
	throw_finished = NO;
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
	throw_in_progress = NO;
	throw_finished = NO;
	if (top_anim == _cat_damage) return;
	[self.top stopAllActions];
	[self.top runAction:_cat_damage];
	top_anim = _cat_damage;
	[base stopAllActions];
	[cape stopAllActions];
	[cape setVisible:NO];
}

-(void)hurt_anim {
	throw_in_progress = NO;
	throw_finished = NO;
	if (top_anim == _cat_hurt) return;
	[self.top stopAllActions];
	[self.top runAction:_cat_hurt];
	top_anim = _cat_hurt;
	
	[cape setVisible:NO];
	[base stopAllActions];
	[cape stopAllActions];
	[self.base runAction:_cat_tail_base];
}

-(void)throw_anim_force:(BOOL)force {
	if (!force && top_anim == _cat_throw) return;
	[self.top stopAllActions];
	[self.top runAction:[CCSequence actions:(CCFiniteTimeAction*)_cat_throw, [CCCallFunc actionWithTarget:self selector:@selector(throw_end)], nil]];
	top_anim = _cat_throw;
	throw_in_progress = YES;
	throw_finished = NO;
	
	[base stopAllActions];
	[cape stopAllActions];
	[self.cape runAction:_cat_cape];
	[self.base runAction:_cat_tail_base];
	[cape setVisible:YES];
}

-(void)throw_end {
	throw_in_progress = YES;
	throw_finished = YES;
}

-(BOOL)get_throw_in_progress { return throw_in_progress; }
-(BOOL)get_throw_finished { return throw_finished; }


@end
