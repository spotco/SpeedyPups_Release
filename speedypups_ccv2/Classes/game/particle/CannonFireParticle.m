#import "CannonFireParticle.h"
#import "FileCache.h"
#import "Resource.h"
#import "GameRenderImplementation.h"

@implementation CannonFireParticle

static const float TIME = 30.0;

-(CCAction*)cons_anim:(NSArray*)a speed:(float)speed {
	CCTexture2D *texture = [Resource get_tex:TEX_CANNONFIRE_PARTICLE];
	NSMutableArray *animFrames = [NSMutableArray array];
    for (NSString* k in a) [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:TEX_CANNONFIRE_PARTICLE idname:k]]];
    return  [CCAnimate actionWithAnimation:[CCAnimation animationWithFrames:animFrames delay:speed] restoreOriginalFrame:NO];
}

+(CannonFireParticle*)cons_x:(float)x y:(float)y {
    return [[CannonFireParticle node] cons_x:x y:y];
}


-(id)cons_x:(float)x y:(float)y {
    CCAction* anim = [self cons_anim:[NSArray arrayWithObjects:@"explode_1",@"explode_2",@"explode_3",@"explode_4",@"explode_5",@"", nil] speed:0.075];
    [self runAction:anim];
    [self setPosition:ccp(x,y)];
    ct = TIME;
    [self csf_setScale:MINSCALE];
	[self setAnchorPoint:ccp(1,0.5)];
    
    return self;
}

-(id)set_scale:(float)sc {
	MINSCALE = sc;
	MAXSCALE = sc;
	return self;
}

-(void)update:(GameEngineLayer*)g{
    ct--;
    [self csf_setScale:(1-ct/TIME)*(MAXSCALE-MINSCALE)+MINSCALE];
    [self setOpacity:(int)(55*(ct/TIME))+200];
}

-(BOOL)should_remove {
    return ct <= 0;
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_FG_ISLAND_ORD]+2;
}


@end
