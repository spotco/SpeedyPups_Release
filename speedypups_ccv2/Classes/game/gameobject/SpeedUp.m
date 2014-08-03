#import "SpeedUp.h"
#import "GameEngineLayer.h"

@implementation SpeedUp

+(SpeedUp*)cons_x:(float)x y:(float)y dirvec:(Vec3D)vec{
    SpeedUp *s = [SpeedUp node];
    s.position = ccp(x,y);
    [s cons_anim];
    [s set_dir:vec];
    [s setActive:YES];
    
    return s;
}

-(HitRect)get_hit_rect {
     return [Common hitrect_cons_x1:[self position].x-30 y1:[self position].y-30 wid:60 hei:60];
}

-(void)update:(Player*)player g:(GameEngineLayer *)g{
    [super update:player g:g];
    
    if (recharge_ct > 0) {
        recharge_ct--;
        if (self.opacity != 170)[self setOpacity:170];
    } else {
        if (self.opacity != 255)[self setOpacity:255];
    }
    
    if (recharge_ct == 0 && [Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]) {
        [self particle_effect:g];
        player.vx += normal_vec.x*2;
        player.vy += normal_vec.y*2;
        [player set_new_spd:15 ct:100];
        recharge_ct = 50;
        [AudioManager playsfx:SFX_SPEEDUP];
    }
}

-(void)particle_effect:(GameEngineLayer*)g {
    for(int i = 0; i < 6; i++) {
        float spd = float_random(4, 10);
        [g add_particle:[JumpPadParticle cons_x:[self position].x
                                              y:[self position].y
                                             vx:-normal_vec.x*spd+float_random(-5, 5)
                                             vy:-normal_vec.y*spd+float_random(-10, 10)]];
    }
}

-(void)set_active:(BOOL)t_active {
    active = t_active;
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_ISLAND_ORD];
}

-(void)cons_anim {
    anim = [self cons_anim_ofspeed:0.2];
    [self runAction:anim];
}

-(id)cons_anim_ofspeed:(float)speed {
	CCTexture2D *texture = [Resource get_tex:TEX_SPEEDUP];
	NSMutableArray *animFrames = [NSMutableArray array];
    
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[SpeedUp spritesheet_rect_tar:@"speedup3"]]];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[SpeedUp spritesheet_rect_tar:@"speedup2"]]];
	[animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[SpeedUp spritesheet_rect_tar:@"speedup1"]]];
    
    return [SpeedUp make_anim_frames:animFrames speed:speed];
}



+(id)make_anim_frames:(NSMutableArray*)animFrames speed:(float)speed {
	id animate = [CCAnimate actionWithAnimation:[CCAnimation animationWithFrames:animFrames delay:speed] restoreOriginalFrame:YES];
    id m = [CCRepeatForever actionWithAction:animate];
    
	return m;
}

+(CGRect)spritesheet_rect_tar:(NSString*)tar {
    return [FileCache get_cgrect_from_plist:TEX_SPEEDUP idname:tar];
}

-(void)set_dir:(Vec3D)vec {
    normal_vec = [VecLib cons_x:vec.x y:vec.y z:0];
    Vec3D tangent = [VecLib cross:vec with:[VecLib Z_VEC]];
    float tar_rad = -[VecLib get_angle_in_rad:tangent] - M_PI/2;
    //rotation_ = [Common rad_to_deg:tar_rad];
	[self setRotation:[Common rad_to_deg:tar_rad]];
}

@end
