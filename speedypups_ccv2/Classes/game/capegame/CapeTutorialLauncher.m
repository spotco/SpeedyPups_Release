#import "CapeTutorialLauncher.h"
#import "CapeGamePlayer.h"

@implementation CapeTutorialLauncher

+(CapeTutorialLauncher*)cons_x:(float)x {
	return [[CapeTutorialLauncher node] cons_x:x];
}

-(id)cons_x:(float)x {
	[self setPosition:ccp(x,0)];
	active = YES;
	return self;
}

-(void)update:(CapeGameEngineLayer *)g {
	if (!active)return;
	if (g.player.position.x > [self position].x) {
		active = NO;
		[g do_tutorial_anim];
	}
}

@end
