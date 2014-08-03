#import "cocos2d.h"
#import "FreeRunStartAtManager.h"

@class GameEngineLayer;
@class FreeRunStartAtUnlockUIAnimation;
@class CSF_CCSprite;
@class MenuCurtains;

typedef enum {
	FreePupsAnimMode_RUNIN,
	FreePupsAnimMode_ROLL,
	FreePupsAnimMode_BREAKANDFALL,
	FreePupsAnimMode_MENU
	//FreePupsAnimMode_FADEOUT
} FreePupsAnimMode;

@class CCSprite_WithVel;
@class FreePupsUIAnimation;

@interface FreePupsAnim : CCLayer {
	CCAction *run_anim, *roll_anim;
	CCSprite *cage_base;
	CCSprite_WithVel *dog, *cage_bottom, *cage_top;
	FreePupsAnimMode mode;
	
	BOOL cage_on_ground;
	NSMutableArray *pups;
	
	FreePupsUIAnimation *uianim;
	
	
	FreeRunStartAtUnlockUIAnimation *worldunlock_anim;
	CCSprite *menu_ui;
	
	MenuCurtains *curtains;
	
	
	GameEngineLayer __unsafe_unretained *g;
	
	float shake_ct;
	float shake_intensity;
}

+(CCScene*)scene_with:(WorldNum)worldnum g:(GameEngineLayer*)g;

@end
