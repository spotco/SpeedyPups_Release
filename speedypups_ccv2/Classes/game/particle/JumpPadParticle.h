#import "StreamParticle.h"

@interface JumpPadParticle : StreamParticle

+(JumpPadParticle*)cons_x:(float)x y:(float)y vx:(float)vx vy:(float)vy;
-(void)cons_vx:(float)lvx vy:(float)lvy;
-(void)set_color;
@end

@interface RocketLaunchParticle : JumpPadParticle

+(RocketLaunchParticle*)cons_x:(float)x y:(float)y vx:(float)vx vy:(float)vy;
+(RocketLaunchParticle*)cons_x:(float)x y:(float)y vx:(float)vx vy:(float)vy scale:(float)scale;

@end

@interface RocketExplodeParticle : JumpPadParticle

+(RocketExplodeParticle*)cons_x:(float)x y:(float)y vx:(float)vx vy:(float)vy;
+(RocketExplodeParticle*)cons_x:(float)x y:(float)y vx:(float)vx vy:(float)vy scale:(float)scale;
-(RocketExplodeParticle*)set_color:(ccColor3B)c;
-(RocketExplodeParticle*)set_scale:(float)sc;
@end
