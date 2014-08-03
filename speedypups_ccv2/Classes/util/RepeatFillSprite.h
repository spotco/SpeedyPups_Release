#import "cocos2d.h"

@interface RepeatFillSprite : CCSprite

+(RepeatFillSprite*)cons_tex:(CCTexture2D*)tex rect:(CGRect)rect rep:(int)rep;

@end
