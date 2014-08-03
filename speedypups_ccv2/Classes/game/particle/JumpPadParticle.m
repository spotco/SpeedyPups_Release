#import "JumpPadParticle.h"
#import "GameRenderImplementation.h"

@implementation JumpPadParticle
+(JumpPadParticle*)cons_x:(float)x y:(float)y vx:(float)vx vy:(float)vy {
    JumpPadParticle *p = [JumpPadParticle spriteWithTexture:[Resource get_tex:TEX_PARTICLES] rect:[FileCache get_cgrect_from_plist:TEX_PARTICLES idname:@"grey_particle"]];
    [p cons_vx:vx vy:vy];
    p.position = ccp(x,y);
    return p;
}

-(void)cons_vx:(float)lvx vy:(float)lvy {
    [super cons];
    self.vx = lvx;
    self.vy = lvy;
    [self set_color];
    [self csf_setScale:float_random(0.75, 1.75)];
}
-(void)set_color {
    [self setColor:ccc3(150+arc4random_uniform(60), 210+arc4random_uniform(40), 200+arc4random_uniform(50))];
}
@end

@implementation RocketLaunchParticle
+(RocketLaunchParticle*)cons_x:(float)x y:(float)y vx:(float)vx vy:(float)vy {
    RocketLaunchParticle *p = [RocketLaunchParticle spriteWithTexture:[Resource get_tex:TEX_PARTICLES] rect:[FileCache get_cgrect_from_plist:TEX_PARTICLES idname:@"smokecloud"]];
    [p cons_vx:vx vy:vy];
    p.position = ccp(x,y);
    return p;
}

+(RocketLaunchParticle*)cons_x:(float)x y:(float)y vx:(float)vx vy:(float)vy scale:(float)scale {
    RocketLaunchParticle *p = [RocketLaunchParticle cons_x:x y:y vx:vx vy:vy];
    [p csf_setScale:scale];
    return p;
}

-(id)init {
    [self setRotation:float_random(-180, 180)];
    [self csf_setScale:0.85];
    return [super init];
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_ABOVE_FG_ORD];
}

-(void)set_color {
}

-(void)cons_vx:(float)lvx vy:(float)lvy {
    [super cons_vx:lvx vy:lvy];
    //[self setColor:ccc3(200+arc4random_uniform(55), 0+arc4random_uniform(100), 0+arc4random_uniform(100))];
    ct = 30;
}

-(void)update:(GameEngineLayer *)g {
    [super update:g];
	[self setRotation:[self rotation]+5];
}

-(id)set_scale:(float)sc {
	[self csf_setScale:sc];
	return self;
}
@end

@implementation RocketExplodeParticle

+(RocketExplodeParticle*)cons_x:(float)x y:(float)y vx:(float)vx vy:(float)vy {
    RocketExplodeParticle *p = [RocketExplodeParticle spriteWithTexture:[Resource get_tex:TEX_PARTICLES] rect:[FileCache get_cgrect_from_plist:TEX_PARTICLES idname:@"grey_particle"]];
    [p cons_vx:vx vy:vy];
    p.position = ccp(x,y);
    return p;
}

+(RocketExplodeParticle*)cons_x:(float)x y:(float)y vx:(float)vx vy:(float)vy scale:(float)scale {
    RocketExplodeParticle *p = [RocketExplodeParticle cons_x:x y:y vx:vx vy:vy];
    [p csf_setScale:scale];
    return p;
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_ABOVE_FG_ORD];
}

-(void)cons_vx:(float)lvx vy:(float)lvy {
    [super cons_vx:lvx vy:lvy];
    [self setColor:ccc3(255, 140, 0)];
    ct = 20;
    [self csf_setScale:float_random(1, 1.85)];
}

-(RocketExplodeParticle*)set_color:(ccColor3B)c {
	[self setColor:c];
	return self;
}

-(RocketExplodeParticle*)set_scale:(float)sc {
	[self csf_setScale:sc];
	return self;
}

@end
