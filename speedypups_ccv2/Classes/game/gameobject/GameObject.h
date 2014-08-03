#import "CCNode.h"
#import "Player.h"
#import "GameRenderImplementation.h"
#import "GEventDispatcher.h"
@class GameEngineLayer;
@class ChallengeInfo;

@interface GameObject : CSF_CCSprite {
    BOOL active,do_render;
}

@property(readwrite,assign) BOOL active,do_render;

-(void)update:(Player*)player g:(GameEngineLayer *)g;
-(void)autolevel_set_position:(CGPoint)pt;
-(HitRect)get_hit_rect;
-(void)set_active:(BOOL)t_active;
-(int)get_render_ord;
-(void)reset;
-(void)check_should_render:(GameEngineLayer *)g;
-(void)notify_challenge_mode:(ChallengeInfo*)c;

-(void)repool;

-(Island*)get_connecting_island:(NSMutableArray*)islands;
@end
