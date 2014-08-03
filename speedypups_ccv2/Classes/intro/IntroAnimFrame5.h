#import "cocos2d.h"
#import "IntroAnim.h"

@interface IntroAnimFrame5 : IntroAnimFrame {
	int ct;
	CCSprite *bg;
	CCSprite *chars, *excl;
}

+(IntroAnimFrame5*)cons;

@end
