#import "CapeGameSpikeVine.h"
#import "Resource.h"
#import "AudioManager.h"
#import "CapeGamePlayer.h"

@implementation CapeGameSpikeVine

#define BASE_IMG_WID 64.0
#define BASE_IMG_HEI 16.0
#define CENTER_IMG_WID 56.0
#define CENTER_IMG_HEI 128.0

+(CapeGameSpikeVine*)cons_pt1:(CGPoint)pt1 pt2:(CGPoint)pt2 {
	return [[CapeGameSpikeVine node] cons_pt1:pt1 pt2:pt2];
}

-(id)cons_pt1:(CGPoint)pt1 pt2:(CGPoint)pt2 {
	[self setPosition:pt1];
    dir_vec = [VecLib cons_x:pt2.x-pt1.x y:pt2.y-pt1.y z:0];
	[self cons_img];
	active = YES;
	
	[self setScale:1];
	
	return self;
}

-(void)update:(CapeGameEngineLayer *)g {
	if (!active) return;
	
	float dist = [Common distanceBetween:[self position] and:g.player.position];
	if (dist > 2000) {
		[self setVisible:NO];
	} else {
		[self setVisible:YES];
		
	}
	
	SATPoly r_vine = [self get_hitpoly];
	float min_x = INFINITY;
	float max_x = -INFINITY;
	for (int i = 0; i < r_vine.length; i++) {
		min_x = MIN(min_x, r_vine.pts[i].x);
		max_x = MAX(max_x, r_vine.pts[i].x);
	}
	if (g.player.position.x < min_x || g.player.position.x > max_x)return;
	
	SATPoly r_playerhit = [PolyLib hitrect_to_poly:[g.player get_hitrect]];
	if ([PolyLib poly_intersect_SAT:r_vine b:r_playerhit]) {
		active = NO;
		[AudioManager playsfx:SFX_HIT];
		[g do_get_hit];
		[g shake_for:15 intensity:6];
		[g freeze_frame:6];
	}
}

-(SATPoly)get_hitpoly {
	SATPoly rtv = r_hitbox;
	for(int i = 0; i < rtv.length; i++) {
		rtv.pts[i].x += [self position].x;
		rtv.pts[i].y += [self position].y;
	}
	return rtv;
}

-(void)draw {
	[super draw];
    [Common draw_renderobj:top n_vtx:4];
    [Common draw_renderobj:bottom n_vtx:4];
    [Common draw_renderobj:center n_vtx:4];
}

-(CCTexture2D*)get_base_tex {
    return [Resource get_tex:TEX_SPIKE_VINE_BOTTOM];
}

-(CCTexture2D*)get_section_tex {
    return [Resource get_tex:TEX_SPIKE_VINE_SECTION];
}

-(CGSize)get_base_size {
    return CGSizeMake(BASE_IMG_WID, BASE_IMG_HEI);
}

-(CGSize)get_section_size {
    return CGSizeMake(CENTER_IMG_WID, CENTER_IMG_HEI);
}

-(void)cons_img {
    CCTexture2D* tex = [self get_base_tex];
	
    CGSize s = [self get_base_size];
    float bwid = [tex pixelsWide];
    float bhei = [tex pixelsHigh];
    
    Vec3D normal = [VecLib cross:dir_vec with:[VecLib Z_VEC]];
    normal = [VecLib normalize:normal];
    normal = [VecLib scale:normal by:s.width/2];
    
    Vec3D r_dirv = [VecLib cons_x:dir_vec.x y:dir_vec.y z:0];
    r_dirv = [VecLib normalize:r_dirv];
    r_dirv=[VecLib scale:r_dirv by:-s.height];
    /**
     (0)   (origin)    (1)  --> normal
     |  r_dirv
     (2)      \ /      (3)
     
     gl rounds texture to nearest 2^n size, use img size constants to properly size
     **/
    
    bottom = [Common neu_cons_render_obj:tex npts:4];
    
    bottom.tri_pts[0] = fccp(-normal.x            ,-normal.y);
    bottom.tri_pts[1] = fccp(normal.x             ,normal.y);
    bottom.tri_pts[2] = fccp(-normal.x + r_dirv.x , -normal.y + r_dirv.y);
    bottom.tri_pts[3] = fccp(normal.x + r_dirv.x  ,normal.y + r_dirv.y);
    
    bottom.tex_pts[0] = fccp(0,0);
    bottom.tex_pts[1] = fccp(1,0);
    bottom.tex_pts[2] = fccp(0,1);
    bottom.tex_pts[3] = fccp(1,1);
    
    top = [Common neu_cons_render_obj:tex npts:4];
    top.tri_pts[0] = fccp(-normal.x + dir_vec.x - r_dirv.x              , -normal.y + dir_vec.y - r_dirv.y );
    top.tri_pts[1] = fccp(normal.x  + dir_vec.x - r_dirv.x             , normal.y + dir_vec.y - r_dirv.y);
    top.tri_pts[2] = fccp(-normal.x  + dir_vec.x   ,  -normal.y  + dir_vec.y);
    top.tri_pts[3] = fccp(normal.x  + dir_vec.x    , normal.y  + dir_vec.y);
    
    top.tex_pts[2] = fccp(0,0);
    top.tex_pts[3] = fccp(0.95,0);
    top.tex_pts[0] = fccp(0,0.95);
    top.tex_pts[1] = fccp(0.95,0.95);
    
    
    tex = [self get_section_tex];
    s = [self get_section_size];
    bwid = [tex pixelsWide];
    bhei = [tex pixelsHigh];
    normal=[VecLib normalize:normal];
    normal=[VecLib scale:normal by:bwid/2];
    
    center = [Common neu_cons_render_obj:tex npts:4];
    
    center.tri_pts[0] = fccp(-normal.x            ,-normal.y);
    center.tri_pts[1] = fccp(normal.x             ,normal.y);
    center.tri_pts[2] = fccp(-normal.x + dir_vec.x , -normal.y + dir_vec.y);
    center.tri_pts[3] = fccp(normal.x + dir_vec.x  ,normal.y + dir_vec.y);
    
    float len = [VecLib length:dir_vec];
    
    center.tex_pts[0] = fccp(0,0);
    center.tex_pts[1] = fccp(s.width/bwid,0);
    center.tex_pts[2] = fccp(0, (len/s.height) * s.height/bhei);
    center.tex_pts[3] = fccp(s.width/bwid,  (len/s.height) * s.height/bhei);
    
    
    r_hitbox = [PolyLib cons_SATPoly_quad:ccp(center.tri_pts[0].x, center.tri_pts[0].y)
                                        b:ccp(center.tri_pts[1].x, center.tri_pts[1].y)
                                        c:ccp(center.tri_pts[3].x, center.tri_pts[3].y)
                                        d:ccp(center.tri_pts[2].x, center.tri_pts[2].y)];
}

@end
