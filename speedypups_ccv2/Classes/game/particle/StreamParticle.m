#import "StreamParticle.h"
#import "FileCache.h"
#import "Player.h"
#import "GameEngineLayer.h"
#import "ObjectPool.h"

@implementation StreamParticle
@synthesize ct;

+(StreamParticle*)cons_x:(float)x y:(float)y {
    //StreamParticle* p = [StreamParticle spriteWithTexture:[Resource get_tex:TEX_PARTICLES] rect:[FileCache get_cgrect_from_plist:TEX_PARTICLES idname:@"grey_particle"]];
    StreamParticle *p = [ObjectPool depool:[StreamParticle class]];
	[p setTexture:[Resource get_tex:TEX_PARTICLES]];
	[p setTextureRect:[FileCache get_cgrect_from_plist:TEX_PARTICLES idname:@"grey_particle"]];
	
	[p cons];
    p.position = ccp(x,y);
    return p;
}

+(StreamParticle*)cons_x:(float)x y:(float)y vx:(float)vx vy:(float)vy {
    //StreamParticle* p = [StreamParticle spriteWithTexture:[Resource get_tex:TEX_PARTICLES] rect:[FileCache get_cgrect_from_plist:TEX_PARTICLES idname:@"grey_particle"]];
    StreamParticle *p = [ObjectPool depool:[StreamParticle class]];
	[p setTexture:[Resource get_tex:TEX_PARTICLES]];
	[p setTextureRect:[FileCache get_cgrect_from_plist:TEX_PARTICLES idname:@"grey_particle"]];
	
	p.position = ccp(x,y);
    [p cons_vx:vx vy:vy];
    return p;
}

-(void)repool {
	if ([self class] == [StreamParticle class]) [ObjectPool repool:self class:[StreamParticle class]];
}

-(void)cons_vx:(float)tvx vy:(float)tvy {
	[self csf_setScale:1];
	[self setRotation:0];
	[self setOpacity:255];
	STREAMPARTICLE_CT_DEFAULT = 40;
    vx = tvx;
    vy = tvy;
    [self csf_setScale:float_random(0.5, 2)];
    ct = (int)STREAMPARTICLE_CT_DEFAULT;
    [self setColor:ccc3(200, 200, 200)];
	is_relpos = NO;
	is_vel_rotation_facing = NO;
	has_set_gravity = NO;
	has_set_final_color = NO;
	has_set_render_ord = NO;
}

-(void)cons {
	[self csf_setScale:1];
	[self setRotation:0];
	[self setOpacity:255];
	STREAMPARTICLE_CT_DEFAULT = 40;
    vx = float_random(-2, -4);
    vy = float_random(0, 2);
    [self csf_setScale:float_random(0.5, 2)];
    ct = (int)STREAMPARTICLE_CT_DEFAULT;
	is_relpos = NO;
	is_vel_rotation_facing = NO;
	has_set_gravity = NO;
	has_set_final_color = NO;
	has_set_render_ord = NO;
}

-(id)set_relpos:(CGPoint)player {
	is_relpos = YES;
	rel_pos = ccp([self position].x-player.x,[self position].y-player.y);
	return self;
}
-(id)set_color:(ccColor3B)c {
	[self setColor:c];
	[self set_final_color:c];
	return self;
}
-(id)set_scale_x:(float)x y:(float)y {
	[self csf_setScaleX:x];
	[self csf_setScaleY:y];
	return self;
}
-(id)set_vel_rotation_facing {
	is_vel_rotation_facing = YES;
	[self setRotation:[VecLib get_rotation:[VecLib cons_x:vx y:vy z:0] offset:-90]];
	return self;
}
-(void)update:(GameEngineLayer*)g{
    if (is_relpos) {
		[self setPosition:ccp(g.player.position.x+rel_pos.x,[self position].y+vy*[Common get_dt_Scale])];
		rel_pos.x += vx * [Common get_dt_Scale];
	} else {
		[self setPosition:ccp([self position].x+vx*[Common get_dt_Scale],[self position].y+vy*[Common get_dt_Scale])];
	}
	
	if (is_vel_rotation_facing) {
		[self setRotation:[VecLib get_rotation:[VecLib cons_x:vx y:vy z:0] offset:-90]];
	}
	
	
    [self setOpacity:((int)(ct/STREAMPARTICLE_CT_DEFAULT*255))];
	if (has_set_gravity) {
		vx += gravity.x * [Common get_dt_Scale];
		vy += gravity.y * [Common get_dt_Scale];
	}
	if (has_set_final_color) {
		float pct = ct/STREAMPARTICLE_CT_DEFAULT;
		[self setColor:ccc3(pct*(initial_color.r-final_color.r)+final_color.r,
							pct*(initial_color.g-final_color.g)+final_color.g,
							pct*(initial_color.b-final_color.b)+final_color.b)];
	}
    ct-=[Common get_dt_Scale];
}

-(BOOL)should_remove {
    return ct <= 0;
}

-(StreamParticle*)set_scale:(float)scale {
	[self csf_setScale:scale];
	return self;
}

-(StreamParticle*)set_ctmax:(int)ctmax {
	STREAMPARTICLE_CT_DEFAULT =  ctmax;
	ct = ctmax;
	return self;
}

-(StreamParticle*)set_gravity:(CGPoint)g {
	has_set_gravity = YES;
	gravity = g;
	return self;
}
-(StreamParticle*)set_final_color:(ccColor3B)color {
	has_set_final_color = YES;
	final_color = color;
	initial_color = [self color];
	return self;
}
-(StreamParticle*)set_render_ord:(int)ord {
	has_set_render_ord = YES;
	render_ord = ord;
	return self;
}

-(int)get_render_ord {
	if (has_set_render_ord) return render_ord;
	return [super get_render_ord];
}

@end
