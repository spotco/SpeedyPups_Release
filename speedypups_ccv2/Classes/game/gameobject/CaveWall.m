#import "CaveWall.h"
#import "GameEngineLayer.h"
#import "Common.h"

@implementation CaveWall

+(CaveWall*)cons_x:(float)x y:(float)y width:(float)width height:(float)height g:(GameEngineLayer*)g {
    CaveWall* n = [CaveWall node];
    [n cons_x:x y:y width:width height:height g:g];
    return n;
}

-(id)init {
	self = [super init];
	[self csf_setScale:1/CC_CONTENT_SCALE_FACTOR()];
	return self;
}

-(void)cons_x:(float)x y:(float)y width:(float)width height:(float)height g:(GameEngineLayer*)g {
    [self setPosition:ccp(x,y)];
    wid = width;
    hei = height;
    
    tex = [Common neu_cons_render_obj:[self get_tex:g] npts:4];
    active = YES;
    /*10
      32*/
	
    tex.tri_pts[3] = fccp(0,0);
    tex.tri_pts[2] = fccp(width,0);
    tex.tri_pts[1] = fccp(0,height);
    tex.tri_pts[0] = fccp(width,height);
    
    for (int i = 0; i < 4; i++) {
        tex.tex_pts[i] = fccp(
			(tex.tri_pts[i].x+[self position].x)/tex.texture.pixelsWide,
			-(tex.tri_pts[i].y+[self position].y)/tex.texture.pixelsHigh
		);
    }
}

-(CCTexture2D*)get_tex:(GameEngineLayer *)g {
    return [Resource get_tex:TEX_GROUND_TEX_1];
}

-(void)draw {
    [super draw];
    if (do_render) {
        [Common draw_renderobj:tex n_vtx:4];
    }
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:[self position].x y1:[self position].y wid:wid hei:hei];
}

-(void)set_active:(BOOL)t_active {
    active = t_active;
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_GAMEOBJ_ORD]-1;
}


@end
