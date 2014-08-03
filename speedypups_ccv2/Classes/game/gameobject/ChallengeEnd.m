#import "ChallengeEnd.h"
#import "Challenge.h" 
#import "GameEngineLayer.h" 
#import "UICommon.h" 
#import "FileCache.h"
#import "FireworksParticleA.h"
#import "AudioManager.h"

@implementation ChallengeEnd

+(ChallengeEnd*)cons_pt:(CGPoint)pt {
    ChallengeEnd* c = [ChallengeEnd node];
    [c setPosition:pt];
    return c;
}

-(id)make_anim{
	CCTexture2D *texture = [Resource get_tex:TEX_GOAL_SS];
	NSMutableArray *animFrames = [NSMutableArray array];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:TEX_GOAL_SS idname:@"goal0"]]];
	[animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:TEX_GOAL_SS idname:@"goal1"]]];
	[animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:TEX_GOAL_SS idname:@"goal2"]]];
	[animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:TEX_GOAL_SS idname:@"goal3"]]];
    return [Common make_anim_frames:animFrames speed:0.2];
}


-(id)init {
    self = [super init];
	[self setAnchorPoint:ccp(0.5,0)];
	[self runAction:[self make_anim]];
    procced = NO;
	[self setVisible:NO];
    return self;
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:[self position].x y1:[self position].y wid:100 hei:1000];
}

-(void)notify_challenge_mode:(ChallengeInfo *)c {
    active = YES;
	[self setVisible:YES];
    info = c;
}

-(void)update:(Player*)player g:(GameEngineLayer *)g {
    [super update:player g:g];
    if (active && !procced && [Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]) {
        procced = YES;
        [GEventDispatcher push_event:
         [[[GEvent cons_type:GEventType_CHALLENGE_COMPLETE]
          add_i1:[self did_complete_challenge:g] i2:0]
          add_key:@"challenge" value:info]
         ];
		[AudioManager playsfx:SFX_GOAL];
    }
	
	if (procced) {
		if (particlect%40==0) {
			CGPoint center = CGPointAdd([self position],ccp(float_random(-30, 30),0));
			for(int i = 0; i < 5; i++) {
				[g add_particle:[FireworksParticleA cons_x:center.x
														 y:center.y
														vx:float_random(-3,3)
														vy:float_random(9,14)
														ct:arc4random_uniform(25)+15]];
			}
		}
		
		if (particlect%3==0) {
			[g add_particle:[FireworksGroundFlower cons_pt:CGPointAdd([self position], ccp(200,0))]];
			[g add_particle:[FireworksGroundFlower cons_pt:CGPointAdd([self position], ccp(320,0))]];
		}
		particlect++;
	}
    
    return;
}

-(BOOL)did_complete_challenge:(GameEngineLayer*)g {
	NSLog(@"time:%d",[g get_time]);
    if (info.type == ChallengeType_COLLECT_BONES) {
        return [g get_num_bones] >= info.ct;
    
    } else if (info.type == ChallengeType_FIND_SECRET) {
        return [g get_num_secrets] >= info.ct;
        
    } else if (info.type == ChallengeType_TIMED) {
        if ([g get_time] <= info.ct) {
            return YES;
        } else if ([[UICommon parse_gameengine_time:[g get_time]] isEqualToString:[UICommon parse_gameengine_time:info.ct]]) {
            return YES;
        } else {
            return NO;
        }
        
    }
    return NO;
}

-(void)reset {
    procced = NO;
}

@end
