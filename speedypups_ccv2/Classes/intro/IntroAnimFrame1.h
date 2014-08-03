#import "IntroAnim.h"

@interface IntroAnimFrame1 : IntroAnimFrame {
	int ct;
	CCSprite *bg;
	CCSprite *leftbush, *rightbush;
	CCSprite *chars;
}

+(IntroAnimFrame1*)cons;

@end
