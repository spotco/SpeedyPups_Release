#import "CCSprite.h"
#import "Common.h"
#import "GEventDispatcher.h"

@interface UIAnim : CSF_CCSprite <GEventListener>

@property(readwrite,strong) CallBack* anim_complete;

-(void)update;
-(void)anim_finished;

@end
