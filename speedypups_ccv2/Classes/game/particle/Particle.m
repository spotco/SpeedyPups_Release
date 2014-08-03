#import "Particle.h"
#import "GameRenderImplementation.h"

@implementation Particle
@synthesize vx,vy;

-(void)update:(GameEngineLayer*)g {}
-(BOOL)should_remove { return YES; }
-(int)get_render_ord { return [GameRenderImplementation GET_RENDER_GAMEOBJ_ORD]; }

- (void)setOpacity:(GLubyte)opacity {
	[super setOpacity:opacity];
    
	for(CCSprite *sprite in [self children]) {
        
		sprite.opacity = opacity;
	}
}

-(void)repool{}

@end
