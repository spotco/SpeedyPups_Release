#import "CapeGameEnd.h"
#import "Resource.h"
#import "Common.h"
#import "CapeGamePlayer.h"
#import "GameEngineLayer.h"
#import "ScoreManager.h"

@implementation CapeGameEnd

+(CapeGameEnd*)cons_pt:(CGPoint)pt {
	return [[CapeGameEnd node] cons_pt:pt];
}

-(id)cons_pt:(CGPoint)pt {
	[self setPosition:ccp(pt.x,0)];
	[self setAnchorPoint:ccp(0.5,0)];
	[self setTexture:[Resource get_tex:TEX_CHECKERBOARD_TEXTURE]];
	ccTexParams par = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
	[[self texture] setTexParameters:&par];
	[self setTextureRect:CGRectMake(0, 0, 32, [Common SCREEN].height)];
	active = YES;
	return self;
}

-(void)update:(CapeGameEngineLayer *)g {
	if (!active) return;
	if (g.player.position.x > self.position.x) {
		active = NO;
		
		[AudioManager playsfx:SFX_CHEER];
		
		[g.get_main_game.score increment_multiplier:0.1];
		[g.get_main_game.score increment_score:100];
		
		[g duration_end];
	}
}

@end
