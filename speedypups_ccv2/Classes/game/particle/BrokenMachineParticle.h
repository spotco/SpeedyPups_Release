#import "BreakableWallRockParticle.h"

@interface BrokenMachineParticle : BreakableWallRockParticle
+(BrokenMachineParticle*)cons_x:(float)x y:(float)y vx:(float)vx vy:(float)vy;
@end

@interface BrokenCopterMachineParticle : BreakableWallRockParticle
+(BrokenCopterMachineParticle*)cons_x:(float)x y:(float)y vx:(float)vx vy:(float)vy pimg:(int)pimg;
+(BrokenCopterMachineParticle*)cons_sub_x:(float)x y:(float)y vx:(float)vx vy:(float)vy pimg:(int)pimg;
+(BrokenCopterMachineParticle*)cons_robot_x:(float)x y:(float)y vx:(float)vx vy:(float)vy pimg:(int)pimg;
@end