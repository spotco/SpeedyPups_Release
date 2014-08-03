#import "GameObject.h"

@class SubBossBGObject;
@class FGWater;
@class NCatBossBody;

typedef enum SubMode {
	SubMode_Intro,
	SubMode_Flyoff,
	SubMode_ToRemove,
	SubMode_DeadExplode,
	SubMode_DeadAfter,
	SubMode_BGFireBombs,
	SubMode_BGFireMissiles,
	SubMode_FrontJumpAttack,
	SubMode_ScopeQuickJump
} SubMode;

typedef enum SubBossCatIntroMode {
	SubBossCatIntroMode_In,
	SubBossCatIntroMode_Taunt,
	SubBossCatIntroMode_Out,
	SubBossCatIntroMode_None
} SubBossCatIntroMode;

@interface SubBoss : GameObject {
	NCatBossBody *cat_body;
	CGPoint cat_body_rel_pos;
	float delay_ct;
	SubBossCatIntroMode cat_mode;
	BOOL cat_anim_done;
	
	CSF_CCSprite *body;
	CCSprite *hatch;
	
	CCAction* _current_anim;
	
	SubBossBGObject __unsafe_unretained *bgobj;
	
	FGWater *fgwater;
	SubMode current_mode;
	float groundlevel;
	
	int pick_ct;
	float ct;
	int sub_submode;
	float flt_ct;
	CGPoint body_rel_pos;
	CGPoint flyoff_dir;
	
	int hp;
	
	CCAction* _anim_body_normal;
	CCAction* _anim_body_broken;
	CCAction* _anim_body_bite;
	
	CCAction* _anim_hatch_closed_to_cannon;
	CCAction* _anim_hatch_cannon_to_closed;
	CCAction* _anim_hatch_closed;
}

+(SubBoss*)cons_with:(GameEngineLayer*)g;
@end
