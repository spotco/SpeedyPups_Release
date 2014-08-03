#import "cocos2d.h"
#import "IntroAnim.h"
#import "Common.h"

@interface IntroAnimFrame3 : IntroAnimFrame {
	CCSprite *bg;
	
	CSF_CCSprite *dleft,*dright,*pups;
	CCSprite *curtains;
	int ct;
    
    NSMutableArray *debris;
}

+(IntroAnimFrame3*)cons;

@end
