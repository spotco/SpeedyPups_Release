#import "TutorialLauncher.h"
#import "TutorialProf.h"
#import "GameEngineLayer.h"

@implementation TutorialLauncher
@synthesize anim;

+(TutorialLauncher*)cons_pos:(CGPoint)pos anim:(NSString*)str {
    return [[TutorialLauncher node] cons:pos str:str];
}

-(id)cons:(CGPoint)pos str:(NSString*)str{
    [self setPosition:pos];
    active = NO;
    [self setAnim:str];
    return self;
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    if (!self.active && player.position.x > [self position].x && player.position.x - [self position].x < 1000) {
        active = YES;
        [g add_gameobject:[TutorialProf cons_msg:self.anim y:[self position].y]];
		[AudioManager playsfx:SFX_POWERUP];
		[GEventDispatcher push_event:
			[[GEvent cons_type:GEventType_TUTORIAL_MESSAGE]
				add_key:@"msg"
				value:[TutorialProf msg_for_tutorial:anim]
			]
		];
    }
}

-(void)reset {
    [super reset];
    active = NO;
}

@end
