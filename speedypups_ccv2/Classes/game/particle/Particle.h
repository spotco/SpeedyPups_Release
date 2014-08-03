#import "CCSprite.h"
#import "Resource.h"
#import "Common.h"
@class GameEngineLayer;

@interface Particle : CSF_CCSprite {
    float vx,vy;
}

@property(readwrite,assign) float vx,vy;

-(void)update:(GameEngineLayer*)g;
-(BOOL)should_remove;
-(int)get_render_ord;

-(void)repool;

@end
