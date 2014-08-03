#import "cocos2d.h"
#import "IntroAnim.h"
@class BackgroundObject;
@class DogSprite;
@class CSF_CCSprite;

@interface IntroAnimFrame6 : IntroAnimFrame {
	int phase;
	float ct;
	NSMutableDictionary *flags;
	CGPoint scroll_pos;
	BackgroundObject *sky,*clouds,*backhills,*fronthills;
	CCSprite *ground;
	DogSprite *dog1, *dog2, *dog3;
	CSF_CCSprite *copter;
	CGPoint dog1_tar_pos, dog2_tar_pos, dog3_tar_pos, copter_tar_pos;
	
	CSF_CCSprite *logo_flyin,*logo_flyin_base, *logo_flyin_speedy, *logo_flyin_pups, *logo_flyin_circle;

	CCAction *dog3_run, *dog2_run, *dog1_run;
	CCAction *dog3_jump, *dog2_jump, *dog1_jump;
	CCAnimate *logojump, *logobounce, *logoempty;
	
	CSF_CCSprite *copter_shadow;
	
	BOOL ok_to_exit;
}

+(IntroAnimFrame6*)cons;

@end
