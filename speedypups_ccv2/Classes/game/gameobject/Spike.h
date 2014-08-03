#import "GameObject.h"
#import "HitEffect.h"
#import "DazedParticle.h"

@interface Spike : GameObject {
    BOOL activated;
}

+(Spike*)cons_x:(float)posx y:(float)posy islands:(NSMutableArray*)islands;

@property(readwrite,strong)CCSprite* img;
@end
