#import "CCSprite.h"
#import "Particle.h"

typedef enum  NRBCSwingState {
	NRBCSwingState_NONE,
	NRBCSwingState_SWINGING,
	NRBCSwingState_PEAK,
	NRBCSwingState_RETURN
} NRBCSwingState;

@interface NRobotBossHeadFlyoffParticle : Particle {
	BOOL off_screen;
	CGPoint rel_pos;
}
+(NRobotBossHeadFlyoffParticle*)cons_pos:(CGPoint)pos vel:(CGPoint)vel player:(CGPoint)player;
@end

@interface NRobotBossBody : CSF_CCSprite {
	
	CCAction *_robot_body;
	CCAction *_robot_body_hurt;
	CCAction *_robot_body_headless;
	
	CCAction *_arm_none,*_arm_load,*_arm_fire,*_arm_ready,*_arm_unload;
	CCAction *_backarm;
	
	float passive_arm_rotation_theta;
	float passive_arm_rotation_theta_speed;
	float swing_theta;
	BOOL firing;
	
	CCAction *current_front_arm_anim;
		
	CCAction *current_body_anim;
	float hurt_anim_ct;
	
	float headless_anim_ct;
	
	CCSprite *frontarm_anchor, *body_anchor;
	CCSprite *hopanchor;
	float hop_vy;

	NRBCSwingState cur_swing_state;
	
	BOOL stop_rotate;
}
+(NRobotBossBody*)cons;
@property(readwrite,strong) CCSprite *body;
@property(readwrite,strong) CCSprite *frontarm;
@property(readwrite,strong) CCSprite *backarm;
-(void)update:(CGPoint)body_rel_pos g:(GameEngineLayer*)g;

-(void)set_passive_rotation_theta_speed:(float)t;
-(void)do_fire;
-(void)arm_fire;
-(void)stop_fire;

-(void)hop;

-(NRBCSwingState)get_swing_state;
-(void)swing_peak_throw;
-(void)do_swing;
-(void)reset_swing_state;

-(void)hurt_anim;
-(void)headless_anim;
-(void)reset_anim;

-(BOOL)headless;
-(void)headless_flyoff;
-(void)end_headless;

-(void)stop_rotate;

@end

@interface NCatBossBody : CSF_CCSprite {
	CCSprite *vib_base;
	float vib_theta;
	
	CCAction *top_anim;
	
	CCAction *_cat_tail_base;
	CCAction *_cat_cape;
	CCAction *_cat_stand;
	CCAction *_cat_laugh;
	CCAction *_cat_hurt;
	CCAction *_cat_damage;
}
+(NCatBossBody*)cons;
@property(readwrite,strong) CCSprite *base;
@property(readwrite,strong) CCSprite *cape;
@property(readwrite,strong) CCSprite *top;
-(void)update;

-(void)laugh_anim;
-(void)stand_anim;
-(void)damage_anim;
-(void)hurt_anim;
-(void)brownian;
@end