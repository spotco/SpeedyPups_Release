#import "CCSprite.h"
#import "GEventDispatcher.h"
#import "Common.h"

@interface CharSelAnim : CSF_CCSprite <GEventListener>

+(CharSelAnim*)cons_pos:(CGPoint)pt speed:(float)speed ;

@end
