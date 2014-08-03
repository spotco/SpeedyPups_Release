#import "Island.h"
#import "Common.h"
#import "Vec3D.h"
#import "Resource.h"



@interface LineIsland : Island {
    BOOL do_draw;
    
	GLRenderObject *main_fill, //main body texture fill
                  *top_fill, //top grass decoration fill
                  *corner_fill; //wedge main body texture between cur and next (optional)
    
    GLRenderObject *tl_top_corner, //left top decoration rounded edge (optional)
                  *tr_top_corner; //right top decoration rounded edge (optional)
    
    GLRenderObject *bottom_line_fill, //bottom border line
                  *corner_line_fill, //border line between cur and next (optional)
                  *left_line_fill, //left border line (optional)
                  *right_line_fill, //right border line (optional)
                  *toppts_fill; //corner wedge decoration between cur and next (optional)
    
    HitRect cache_hitrect;
    
    BOOL has_gen_hitrect;
    BOOL has_transformed_renderpts;
	
	GameEngineLayer* __unsafe_unretained gameengine;
}

@property(readwrite,assign) fCGPoint tl,bl,tr,br;
@property(readwrite,assign) BOOL force_draw_leftline,force_draw_rightline;

+(LineIsland*)cons_pt1:(CGPoint)start pt2:(CGPoint)end height:(float)height ndir:(float)ndir can_land:(BOOL)can_land g:(GameEngineLayer*)g;

-(void)calc_init;
-(void)cons_tex;
-(void)cons_top;

-(CCTexture2D*)get_tex_fill;
-(CCTexture2D*)get_tex_corner;
-(CCTexture2D*)get_tex_border;
-(CCTexture2D*)get_tex_top;
-(CCTexture2D*)get_corner_fill_color;
-(float)get_corner_top_fill_scale;

-(void)main_fill_tex_map;
-(void)corner_fill_tex_map;

-(GLRenderObject*)get_main_fill;

@end
