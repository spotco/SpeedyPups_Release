#import "WaveParticle.h"
#import "GameRenderImplementation.h"
#import "ObjectPool.h"

@implementation WaveParticle

-(BOOL)is_batched_sprite {
	return YES;
}
-(NSString*)get_batch_sprite_tex_key {
	return TEX_PARTICLES;
}


+(WaveParticle*)cons_x:(float)x y:(float)y vx:(float)vx vtheta:(float)vtheta {
    WaveParticle *p = [ObjectPool depool:[WaveParticle class]];
	[p setDisplayFrame:[CCSpriteFrame frameWithTexture:[Resource get_tex:TEX_PARTICLES] rect:[FileCache get_cgrect_from_plist:TEX_PARTICLES idname:@"grey_particle"]]];
	
	[p setPosition:ccp(x,y)];
    [p cons:vx vtheta:vtheta];
    return p;
}

-(void)repool {
	if ([self class] == [WaveParticle class]) [ObjectPool repool:self class:[WaveParticle class]];
}

-(void)cons:(float)tvx vtheta:(float)tvtheta {
    theta = 0;
    baseline = [self position].y;
    vtheta = tvtheta;
    vx = tvx;
    [self setColor:ccc3(197+arc4random_uniform(20), 225+arc4random_uniform(25), 128+arc4random_uniform(20))];
    [self csf_setScale:float_random(0.25, 1)];
    ct = 800;
}

-(void)update:(GameEngineLayer*)g{
    theta += vtheta;
    [self setPosition:ccp([self position].x+vx,baseline+sinf(theta)*30)];
    [self setOpacity:ct/800.0*255];
    ct--;
}

-(WaveParticle*)set_color:(ccColor3B)c {
	[self setColor:c];
	return self;
}

-(BOOL)should_remove {
    return ct < 0;
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_FG_ISLAND_ORD];
}


@end
