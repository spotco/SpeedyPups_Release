#import "BreakableWallRockParticle.h"
#import "FileCache.h"
#import "GameRenderImplementation.h"

#define BreakableWallRockParticle_CT_DEFAULT 50.0

@implementation BreakableWallRockParticle

+(BreakableWallRockParticle*)cons_x:(float)x y:(float)y vx:(float)vx vy:(float)vy {
    BreakableWallRockParticle* p = [BreakableWallRockParticle spriteWithTexture:[Resource get_tex:TEX_CAVE_ROCKPARTICLE]];
    p.position = ccp(x,y);
    [p cons_vx:vx vy:vy];
    return p;
}

+(BreakableWallRockParticle*)cons_lab_x:(float)x y:(float)y vx:(float)vx vy:(float)vy {
    BreakableWallRockParticle* p = [BreakableWallRockParticle spriteWithTexture:[Resource get_tex:TEX_LAB_ROCK_PARTICLE]];
    p.position = ccp(x,y);
    [p cons_vx:vx vy:vy];
    return p;
}

+(BreakableWallRockParticle*)cons_spike_x:(float)x y:(float)y vx:(float)vx vy:(float)vy {
    BreakableWallRockParticle* p = [BreakableWallRockParticle spriteWithTexture:[Resource get_tex:TEX_PARTICLES] rect:[FileCache get_cgrect_from_plist:TEX_PARTICLES idname:@"spike_particle"]];
    p.position = ccp(x,y);
    [p cons_vx:vx vy:vy];
    return p;
}

-(void)cons_vx:(float)tvx vy:(float)tvy {
    vx = tvx;
    vy = tvy;
    [self csf_setScale:float_random(0.5, 1.5)];
    [self setRotation:float_random(-180, 180)];
    ct = (int)BreakableWallRockParticle_CT_DEFAULT;
	gravity = 0.3;
}

-(void)cons {
    vx = float_random(-2, -4);
    vy = float_random(0, 2);
    [self csf_setScale:float_random(0.5, 2)];
    ct = (int)BreakableWallRockParticle_CT_DEFAULT;
	gravity = 0.3;
}

-(void)update:(GameEngineLayer*)g{
    [self setPosition:ccp([self position].x+vx,[self position].y+vy)];
    [self setOpacity:((int)(ct/BreakableWallRockParticle_CT_DEFAULT*255))];
    vy-=gravity;
    ct--;
}

-(int)get_render_ord {
	return [GameRenderImplementation GET_RENDER_FG_ISLAND_ORD];
}

-(BOOL)should_remove {
    return ct <= 0;
}

-(id)set_gravity:(float)f {
	gravity = f;
	return self;
}

@end
