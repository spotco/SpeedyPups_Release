#import "CapeGameEngineLayer.h"
@class VolleyCatBossBody;

typedef enum CapeGameBossCatMode {
	CapeGameBossCatMode_INITIAL_IN,
	CapeGameBossCatMode_TAUNT,
	CapeGameBossCatMode_PATTERN_1,
	CapeGameBossCatMode_PATTERN_2,
	CapeGameBossCatMode_PATTERN_3,
	
	CapeGameBossCatMode_HURT_SPIN,
	CapeGameBossCatMode_END_OUT,
	CapeGameBossCatMode_TO_REMOVE
} CapeGameBossCatMode;

@interface CapeGameBossCat : CapeGameObject {
	VolleyCatBossBody *cat_body;
	float delay_ct;
	CapeGameBossCatMode mode;
	CapeGameBossCatMode next_mode;
	
	BOOL added_head;
	
	CGPoint cat_screen_pos;
	float pos_theta;
	
	int bomb_count;
}

+(CapeGameBossCat*)cons;

@end
