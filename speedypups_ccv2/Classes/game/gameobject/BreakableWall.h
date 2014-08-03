#import "GameObject.h"
#import "PolyLib.h"
#import "SpikeVine.h"
#import "BreakableWallRockParticle.h"

@interface BreakableWall : SpikeVine {
    BOOL broken;
}

+(BreakableWall*)cons_x:(float)x y:(float)y x2:(float)x2 y2:(float)y2;

@end
