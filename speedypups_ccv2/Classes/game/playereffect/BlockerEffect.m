#import "BlockerEffect.h"

@implementation BlockerEffect

+(BlockerEffect*)cons_from:(PlayerEffectParams*)base {
    BlockerEffect *n = [[BlockerEffect alloc] init];
    [PlayerEffectParams copy_params_from:base to:n];
    n.time_left = -1;
    n.cur_airjump_count = 0;
    n.cur_dash_count = 0;
    return n;
}

-(void)update:(Player*)p g:(GameEngineLayer *)g{
	self.player = p;
    if (p.current_island != NULL) {
        time_left = 0;
    } else {
        p.vx = 0;
    }
}

-(void)decrement_timer {
    return; 
}

-(NSString*)info {
    return [NSString stringWithFormat:@"BlockerEffect(timeleft:%i)",time_left];
}

@end
