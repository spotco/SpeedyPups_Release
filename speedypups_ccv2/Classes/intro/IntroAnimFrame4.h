#import "cocos2d.h"
#import "IntroAnim.h"
#import "Common.h"

@interface IntroAnimFrame4 : IntroAnimFrame {
	CCSprite *bg;
	
	CSF_CCSprite *dleft,*dright;
	CCSprite *curtains;
	CSF_CCSprite *spotlight, *copter, *exclamation;
	
	int ct;
    
}

+(IntroAnimFrame4*)cons;

@end