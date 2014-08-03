#import "IntroAnim.h"

@interface IntroAnimFrame2 : IntroAnimFrame {
	float ct;
	CCSprite *bg;
	CCSprite *ground;
	CCSprite *robot1, *robot2, *robot3;
}

+(IntroAnimFrame2*)cons;

@end
