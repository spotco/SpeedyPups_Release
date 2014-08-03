#import "JumpParticle.h"
#import "FileCache.h"
#import "GameRenderImplementation.h"
#import "GameEngineLayer.h"
#import "ObjectPool.h"

@implementation JumpParticle

static const float TIME = 10.0;
static const float MINSCALE = 1;
static const float MAXSCALE = 2;

+(JumpParticle*)cons_pt:(CGPoint)pt vel:(CGPoint)vel up:(CGPoint)up {
	return [JumpParticle cons_pt:pt vel:vel up:up tex:[Resource get_tex:TEX_DASHJUMPPARTICLES_SS] rect:[FileCache get_cgrect_from_plist:TEX_DASHJUMPPARTICLES_SS idname:@"jumpparticle"] relpos:NO];
}

+(JumpParticle*)cons_pt:(CGPoint)pt vel:(CGPoint)vel up:(CGPoint)up tex:(CCTexture2D *)tex rect:(CGRect)rect relpos:(BOOL)relpos {
	//return [[JumpParticle node] cons_pt:pt vel:vel up:up tex:tex rect:rect relpos:relpos];
	JumpParticle *rtv = [ObjectPool depool:[JumpParticle class]];
	[rtv cons_pt:pt vel:vel up:up tex:tex rect:rect relpos:relpos];
	return rtv;
}

-(void)repool {
	if ([self class] == [JumpParticle class]) [ObjectPool repool:self class:[JumpParticle class]];
}

-(id)cons_pt:(CGPoint)pt vel:(CGPoint)vel up:(CGPoint)up tex:(CCTexture2D*)tex rect:(CGRect)rect relpos:(BOOL)_relpos {
	[self setTexture:tex];
	[self setTextureRect:rect];
	
    [self setPosition:pt];
	[self csf_setScale:MINSCALE];
	[self setOpacity:200];
	
	Vec3D velvec = [VecLib cons_x:vel.x y:vel.y z:0];;
	velvec = [VecLib negate:velvec];
	Vec3D dirvec = [VecLib normalize:
					[VecLib add:[VecLib normalize:velvec]
							 to:[VecLib scale:[VecLib normalize:[VecLib cons_x:up.x y:up.y z:0]]
										   by:0.75]
					 ]
					];
	
	float ccwt = [Common rad_to_deg:[VecLib get_angle_in_rad:dirvec]+45];
	[self setRotation:ccwt > 0 ? 180-ccwt : -(180-ABS(ccwt))];
	
    ct = TIME;
	
    scx = 1;
    scale = 1;
	
	is_relpos = _relpos;
	set_relpos = NO;
	
	return self;
	
}

-(id)set_scale:(float)s {
	scale = s;
	float tar_sc = ((1-ct/TIME)*(MAXSCALE-MINSCALE)+MINSCALE)*scale;
	[self csf_setScaleX:tar_sc*scx];
	[self csf_setScaleY:tar_sc];
	return self;
}

-(id)set_scx:(float)_scx {
	scx = _scx;
	return self;
}

-(void)update:(GameEngineLayer*)g{
    ct--;
	if (is_relpos) {
		if (!set_relpos) {
			rel_pos = ccp([self position].x-g.player.position.x,[self position].y-g.player.position.y);
			set_relpos = YES;
		}
		[self setPosition:CGPointAdd(g.player.position, rel_pos)];
	}
	
	float tar_sc = ((1-ct/TIME)*(MAXSCALE-MINSCALE)+MINSCALE)*scale;
	[self csf_setScaleX:tar_sc*scx];
	[self csf_setScaleY:tar_sc];
    [self setOpacity:(int)(200*(ct/TIME))];
}

-(BOOL)should_remove {
    return ct <= 0;
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_FG_ISLAND_ORD];
}

@end
