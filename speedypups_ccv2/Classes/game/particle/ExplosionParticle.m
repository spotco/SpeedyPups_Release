#import "ExplosionParticle.h"
#import "GameEngineLayer.h"

@implementation ExplosionParticle

static const float TIME = 30.0;
static const float MINSCALE = 0.5;
static const float MAXSCALE = 0.5;

-(CCAction*)cons_anim:(NSArray*)a speed:(float)speed {
	CCTexture2D *texture = [Resource get_tex:TEX_EXPLOSION];
	NSMutableArray *animFrames = [NSMutableArray array];
    for (NSString* k in a) [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:TEX_EXPLOSION idname:k]]];
    return  [CCAnimate actionWithAnimation:[CCAnimation animationWithFrames:animFrames delay:speed] restoreOriginalFrame:NO];
}

+(ExplosionParticle*)cons_x:(float)x y:(float)y {
    return [[ExplosionParticle node] cons_x:x y:y];
}

-(id)set_scale:(float)scale {
	sc = scale;
	[self csf_setScale:((1-ct/TIME)*(MAXSCALE-MINSCALE)+MINSCALE)*sc];
	return self;
}

-(id)cons_x:(float)x y:(float)y {
    CCAction* anim = [self cons_anim:[NSArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"empty", nil] speed:0.075];
    [self runAction:anim];
	sc = 1;
    
    [self setPosition:ccp(x,y)];
    ct = TIME;
    [self csf_setScale:MINSCALE];
    
    return self;
}

-(void)update:(GameEngineLayer*)g{
    ct--;
    [self csf_setScale:((1-ct/TIME)*(MAXSCALE-MINSCALE)+MINSCALE)*sc];
    [self setOpacity:(ct/TIME)*255];
}

-(BOOL)should_remove {
    return ct <= 0;
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_FG_ISLAND_ORD];
}

@end


@implementation RelativePositionExplosionParticle

+(RelativePositionExplosionParticle*) cons_x:(float)x y:(float)y player:(CGPoint)player{
    return [[RelativePositionExplosionParticle node] cons_x:x y:y player:player];
}

-(id)cons_x:(float)x y:(float)y player:(CGPoint)player {
    rel_pos = ccp(x-player.x,y-player.y);
    [super cons_x:x y:y];
    return self;
}

-(void)update:(GameEngineLayer*)g{
    [self setPosition:ccp(rel_pos.x+g.player.position.x,[self position].y)];
    [super update:g];
}

@end
