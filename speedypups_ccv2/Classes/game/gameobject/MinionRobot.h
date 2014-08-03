#import "PhysicsEnabledObject.h"
#import "HitEffect.h"
#import "DazedParticle.h"
#import "BrokenMachineParticle.h"

@interface MinionRobot : GameObject {
    BOOL busted;
    BOOL has_shadow;
	
	CGPoint starting_pos;
	float vx,vy;
	Island *current_island;
	
	CCSprite *body, *bodyimg;
}

+(MinionRobot*)cons_x:(float)x y:(float)y;
+(void)player_do_bop:(Player*)player g:(GameEngineLayer*)g;

@end
