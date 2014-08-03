
#import "LineIsland.h"
#import "GameEngineLayer.h"
#import "ObjectPool.h"

@implementation LineIsland

#define HEI 56
#define OFFSET -40

#define MVR_ROUNDED_CORNER_SCALE 8
#define NORMAL_ROUNDED_CORNER_SCALE 20
#define BORDER_LINE_WIDTH 5
#define TL_DOWNOFFSET 20

#define BOTTOM_BORDER_IGNORE_HEI 200

@synthesize tl,bl,tr,br;
@synthesize force_draw_leftline,force_draw_rightline;

+(LineIsland*)cons_pt1:(CGPoint)start pt2:(CGPoint)end height:(float)height ndir:(float)ndir can_land:(BOOL)can_land g:(GameEngineLayer *)g {
	//LineIsland *new_island = [LineIsland node];
	LineIsland *new_island = [ObjectPool depool:[LineIsland class]];
	
	[new_island reset_fields];
	
	[new_island set_gameengine:g];
    new_island.fill_hei = height;
    new_island.self.ndir = ndir;
	[new_island set_pt1:start pt2:end];
	[new_island calc_init];
	new_island.anchorPoint = ccp(0,0);
	new_island.position = ccp(new_island.startX,new_island.startY);
    new_island.can_land = can_land;
	[new_island cons_tex];
	[new_island cons_top];
	return new_island;
}

-(void)reset_fields {
	has_gen_hitrect = NO;
	has_transformed_renderpts = NO;
	force_draw_leftline = NO;
	force_draw_rightline = NO;
	self.next = NULL;
	self.prev = NULL;
	self.can_land = NO;
}

-(id)init {
	self = [super init];
	main_fill = [[GLRenderObject alloc] init];
	top_fill = [[GLRenderObject alloc] init];
	corner_fill = [[GLRenderObject alloc] init];
	tl_top_corner = [[GLRenderObject alloc] init];
	tr_top_corner = [[GLRenderObject alloc] init];
	bottom_line_fill = [[GLRenderObject alloc] init];
	corner_line_fill = [[GLRenderObject alloc] init];
	left_line_fill = [[GLRenderObject alloc] init];
	right_line_fill = [[GLRenderObject alloc] init];
	toppts_fill = [[GLRenderObject alloc] init];
	return self;
}

-(void)repool {
	if ([self class] == [LineIsland class]) {
		gameengine = NULL;
		[ObjectPool repool:self class:[LineIsland class]];
	}
}

-(void)set_gameengine:(GameEngineLayer*)g {
	gameengine = g;
}

-(void)check_should_render:(GameEngineLayer *)g {
    
    if ([Common hitrect_touch:[g get_viewbox] b:[self get_hitrect]]) {
        do_draw = YES;
        if (!self.visible) {
            [self setVisible:YES];
        }
    } else {
        do_draw = NO;
        if (self.visible) {
            [self setVisible:NO];
        }
    }
    
    if (do_draw) {
        [BatchDraw add:top_fill key:top_fill.texture.name z_ord:[self get_render_ord] draw_ord:2];
        [BatchDraw add:main_fill key:main_fill.texture.name z_ord:[self get_render_ord] draw_ord:0];
        
        if (self.prev == NULL || force_draw_leftline)
            [BatchDraw add:left_line_fill key:left_line_fill.texture.name z_ord:[self get_render_ord] draw_ord:3];
        
        if (self.next == NULL || force_draw_rightline)
            [BatchDraw add:right_line_fill key:right_line_fill.texture.name z_ord:[self get_render_ord] draw_ord:4];
        
        if (bottom_line_fill.isalloc == 1 && fill_hei <= BOTTOM_BORDER_IGNORE_HEI)
            [BatchDraw add:bottom_line_fill key:bottom_line_fill.texture.name z_ord:[self get_render_ord] draw_ord:5];
        
        
        if (self.prev == NULL || force_draw_leftline)
            [BatchDraw add:tl_top_corner key:tl_top_corner.texture.name z_ord:[self get_render_ord] draw_ord:6];
        
        if (self.next == NULL || force_draw_rightline)
            [BatchDraw add:tr_top_corner key:tr_top_corner.texture.name z_ord:[self get_render_ord] draw_ord:7];
        
        
        if (self.next != NULL && !(force_draw_leftline||force_draw_rightline)) {
            [BatchDraw add:corner_fill key:corner_fill.texture.name z_ord:[self get_render_ord] draw_ord:8];
            [BatchDraw add:toppts_fill key:toppts_fill.texture.name z_ord:[self get_render_ord] draw_ord:9];
            
            if (fill_hei <= BOTTOM_BORDER_IGNORE_HEI)
                [BatchDraw add:corner_line_fill key:corner_line_fill.texture.name z_ord:[self get_render_ord] draw_ord:10];
        }
        
    }
    
}

-(HitRect)get_hitrect {
    if (has_gen_hitrect == NO) {
        has_gen_hitrect = YES;
        int x_max = main_fill.tri_pts[0].x;
        int x_min = main_fill.tri_pts[0].x;
        int y_max = main_fill.tri_pts[0].y;
        int y_min = main_fill.tri_pts[0].y;
        for (int i = 0; i < 4; i++) {
            x_max = MAX(main_fill.tri_pts[i].x,x_max);
            x_min = MIN(main_fill.tri_pts[i].x,x_min);
            y_max = MAX(main_fill.tri_pts[i].y,y_max);
            y_min = MIN(main_fill.tri_pts[i].y,y_min);
        }
        cache_hitrect = [Common hitrect_cons_x1:x_min y1:y_min x2:x_max y2:y_max];
    }
    return cache_hitrect;
}

-(void)calc_init {
    self.t_min = 0;
    self.t_max = sqrtf(powf(self.endX - self.startX, 2) + powf(self.endY - self.startY, 2));
    do_draw = YES;
    force_draw_leftline = NO;
    force_draw_rightline = NO;
    has_gen_hitrect = NO;
}

-(void) draw {
    return;
    if (!do_draw) {
        return;
    }
	[super draw];
}

-(WorldNum)get_worldnum {
	return gameengine.world_mode.cur_world;
}

-(CCTexture2D*)get_tex_fill {
	if ([self get_worldnum] == WorldNum_3) {
		return [Resource get_tex:TEX_BG3_ISLAND_FILL];
	}
    return [Resource get_tex:TEX_GROUND_TEX_1];
}
-(CCTexture2D*)get_tex_corner {
	
	if ([self get_worldnum] == WorldNum_1) {
		return [Resource get_tex:TEX_TOP_EDGE];
		
	} else if ([self get_worldnum] == WorldNum_2) {
		return [Resource get_tex:TEX_BG2_ISLAND_TOP_EDGE];
		
	} else if ([self get_worldnum] == WorldNum_3) {
		return [Resource get_tex:TEX_BG3_ISLAND_EDGE];
		
	}
	return [Resource get_tex:TEX_TOP_EDGE];
}
-(CCTexture2D*)get_tex_border {
    return [Resource get_tex:TEX_ISLAND_BORDER];
}
-(CCTexture2D*)get_tex_top {
	if ([self get_worldnum] == WorldNum_1) {
		return [Resource get_tex:TEX_GROUND_TOP_1];
		
	} else if ([self get_worldnum] == WorldNum_2) {
		return [Resource get_tex:TEX_BG2_ISLAND_TOP_FILL];
		
	} else if ([self get_worldnum] == WorldNum_3) {
		return [Resource get_tex:TEX_BG3_TOP_FILL];
		
	}
    return [Resource get_tex:TEX_GROUND_TOP_1];
}
-(CCTexture2D*)get_corner_fill_color {
	if ([self get_worldnum] == WorldNum_1) {
		return [Resource get_tex:TEX_GROUND_CORNER_TEX_1];
		
	} else if ([self get_worldnum] == WorldNum_2) {
		return [Resource get_tex:TEX_BG2_ISLAND_CORNER];
		
	} else if ([self get_worldnum] == WorldNum_3) {
		return [Resource get_tex:TEX_BG3_ISLAND_CORNER];
		
	}
	return [Resource get_tex:TEX_GROUND_CORNER_TEX_1];
}

-(float)get_corner_top_fill_scale {
    return 26.0;
}

-(Vec3D)scale_ndir:(Vec3D)v {
    return [VecLib scale:v by:self.ndir];
}

-(void)cons_tex {
    //init islandfill
    main_fill = [Common cons_render_obj:[self get_tex_fill] npts:4 obj:main_fill];
	
	fCGPoint *tri_pts = main_fill.tri_pts;
    
    Vec3D v3t2 = [VecLib cons_x:(self.endX - self.startX) y:(self.endY - self.startY) z:0];
    Vec3D vZ = [VecLib Z_VEC];
    Vec3D v3t1 = [VecLib cross:v3t2 with:vZ];
    
    v3t1 = [VecLib normalize:v3t1];
    v3t1 = [self scale_ndir:v3t1];
    
    float taille = fill_hei;
    
    /**
     32
     10
     **/
    tri_pts[3] = fccp(0,0);
    tri_pts[2] = fccp(self.endX-self.startX,self.endY-self.startY);
    tri_pts[1] = fccp(0+v3t1.x * taille,0+v3t1.y * taille);
    tri_pts[0] = fccp(self.endX-self.startX +v3t1.x * taille ,self.endY-self.startY +v3t1.y * taille);
	
    [self main_fill_tex_map];
    
    
    [self cons_LR_line_with_v3t1:v3t1 v3t2:v3t2];
}

-(void)main_fill_tex_map {
    for (int i = 0; i < 4; i++) {
        main_fill.tex_pts[i] = fccp(( main_fill.tri_pts[i].x+self.startX)/main_fill.texture.pixelsWide,
                                   ( main_fill.tri_pts[i].y+self.startY)/main_fill.texture.pixelsHigh);
    }
}

-(void) cons_LR_line_with_v3t1:(Vec3D)v3t1 v3t2:(Vec3D)v3t2 {
    /**
     TL TR
     BL BR
     **/
    bl = main_fill.tri_pts[1];
    br = main_fill.tri_pts[0];
    tl = main_fill.tri_pts[3];
    tr = main_fill.tri_pts[2];
    
    v3t1 = [VecLib normalize:v3t1];
    [VecLib scale:v3t1 by:TL_DOWNOFFSET];
    tl = fccp(tl.x + v3t1.x, tl.y + v3t1.y);
    tr = fccp(tr.x + v3t1.x, tr.y + v3t1.y);
    
    [self cons_left_line_fill];
    [self cons_right_line_fill];
}

-(void)cons_top {
    //set top green bar
    //also initially sets toppts
    top_fill = [Common cons_render_obj:[self get_tex_top] npts:4 obj:top_fill];
    toppts_fill = [Common cons_render_obj:[self get_corner_fill_color] npts:3 obj:toppts_fill];
    toppts_fill.isalloc = 0;
    
	fCGPoint* tri_pts = top_fill.tri_pts;
	fCGPoint* tex_pts = top_fill.tex_pts;
	CCTexture2D* texture = top_fill.texture;
	
	float dist = sqrt(pow(self.endX-self.startX, 2)+pow(self.endY-self.startY, 2));
    
    
    Vec3D v3t2 = [VecLib cons_x:(self.endX - self.startX) y:(self.endY - self.startY) z:0];
    Vec3D vZ = [VecLib Z_VEC];
    
    Vec3D v3t1 = [VecLib cross:v3t2 with:vZ];
    v3t1 = [VecLib normalize:v3t1];
    v3t1 = [VecLib negate:v3t1];
    v3t1 = [self scale_ndir:v3t1];
    
    float hei = HEI;
    float offset = OFFSET;
    float d_o_x = offset * v3t1.x;
    float d_o_y = offset * v3t1.y;
    /**
     10
     32
     **/
    tri_pts[2] = fccp(self.endX-self.startX + d_o_x              ,self.endY-self.startY + d_o_y);
    tri_pts[3] = fccp(d_o_x                            , d_o_y);
    tri_pts[0] = fccp(self.endX-self.startX+v3t1.x*hei  + d_o_x  ,self.endY-self.startY+v3t1.y*hei + d_o_y);
    tri_pts[1] = fccp(v3t1.x*hei + d_o_x               ,v3t1.y*hei + d_o_y);
    
    tex_pts[0] = fccp(dist/texture.pixelsWide,0);
    tex_pts[1] = fccp(0,0);
    tex_pts[2] = fccp(dist/texture.pixelsWide,1);
    tex_pts[3] = fccp(0,1);
    
    toppts_fill.tri_pts[0] = fccp(self.endX-self.startX,self.endY-self.startY);
    toppts_fill.tri_pts[1] = fccp(tri_pts[2].x,tri_pts[2].y);
    
    v3t2 = [VecLib negate:v3t2];
    v3t2 = [VecLib normalize:v3t2];
    [self cons_tl_top:tri_pts[1] bot:tri_pts[3] vec:v3t2];
    v3t2 = [VecLib negate:v3t2];
    [self cons_tr_top:tri_pts[2] bot:tri_pts[0] vec:v3t2];
    
    [self cons_bottom_line_fill];
}

-(GLRenderObject*)cons_TRorTL_top:(fCGPoint)top bot:(fCGPoint)bot vec:(Vec3D)vec o:(GLRenderObject*)o {
    Vec3D mvr = [VecLib cons_x:-vec.x y:-vec.y z:0];
    mvr = [VecLib scale:mvr by:MVR_ROUNDED_CORNER_SCALE];
    
    top = ccp2fccp([VecLib transform_pt:fccp2ccp(top) by:mvr]);
    bot = ccp2fccp([VecLib transform_pt:fccp2ccp(bot) by:mvr]);
    [Common cons_render_obj:[self get_tex_corner] npts:4 obj:o];
	
	ccTexParams par = {GL_LINEAR, GL_LINEAR, GL_CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE};
	[o.texture setTexParameters:&par];
	
	fCGPoint* tri_pts = o.tri_pts;
    
    vec = [VecLib scale:[VecLib normalize:vec] by:NORMAL_ROUNDED_CORNER_SCALE];
    
    tri_pts[0] = fccp(top.x+vec.x,top.y+vec.y);
    tri_pts[1] = top;
    tri_pts[2] = fccp(bot.x+vec.x,bot.y+vec.y);
    tri_pts[3] = bot;
    
    return o;
}

-(void)cons_tl_top:(fCGPoint)top bot:(fCGPoint)bot vec:(Vec3D)vec {
    tl_top_corner = [self cons_TRorTL_top:top bot:bot vec:vec o:tl_top_corner];
    fCGPoint* tex_pts = tl_top_corner.tex_pts;
    
    tex_pts[0] = fccp(0.05,0);
    tex_pts[1] = fccp(1,0);
    tex_pts[3] = fccp(1,1);
    tex_pts[2] = fccp(0.05,1);
}

-(void)cons_tr_top:(fCGPoint)top bot:(fCGPoint)bot vec:(Vec3D)vec {
    tr_top_corner = [self cons_TRorTL_top:top bot:bot vec:vec o:tr_top_corner];
    fCGPoint* tex_pts = tr_top_corner.tex_pts;
    
    tex_pts[2] = fccp(0.05,0);
    tex_pts[3] = fccp(1,0);
    tex_pts[1] = fccp(1,1);
    tex_pts[0] = fccp(0.05,1);
}

-(GLRenderObject*)line_from:(fCGPoint)a to:(fCGPoint)b scale:(float)scale n:(GLRenderObject*)n {
    [Common cons_render_obj:[self get_tex_border] npts:4 obj:n];
    n.isalloc = 1;
    fCGPoint* tri_pts = n.tri_pts;
	fCGPoint* tex_pts = n.tex_pts;
    
    Vec3D v = [VecLib cons_x:b.x-a.x y:b.y-a.y z:0];
    Vec3D dirv;
    
    if (self.ndir == -1) {
        dirv = [VecLib cross:[VecLib Z_VEC] with:v];
    } else {
        dirv = [VecLib cross:v with:[VecLib Z_VEC]];
    }
    
    dirv = [VecLib normalize:dirv];
    dirv = [VecLib scale:dirv by:BORDER_LINE_WIDTH];
    dirv = [VecLib scale:dirv by:scale];
    
    tri_pts[0] = a;
    tri_pts[1] = b;
    tri_pts[2] = fccp(a.x+dirv.x,a.y+dirv.y);
    tri_pts[3] = fccp(b.x+dirv.x,b.y+dirv.y);
    
    tex_pts[0] = fccp(0,0);
    tex_pts[1] = fccp(1,0);
    tex_pts[2] = fccp(0,1);
    tex_pts[3] = fccp(1,1);
    
    return n;
}

-(void)cons_bottom_line_fill {
    bottom_line_fill = [self line_from:bl to:br scale:1 n:bottom_line_fill];
}

-(void)cons_corner_line_fill {
    //if next is island, set force_draw_rightline
    if (self.next == NULL) {
        return;
    } else if (![self.next isKindOfClass:[LineIsland class]]){
        force_draw_rightline = YES;
        return;
    }
    
    LineIsland *n = (LineIsland*)self.next;
    corner_line_fill = [self line_from:br to:fccp(n.bl.x-self.startX+n.self.startX,n.bl.y-self.startY+n.self.startY) scale:1 n:corner_line_fill];
}

-(void)cons_left_line_fill {
    left_line_fill = [self line_from:tl to:bl scale:1 n:left_line_fill];
}

-(void)cons_right_line_fill {
    right_line_fill = [self line_from:tr to:br scale:-1 n:right_line_fill];
}

-(void)link_finish {
    if (self.next != NULL) {
        
        [self cons_corner_tex];
        [Common transform_obj:corner_fill by:[self position]];
        
        
        if (toppts_fill != NULL && toppts_fill.isalloc == 0) {
            [self cons_corner_top];
            [Common transform_obj:toppts_fill by:[self position]];
            toppts_fill.isalloc = 1;
        }
        
        [self cons_corner_line_fill];
        if (corner_line_fill != NULL) [Common transform_obj:corner_line_fill by:[self position]];
    }
    
    if (!has_transformed_renderpts) {
        has_transformed_renderpts = YES;
        [Common transform_obj:main_fill by:[self position]];
        [Common transform_obj:top_fill by:[self position]];
        [Common transform_obj:tl_top_corner by:[self position]];
        [Common transform_obj:tr_top_corner by:[self position]];
        [Common transform_obj:bottom_line_fill by:[self position]];
        [Common transform_obj:left_line_fill by:[self position]];
        [Common transform_obj:right_line_fill by:[self position]];
        
    }
    
}

-(void)cons_corner_top {
    //called from link_finish, position greenwedge
    
    Vec3D v3t2 = [VecLib cons_x:(self.next.endX - self.next.startX) y:(self.next.endY - self.next.startY) z:0];
    Vec3D vZ = [VecLib Z_VEC];
    Vec3D v3t1 = [VecLib cross:v3t2 with:vZ];
    //[v3t2 crossWith:vZ];
    v3t1 = [VecLib normalize:v3t1];
    v3t1 = [VecLib negate:v3t1];
    v3t1 = [self scale_ndir:v3t1];
    
    float offset = OFFSET;
    float d_o_x = offset * v3t1.x;
    float d_o_y = offset * v3t1.y;
    toppts_fill.tri_pts[2] = fccp( d_o_x+self.next.startX-self.startX ,d_o_y+self.next.startY-self.startY );
    
    float corner_top_scale = [self get_corner_top_fill_scale];
    
    /*cur 0  next
     1 2
     */
    //toppts[0,1] already set, set[2] and scale
    Vec3D reduce_left = [VecLib cons_x:toppts_fill.tri_pts[1].x-toppts_fill.tri_pts[0].x y:toppts_fill.tri_pts[1].y-toppts_fill.tri_pts[0].y z:0];
    reduce_left = [VecLib normalize:reduce_left];
    reduce_left = [VecLib scale:reduce_left by:corner_top_scale];
    toppts_fill.tri_pts[1] = fccp( toppts_fill.tri_pts[0].x + reduce_left.x, toppts_fill.tri_pts[0].y + reduce_left.y);
    
    Vec3D reduce_right = [VecLib cons_x:toppts_fill.tri_pts[2].x-toppts_fill.tri_pts[0].x y:toppts_fill.tri_pts[2].y-toppts_fill.tri_pts[0].y z:0];
    reduce_right = [VecLib normalize:reduce_right];
    reduce_right = [VecLib scale:reduce_right by:corner_top_scale];
    toppts_fill.tri_pts[2] = fccp( toppts_fill.tri_pts[0].x + reduce_right.x, toppts_fill.tri_pts[0].y + reduce_right.y);
    
    toppts_fill.tex_pts[0] = fccp(0,0);
    toppts_fill.tex_pts[1] = fccp(1,0);
    toppts_fill.tex_pts[2] = fccp(1,1);
}

-(void)cons_corner_tex {
    corner_fill = [Common cons_render_obj:[self get_tex_fill] npts:3 obj:corner_fill];
    
    fCGPoint* tri_pts = corner_fill.tri_pts;
    
    Vec3D v3t2 = [VecLib cons_x:(self.endX - self.startX) y:(self.endY - self.startY) z:0];
    Vec3D vZ = [VecLib Z_VEC];
    Vec3D v3t1 = [VecLib cross:v3t2 with:vZ];
    v3t1 = [VecLib normalize:v3t1];
    v3t1 = [self scale_ndir:v3t1];
    
    tri_pts[0] = fccp(self.endX-self.startX,self.endY-self.startY);
    tri_pts[1] = fccp(self.endX+v3t1.x*fill_hei-self.startX,self.endY+v3t1.y*fill_hei-self.startY);
    
    v3t2 = [VecLib cons_x:(self.next.endX - self.next.startX) y:(self.next.endY - self.next.startY) z:0];
    v3t1 = [VecLib cross:v3t2 with:vZ];
    v3t1 = [VecLib normalize:v3t1];
    v3t1 = [self scale_ndir:v3t1];
    tri_pts[2] = fccp(self.next.startX+v3t1.x*self.next.fill_hei-self.startX, self.next.startY+v3t1.y*self.next.fill_hei-self.startY);
    
    [self corner_fill_tex_map];
    /**
     main fill
     32
     10
     **/
    
    /**
     corner_fill:
        0
     cur12next
     **/
    corner_fill.tex_pts[0] = main_fill.tex_pts[2];
    corner_fill.tex_pts[1] = main_fill.tex_pts[0];
    corner_fill.tex_pts[2] = fccp(
        (corner_fill.tri_pts[2].x - corner_fill.tri_pts[1].x)/corner_fill.texture.pixelsWide + corner_fill.tex_pts[1].x,
        (corner_fill.tri_pts[2].y - corner_fill.tri_pts[1].y)/corner_fill.texture.pixelsHigh + corner_fill.tex_pts[1].y
    );
}

-(void)corner_fill_tex_map {
    for (int i = 2; i < 4; i++) {
        corner_fill.tex_pts[i] = fccp(( corner_fill.tri_pts[i].x+self.startX)/   corner_fill.texture.pixelsWide,
                                     ( corner_fill.tri_pts[i].y+self.startY)/   corner_fill.texture.pixelsHigh);
    }
}

-(GLRenderObject*)get_main_fill {
    return main_fill;
}


@end
