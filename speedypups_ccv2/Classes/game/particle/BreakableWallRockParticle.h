#import "Particle.h"

@interface BreakableWallRockParticle : Particle {
    int ct;
	float gravity;
}

+(BreakableWallRockParticle*)cons_x:(float)x y:(float)y vx:(float)vx vy:(float)vy;
+(BreakableWallRockParticle*)cons_lab_x:(float)x y:(float)y vx:(float)vx vy:(float)vy;
+(BreakableWallRockParticle*)cons_spike_x:(float)x y:(float)y vx:(float)vx vy:(float)vy;
-(void)cons_vx:(float)tvx vy:(float)tvy ;
-(id)set_gravity:(float)f;

@end
