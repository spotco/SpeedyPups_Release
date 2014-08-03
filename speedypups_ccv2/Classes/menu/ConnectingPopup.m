#import "ConnectingPopup.h"
#import "CharSelAnim.h"

@implementation ConnectingPopup {
	CharSelAnim *player;
}


+(ConnectingPopup*)cons {
	return [[ConnectingPopup node] cons];
}
-(id)cons {
	[super cons];
		
	player = [CharSelAnim cons_pos:[Common pct_of_obj:self pctx:0.1 pcty:0.36] speed:0.05];
	[self addChild:player];
	
	return self;
}

-(void)update {
	CGPoint pos = player.position;
	pos.x += 4;
	if (pos.x > [Common pct_of_obj:self pctx:0.9 pcty:0].x) {
		pos.x = [Common pct_of_obj:self pctx:0.1 pcty:0].x;
	}
	[player setPosition:pos];
}

-(void)dealloc {
	[self removeAllChildrenWithCleanup:YES];
	[GEventDispatcher remove_listener:player];
}

@end
