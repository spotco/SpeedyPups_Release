#import "DogCapeEffect.h"

@implementation DogCapeEffect

+(DogCapeEffect*)cons_from:(PlayerEffectParams*)base {
    DogCapeEffect *n = [[DogCapeEffect alloc] init];
    [PlayerEffectParams copy_params_from:base to:n];
    n.time_left = 300;
    n.cur_airjump_count = 1;
    return n;
}

-(void)update:(Player*)p g:(GameEngineLayer *)g{
	self.player = p;
    if(p.vx < 13) {
        p.vx = 13;
    }
}

-(player_anim_mode)get_anim {
    return player_anim_mode_CAPE;
}

-(void)decr_airjump_count {
}

-(NSString*)info {
    return [NSString stringWithFormat:@"DogCapeEffect(timeleft:%i)",time_left];
}


@end
