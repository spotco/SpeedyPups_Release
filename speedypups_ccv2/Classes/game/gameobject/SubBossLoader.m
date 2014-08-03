#import "SubBossLoader.h"
#import "AudioManager.h"
#import "GameEngineLayer.h"
#import "SubBoss.h"

@implementation SubBossLoader
+(SubBossLoader*)cons_pt:(CGPoint)pt {
	return [[SubBossLoader node] cons_at:pt];
}

-(id)cons_at:(CGPoint)pos {
    [self setPosition:pos];
    self.active = NO;
    return self;
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    if (!self.active && player.position.x > [self position].x) {
        active = YES;
        [GEventDispatcher push_event:[[GEvent cons_type:GEventType_BOSS2_ACTIVATE] add_pt:player.position]];
		[g add_gameobject:[SubBoss cons_with:g]];
		if ([AudioManager get_cur_group] != BGM_GROUP_BOSS1) {
			[AudioManager playbgm_imm:BGM_GROUP_BOSS1];
		}
    }
}

-(void)reset {
    [super reset];
    self.active = NO;
}

@end
