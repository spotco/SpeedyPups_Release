#import "cocos2d.h"

@interface IntroAnimFrame : CCSprite
-(void)update;
-(BOOL)should_continue;
-(void)force_continue;
-(void)set_recursive_opacity:(GLubyte)opacity;
@end

@interface IntroAnim : CCLayer {
	NSMutableArray *frames;
	int cur_frame;
	
	BOOL transitioning_out;
	BOOL transitioning_in;
	BOOL force_end;
}
+(CCScene*)scene;
@end
