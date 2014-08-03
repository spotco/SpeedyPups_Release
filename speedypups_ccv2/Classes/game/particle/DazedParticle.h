#import "Particle.h"

@interface DazedParticle : Particle {
    int ct;
    float cx,cy,theta;
	
    id<PhysicsObject> __unsafe_unretained tar;
	CCSprite __unsafe_unretained *tarsprite;
}

+(DazedParticle*)cons_x:(float)x y:(float)y theta:(float)theta time:(int)time tracking:(id<PhysicsObject>)t;
+(void)cons_effect:(GameEngineLayer*)g tar:(id<PhysicsObject>)tar time:(int)time;
+(void)cons_effect:(id)particlelayer sprite:(CCSprite*)tar time:(int)time;

@end
