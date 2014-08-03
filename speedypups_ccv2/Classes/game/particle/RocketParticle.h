#import "StreamParticle.h"

@interface RocketParticle : StreamParticle

+(RocketParticle*)cons_x:(float)x y:(float)y;
-(id)set_vel:(CGPoint)vel;
@end
