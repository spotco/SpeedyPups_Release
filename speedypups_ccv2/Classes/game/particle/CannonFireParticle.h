#import "Particle.h"

@interface CannonFireParticle : Particle {
    int ct;
	float MINSCALE, MAXSCALE;
}

+(CannonFireParticle*)cons_x:(float)x y:(float)y;
-(id)set_scale:(float)sc;
@end
