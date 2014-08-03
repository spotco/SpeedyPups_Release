#import "GameObject.h"

@class NRobotBossBody;
@class NCatBossBody;
@class VolleyRobotBossFistProjectile;

typedef enum NRobotBossMode {
	NRobotBossMode_TOREMOVE,
	
	NRobotBossMode_WAIT,
	
	NRobotBossMode_CAT_IN_RIGHT1,
	NRobotBossMode_CAT_TAUNT_RIGHT1,
	NRobotBossMode_CAT_ROBOT_IN_RIGHT1,
	
	NRobotBossMode_CHOOSING,

	NRobotBossMode_ATTACK_WALLROCKETS_IN,
	NRobotBossMode_ATTACK_WALLROCKETS,
	NRobotBossMode_ATTACK_CHARGE_LEFT,
	
	NRobotBossMode_ATTACK_STREAMHOMING_IN,
	NRobotBossMode_ATTACK_STREAMHOMING,
	NRobotBossMode_ATTACK_CHARGE_RIGHT,
	
	NRobotBossMode_ATTACK_THROWFIST_IN,
	NRobotBossMode_ATTACK_THROWFIST,
	
	NRobotBossMode_HEAD_CHASE_LEFT,
	NRobotBossMode_HEAD_CHASE_RIGHT,
	
	NRobotBossMode_EXPLODE_OUT,
	NRobotBossMode_CAPE_OUT
} NRobotBossMode;

@interface NRobotBoss : GameObject {
	GameEngineLayer __unsafe_unretained *g;
	
	NRobotBossBody *robot_body;
	NCatBossBody *cat_body;
	
	CGPoint cat_body_rel_pos;
	CGPoint robot_body_rel_pos;
	CGPoint cape_item_rel_pos;
	
	int attack_ct;
	
	float delay_ct;
	float tmp_ct;
	int pattern_ct;
	
	float groundlevel;
	
	NRobotBossMode cur_mode;
	
	NSMutableArray *fist_projectiles;
	int volley_ct;
	
	CSF_CCSprite *head_chaser;
	CGPoint head_chaser_rel_pos;
	
	int hp;
	CSF_CCSprite *cape_item_body;
	
	CGPoint last_robot_body_rel_pos;
	float spark_emit_rate;
}

+(NRobotBoss*)cons_with:(GameEngineLayer*)g;

@end
