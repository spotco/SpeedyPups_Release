#import "PlayerEffectParams.h"

@interface SubFireworksParticleA : Particle {
    int ct;
}
+(SubFireworksParticleA*)cons_x:(float)x y:(float)y vx:(float)vx vy:(float)vy;
@end

@interface FireworksParticleA : Particle {
    int ct;
}
+(FireworksParticleA*)cons_x:(float)x y:(float)y vx:(float)vx vy:(float)vy ct:(int)ct;
@end

@interface FireworksGroundFlower : Particle {
	int ct;
	CGPoint vel,acel;
}
+(FireworksGroundFlower*)cons_pt:(CGPoint)pt;
@end