#import "TutorialEnd.h"
#import "GEventDispatcher.h"

@implementation TutorialEnd
+(TutorialEnd*)cons_pos:(CGPoint)pos {
    return [[TutorialEnd node] cons:pos];
}

-(id)cons:(CGPoint)pos{
    [self setPosition:pos];
    active = NO;
    return self;
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    if (!self.active && player.position.x > [self position].x) {
        active = YES;
        [GEventDispatcher push_event:[GEvent cons_type:GEventType_END_TUTORIAL]];
    }
}

-(void)reset {
    [super reset];
    active = NO;
}
@end
