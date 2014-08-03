#import "SpikeVine.h"
#import "AudioManager.h"
#import "GameEngineLayer.h" 
#import "BreakableWallRockParticle.h"

@implementation SpikeVine

#define BASE_IMG_WID 56.0
#define BASE_IMG_HEI 27.0
#define CENTER_IMG_WID 56.0
#define CENTER_IMG_HEI 128.0

+(SpikeVine*)cons_x:(float)x y:(float)y x2:(float)x2 y2:(float)y2 {
    SpikeVine *n = [SpikeVine node];
    [n cons_x:x y:y x2:x2 y2:y2];
    return n;
}

-(id)init {
	self = [super init];
	[self csf_setScale:1/CC_CONTENT_SCALE_FACTOR()];
	return self;
}

-(void)cons_x:(float)x y:(float)y x2:(float)x2 y2:(float)y2 {
    [self setPosition:ccp(x,y)];
    dir_vec = [VecLib cons_x:x2-x y:y2-y z:0];
    [self cons_img];
    [self setActive:YES];
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    [super update:player g:g];
    if(activated) {
        return;
    }
    
    if ([Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]] && !player.dead) {
		
		if ([player is_armored] && [self class] == [SpikeVine class]) {
			float len = [VecLib length:dir_vec];
			for(float i = 0; i < len; i+=float_random(8, 30)) {
				[g add_particle:
				 [BreakableWallRockParticle cons_spike_x:[self position].x + (i/len)*dir_vec.x
												 y:[self position].y + (i/len)*dir_vec.y
												vx:float_random(-5, 5)
												vy:float_random(-5, 5)]
				 ];
				
			}
			[g freeze_frame:6];
			[g shake_for:10 intensity:4];
			[AudioManager playsfx:SFX_SPIKEBREAK];
			activated = YES;
			stop_draw = YES;
			return;
		}
		
		
        HitRect player_small_rect = [player get_hit_rect]; //watahack :DDD
        float pwid = player_small_rect.x2-player_small_rect.x1;
        float phei = player_small_rect.y2-player_small_rect.y1;
        player_small_rect.x1+=pwid*0.25;
        player_small_rect.x2-=pwid*0.25;
        player_small_rect.y1+=phei*0.25;
        player_small_rect.y2-=phei*0.25;
        
        SATPoly r_playerhit = [PolyLib hitrect_to_poly:player_small_rect];
        for(int i = 0; i < r_hitbox.length; i++) {
            r_hitbox.pts[i].x += [self position].x;
            r_hitbox.pts[i].y += [self position].y;
        }
        if ([PolyLib poly_intersect_SAT:r_hitbox b:r_playerhit]) {
            [self hit:player g:g];
        }
        for(int i = 0; i < r_hitbox.length; i++) {
            r_hitbox.pts[i].x -= [self position].x;
            r_hitbox.pts[i].y -= [self position].y;
        }
    }
    
    return;
}

-(void)hit:(Player *)player g:(GameEngineLayer *)g {
    if (![player is_armored]) {
        [player reset_params];
        player.current_swingvine = NULL;
        activated = YES;
        [player add_effect:[HitEffect cons_from:[player get_default_params] time:40 nograv:YES]];
        [DazedParticle cons_effect:g tar:player time:40];
        [AudioManager playsfx:SFX_HIT];
        [g.get_stats increment:GEStat_SPIKES];
		[g freeze_frame:6];
		[g shake_for:15 intensity:6];
    }
}

-(void)reset {
    [super reset];
    activated = NO;
	stop_draw = NO;
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
	
	ccTexParams texParams = {GL_LINEAR, GL_LINEAR, GL_CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE };
	[tex setTexParameters:&texParams];
	
    CGSize s = [self get_base_size];
    float bwid = [tex pixelsWide]; 
    float bhei = [tex pixelsHigh];
    
    Vec3D normal = [VecLib cross:dir_vec with:[VecLib Z_VEC]];
    normal = [VecLib normalize:normal];
    normal = [VecLib scale:normal by:[self get_section_size].width/2];
	
	normal = [VecLib cross:dir_vec with:[VecLib Z_VEC]];
    normal = [VecLib normalize:normal];
    normal = [VecLib scale:normal by:[self get_base_size].width/2];
    
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
    bottom.tex_pts[2] = fccp(0,0.985);
    bottom.tex_pts[3] = fccp(1,0.985);
    
    top = [Common neu_cons_render_obj:tex npts:4];
    top.tri_pts[0] = fccp(-normal.x + dir_vec.x - r_dirv.x              , -normal.y + dir_vec.y - r_dirv.y );
    top.tri_pts[1] = fccp(normal.x  + dir_vec.x - r_dirv.x             , normal.y + dir_vec.y - r_dirv.y);
    top.tri_pts[2] = fccp(-normal.x  + dir_vec.x   ,  -normal.y  + dir_vec.y);
    top.tri_pts[3] = fccp(normal.x  + dir_vec.x    , normal.y  + dir_vec.y);
    
    top.tex_pts[2] = fccp(0,0);
    top.tex_pts[3] = fccp(1,0);
    top.tex_pts[0] = fccp(0,0.985);
    top.tex_pts[1] = fccp(1,0.985);
    
    
    tex = [self get_section_tex];
    s = [self get_section_size];
    bwid = [tex pixelsWide];
    bhei = [tex pixelsHigh];
    normal=[VecLib normalize:normal];
    normal=[VecLib scale:normal by:[self get_section_size].width/2];
    
    center = [Common neu_cons_render_obj:tex npts:4];
    
    center.tri_pts[0] = fccp(-normal.x            ,-normal.y);
    center.tri_pts[1] = fccp(normal.x             ,normal.y);
    center.tri_pts[2] = fccp(-normal.x + dir_vec.x , -normal.y + dir_vec.y);
    center.tri_pts[3] = fccp(normal.x + dir_vec.x  ,normal.y + dir_vec.y);
    
    float len = [VecLib length:dir_vec];
    
    center.tex_pts[0] = fccp(0,0);
    center.tex_pts[1] = fccp(1,0);
    center.tex_pts[2] = fccp(0, (len/s.height) * s.height/bhei);
    center.tex_pts[3] = fccp(1,  (len/s.height) * s.height/bhei);
    
    
    r_hitbox = [PolyLib cons_SATPoly_quad:ccp(center.tri_pts[0].x, center.tri_pts[0].y)
                                        b:ccp(center.tri_pts[1].x, center.tri_pts[1].y)
                                        c:ccp(center.tri_pts[3].x, center.tri_pts[3].y)
                                        d:ccp(center.tri_pts[2].x, center.tri_pts[2].y)];
    
}

-(void)draw {
    [super draw];
    //glColor4ub(0,255,0,100);
    //ccDrawLine(ccp(0,0), ccp(dir_vec.x,dir_vec.y));
    [self draw_o];
}

-(void)draw_o {
	if (stop_draw) return;
    [Common draw_renderobj:top n_vtx:4];
    [Common draw_renderobj:bottom n_vtx:4];
    [Common draw_renderobj:center n_vtx:4];
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_BTWN_PLAYER_ISLAND];
}


-(HitRect)get_hit_rect {
    float x_max = -INFINITY;
    float x_min = INFINITY;
    float y_max = -INFINITY;
    float y_min = INFINITY;
    
    fCGPoint *l = top.tri_pts;
    for (int i = 0; i < 4; i++) {
        x_min = MIN(x_min,l[i].x);
        x_max = MAX(x_max,l[i].x);
        y_min = MIN(y_min,l[i].y);
        y_max = MAX(y_max,l[i].y);
    }
    
    l = bottom.tri_pts;
    for (int i = 0; i < 4; i++) {
        x_min = MIN(x_min,l[i].x);
        x_max = MAX(x_max,l[i].x);
        y_min = MIN(y_min,l[i].y);
        y_max = MAX(y_max,l[i].y);
    }
    
    return [Common hitrect_cons_x1:x_min+[self position].x y1:y_min+[self position].y x2:x_max+[self position].x y2:y_max+[self position].y];
}



@end
