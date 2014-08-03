#import "Water.h"
#import "AudioManager.h" 
#import "GameEngineLayer.h" 

#define ANIM_SPEED 0.0025
#define OFFSET_V 10
#define FILL_COLOR 18, 64, 100

@implementation Water

+(Water*)cons_x:(float)x y:(float)y width:(float)width height:(float)height {
    Water *w = [Water node];
    w.position = ccp(x,y);
    [w cons_body_ofwidth:width height:height];
    
    return w;
}

-(id)init {
	self = [super init];
	[self csf_setScale:1/CC_CONTENT_SCALE_FACTOR()];
	return self;
}

-(CGPoint)get_size {
	return ccp(bwidth,bheight);
}

-(void)cons_body_ofwidth:(float)width height:(float)height {
    
    bwidth = width;
    bheight = height;
    body = [self cons_drawbody_ofwidth:width];
	body_offset = [[GLRenderObject alloc] init];
	body_offset.texture = body.texture;
	body_offset.isalloc = body.isalloc;
	body_offset.pts = body.pts;
	for (int i = 0; i < body.pts; i++) {
		body_offset.tri_pts[i] = body.tri_pts[i];
	}
	
	[self update_body_tex_offset];
	
    offset_ct = 0;
    [self update_body_tex_offset];
    
    active = YES;
    activated = NO;
    
    CCSprite *fillsprite = [CCSprite spriteWithTexture:[Resource get_tex:TEX_BLANK]];
    fillsprite.anchorPoint = ccp(0,0);
    fillsprite.color = ccc3(FILL_COLOR);
    [fillsprite setTextureRect:CGRectMake(0, 0, bwidth, bheight)];
    [self addChild:fillsprite z:-1];
    
    fishes = [FishGenerator cons_ofwidth:bwidth basehei:bheight];
    [self addChild:fishes z:-2];
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    [super update:player g:g];
    [fishes update];
    [self update_body_tex_offset];
    if(activated) {
        return;
    }
    
    if ([Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]] && !player.dead) {
        [player reset_params];
        activated = YES;
        [player add_effect:[SplashEffect cons_from:[player get_default_params] time:40]];
        [AudioManager playsfx:SFX_SPLASH];
        [g.get_stats increment:GEStat_DROWNED];
        
    } else if ([player get_current_params].noclip &&
               [player get_current_params].noclip < 2 &&
               [Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect_ignore_noclip]]) {
        activated = YES;
        [player add_effect_suppress_current_end_effect:[SplashEffect cons_from:[player get_default_params] time:40]];
        [g.get_stats increment:GEStat_DROWNED];
        
    }
    
    return;
}

-(void)reset {
    [super reset];
    activated = NO;
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:self.position.x 
                                y1:self.position.y
                               wid:bwidth 
                               hei:bheight];
}

-(void)update_body_tex_offset {
    body_offset.tex_pts[0] = fccp(body.tex_pts[0].x+offset_ct, body.tex_pts[0].y);
    body_offset.tex_pts[1] = fccp(body.tex_pts[1].x+offset_ct, body.tex_pts[1].y);
    body_offset.tex_pts[2] = fccp(body.tex_pts[2].x+offset_ct, body.tex_pts[2].y);
    body_offset.tex_pts[3] = fccp(body.tex_pts[3].x+offset_ct, body.tex_pts[3].y);
    offset_ct = offset_ct >= 1 ? ANIM_SPEED : offset_ct + ANIM_SPEED * [Common get_dt_Scale];
}

/*0 1
  2 3*/
-(GLRenderObject*)cons_drawbody_ofwidth:(float)width {
    
    GLRenderObject* o = [Common neu_cons_render_obj:[Resource get_tex:TEX_WATER] npts:4];
    
	ccTexParams texParams = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_CLAMP_TO_EDGE };
	[o.texture setTexParameters:&texParams];
	
    int twid = (int)o.texture.pixelsWide;
    int thei = (int)o.texture.pixelsHigh;
    
    o.tri_pts[0] = fccp(0,bheight - thei + OFFSET_V);
    o.tri_pts[1] = fccp(width,bheight -thei + OFFSET_V);
    o.tri_pts[2] = fccp(0,bheight + OFFSET_V);
    o.tri_pts[3] = fccp(width,bheight + OFFSET_V);
    
    o.tex_pts[0] = fccp(0,1);
    o.tex_pts[1] = fccp(o.tri_pts[1].x/twid,1);
    o.tex_pts[2] = fccp(0,0.035);
    o.tex_pts[3] = fccp(o.tri_pts[3].x/twid,0.035);
    
    return o;

}

-(void) draw {
    [super draw];
    if (do_render) {
        [Common draw_renderobj:body_offset n_vtx:4];
    }
}



-(void)dealloc {
    [self removeAllChildrenWithCleanup:YES];
}



@end
