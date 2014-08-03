#import "EnemyAlert.h"

@implementation EnemyAlert

+(EnemyAlert*)cons_p1:(CGPoint)p1 size:(CGPoint)size {
    return [[EnemyAlert node] cons_p1:p1 size:size];
}

-(id)cons_p1:(CGPoint)p1 size:(CGPoint)tsize {
    [self setPosition:p1];
    size = tsize;
    return self;
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    if (!activated && [Common hitrect_touch:[player get_hit_rect] b:[self get_hit_rect]]) {
        activated = YES;
        [GEventDispatcher push_event:[GEvent cons_type:GEventType_SHOW_ENEMYAPPROACH_WARNING]];
    }
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:[self position].x y1:[self position].y wid:size.x hei:size.y];
}

-(void)reset {
    [super reset];
    activated = NO;
}

-(void)draw {
    return;
}

@end
