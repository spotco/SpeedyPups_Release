#import "BridgeIsland.h"
#import "LineIsland.h"
#import "GameRenderImplementation.h"

@implementation BridgeIsland

+(BridgeIsland*)cons_pt1:(CGPoint)start pt2:(CGPoint)end height:(float)height ndir:(float)ndir can_land:(BOOL)can_land {
	BridgeIsland *new_island = [BridgeIsland node];
    new_island.fill_hei = height;
    new_island.ndir = ndir;
	[new_island set_pt1:start pt2:end];
	[new_island calc_init];
	new_island.anchorPoint = ccp(0,0);
	new_island.position = ccp(new_island.startX,new_island.startY);
    new_island.can_land = can_land;
	[new_island cons_tex];
	return new_island;
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_BTWN_PLAYER_ISLAND];
}

-(void)calc_init {
    self.self.t_min = 0;
    self.t_max = sqrtf(powf(self.endX - self.startX, 2) + powf(self.endY - self.startY, 2));
}

-(void)cons_tex {
    float BEDGE_WID = 16;
    float BEDGE_HEI = 32;
    
    float BCENTER_WID = 32;
    float BCENTER_HEI = 48;
    
    CGPoint p2off = ccp(self.endX-self.startX,self.endY-self.startY);
    Vec3D linedir = [VecLib cons_x:p2off.x y:p2off.y z:0];
    linedir=[VecLib normalize:linedir];
    
    Vec3D linenormal = [VecLib cross:linedir with:[VecLib Z_VEC]];
    linenormal = [VecLib normalize:linenormal];
    
    /*
     23 --23---23
     
     01   01   01
     */
    linedir = [VecLib scale:linedir by:-BEDGE_WID];
    linenormal=[VecLib scale:linenormal by:BEDGE_HEI];
    left = [Common neu_cons_render_obj:[Resource get_tex:TEX_BRIDGE_EDGE] npts:4];
    left.tri_pts[0] = fccp(linedir.x,linenormal.y);
    left.tri_pts[1] = fccp(0,linenormal.y);
    left.tri_pts[2] = fccp(linedir.x,0);
    left.tri_pts[3] = fccp(0,0);
    
    left.tex_pts[0] = fccp(0,0);
    left.tex_pts[1] = fccp(1,0);
    left.tex_pts[2] = fccp(0,1);
    left.tex_pts[3] = fccp(1,1);
    
    linedir=[VecLib normalize:linedir];
    linedir = [VecLib scale:linedir by:-BEDGE_WID];
    right = [Common neu_cons_render_obj:[Resource get_tex:TEX_BRIDGE_EDGE] npts:4];
    right.tri_pts[1] = fccp(p2off.x+linedir.x,p2off.y+linenormal.y);
    right.tri_pts[0] = fccp(p2off.x,p2off.y+linenormal.y);
    right.tri_pts[3] = fccp(p2off.x+linedir.x,p2off.y);
    right.tri_pts[2] = fccp(p2off.x,p2off.y);
    
    right.tex_pts[1] = fccp(0,0);
    right.tex_pts[0] = fccp(1,0);
    right.tex_pts[3] = fccp(0,1);
    right.tex_pts[2] = fccp(1,1);
    
    linedir=[VecLib normalize:linedir];
    linedir = [VecLib scale:linedir by:2];
    for(int i = 0; i < 4; i++) {
        right.tri_pts[i].x -= linedir.x;
        right.tri_pts[i].y -= linedir.y;
        left.tri_pts[i].x += linedir.x;
        left.tri_pts[i].y += linedir.y;
    }
    
    
    linedir = [VecLib cons_x:p2off.x y:p2off.y z:0];
    linenormal = [VecLib cross:linedir with:[VecLib Z_VEC]];
    linenormal = [VecLib normalize:linenormal];
    linenormal = [VecLib scale:linenormal by:BCENTER_HEI];
    
    [[Resource get_tex:TEX_BRIDGE_SECTION] setClampTexParameters];
    center = [Common neu_cons_render_obj:[Resource get_tex:TEX_BRIDGE_SECTION] npts:4];
    center.tri_pts[0] = fccp(linenormal.x,linenormal.y);
    center.tri_pts[1] = fccp(linedir.x+linenormal.x,linedir.y+linenormal.y);
    center.tri_pts[2] = fccp(0,0);
    center.tri_pts[3] = fccp(linedir.x,linedir.y);
    
    linenormal = [VecLib normalize:linenormal];
    linenormal = [VecLib scale:linenormal by:-10];
    for(int i = 0; i < 4; i++) {
        center.tri_pts[i].x += linenormal.x;
        center.tri_pts[i].y += linenormal.y;
    }
    
    float reps = [VecLib length:linedir] / BCENTER_WID;
    reps = floorf(reps);
    
    center.tex_pts[2] = fccp(0,0);
    center.tex_pts[3] = fccp(reps,0);
    center.tex_pts[0] = fccp(0,1);
    center.tex_pts[1] = fccp(reps,1);
    
}

-(void)link_finish {
    if (self.next != NULL && [self.next isKindOfClass:[LineIsland class]]) {
        ((LineIsland*)self.next).force_draw_leftline = YES;
    }
}

-(void)draw {
    [super draw];
    [Common draw_renderobj:left n_vtx:4];
    [Common draw_renderobj:right n_vtx:4];
    [Common draw_renderobj:center n_vtx:4];
//    glColor4f(1.0, 0, 0, 1.0);
//    ccDrawLine(ccp(0,0), ccp(self.endX-self.startX,endY-startY));
}


@end
