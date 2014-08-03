#import "FreeRunProgressDisplay.h"
#import "GEventDispatcher.h"
#import "GameEngineLayer.h"
#import "AutoLevel.h"

@implementation FreeRunProgressDisplay

+(FreeRunProgressDisplay*)cons_pt:(CGPoint)pt lab:(BOOL)lab {
	return [[FreeRunProgressDisplay node] cons:pt lab:lab];
}

-(id)cons:(CGPoint)pos lab:(BOOL)_lab {
    [self setPosition:pos];
	lab = _lab;
    active = NO;
    return self;
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    if (!self.active && player.position.x > [self position].x && player.position.x - [self position].x < 1000) {
        active = YES;
		FreeRunStartAt progress = [g.world_mode get_freerun_progress];
		if (lab) {
			if (progress == FreeRunStartAt_WORLD1) {
				progress = FreeRunStartAt_LAB1;
			} else if (progress == FreeRunStartAt_WORLD2) {
				progress = FreeRunStartAt_LAB2;
			} else if (progress == FreeRunStartAt_WORLD3) {
				progress = FreeRunStartAt_LAB3;
			}
		}
		[GEventDispatcher push_event:[[GEvent cons_type:GEventType_FREERUN_PROGRESS] add_i1:(int)progress i2:lab]];
    }
}

-(void)reset {
    active = NO;
}

@end
