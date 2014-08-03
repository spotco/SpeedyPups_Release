#import "CCSprite.h"
#import "Common.h"

@interface VolleyRobotBossBody : CCSprite {
	float passive_arm_rotation_theta;
	float swing_theta;
	int mode;
	
	BOOL swing_has_thrown_bomb;
	
	CCAction *_robot_body;
	CCAction *_robot_body_hurt;
	 CCAction *_robot_arm_front_loaded;
	 CCAction *_robot_arm_front_unloaded;
	 CCAction *_robot_arm_back;
}
+(VolleyRobotBossBody*)cons;
@property(readwrite,strong) CCSprite *body;
@property(readwrite,strong) CCSprite *frontarm;
@property(readwrite,strong) CCSprite *backarm;
-(void)update;
-(void)do_swing;
-(BOOL)swing_launched;
-(BOOL)swing_in_progress;

-(void)set_swing_has_thrown_bomb;
-(BOOL)swing_has_thrown_bomb;

@end

@interface VolleyCatBossBody : CSF_CCSprite {
	CCSprite *vib_base;
	float vib_theta;
	
	CCAction *top_anim;
	BOOL throw_in_progress, throw_finished;
	
	CCAction *_cat_tail_base;
	CCAction *_cat_cape;
	CCAction *_cat_stand;
	CCAction *_cat_laugh;
	CCAction *_cat_hurt;
	CCAction *_cat_damage;
	CCAction *_cat_throw;
}
+(VolleyCatBossBody*)cons;
@property(readwrite,strong) CCSprite *base;
@property(readwrite,strong) CCSprite *cape;
@property(readwrite,strong) CCSprite *top;
-(void)update;

-(void)laugh_anim;
-(void)stand_anim;
-(void)damage_anim;
-(void)hurt_anim;
-(void)brownian;
-(void)throw_anim_force:(BOOL)force;
-(BOOL)get_throw_in_progress;
-(BOOL)get_throw_finished;
@end
