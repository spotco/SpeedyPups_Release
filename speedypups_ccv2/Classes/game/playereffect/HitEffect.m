#import "HitEffect.h"
#import "FlashEffect.h"
#import "GameEngineLayer.h"

@implementation HitEffect
@synthesize tmode;
@synthesize nograv;

+(HitEffect*)cons_from:(PlayerEffectParams*)base time:(int)time {
    HitEffect *e = [[HitEffect alloc] init];
    [PlayerEffectParams copy_params_from:base to:e];
    e.time_left = time;
    e.noclip = 1;
    e.tmode = player_anim_mode_HIT;
    return e;
}

+(HitEffect*)cons_from:(PlayerEffectParams*)base time:(int)time nograv:(BOOL)nograv {
    HitEffect* h = [HitEffect cons_from:base time:time];
    h.nograv = nograv;
    return h;
}

-(player_anim_mode)get_anim {
    return self.tmode;
}

-(void)update:(Player*)p g:(GameEngineLayer *)g{
    p.dead = YES;
    p.vx = 0;
    if (nograv || p.current_island != NULL) {
        p.vy = 0;
    }
	self.player = p;
}

-(void)effect_end {
    [GEventDispatcher push_unique_event:[GEvent cons_type:GEventType_PLAYER_DIE]];
}

-(void)effect_begin:(Player *)p {
    p.dead = YES;
}

-(NSString*)info {
    return [NSString stringWithFormat:@"HitEffect(timeleft:%i)",time_left];
}
@end

@implementation FlashHitEffect

+(FlashHitEffect*)cons_from:(PlayerEffectParams *)base time:(int)time {
    FlashHitEffect *e = [[FlashHitEffect alloc] init];
    [PlayerEffectParams copy_params_from:base to:e];
    e.time_left = time;
    e.noclip = 1;
    e.tmode = player_anim_mode_FLASH;
    return e;
}

-(void)update:(Player*)p g:(GameEngineLayer *)g{
    p.dead = YES;
    p.vx = 0;
    p.vy = 0;
}

@end
