#import "JumpPad.h"
#import "Player.h"
#import "GameEngineLayer.h"
#import "JumpParticle.h"

#define JUMP_POWER 20
#define RECHARGE_TIME 15

@implementation JumpPad

+(JumpPad*)cons_x:(float)x y:(float)y dirvec:(Vec3D )vec{
    JumpPad *j = [JumpPad node];
    j.position = ccp(x,y);
    [j cons_anim];
    
    [j set_dir:vec];
    
    [j setActive:YES];
    return j;
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:[self position].x-20 y1:[self position].y-20 wid:40 hei:40];
}

-(void)update:(Player*)player g:(GameEngineLayer *)g{
    [super update:player g:g];
	
	[body setVisible:g.world_mode.cur_mode == BGMode_LAB ? NO : YES];
	[labbody setVisible:g.world_mode.cur_mode == BGMode_LAB ? YES : NO];
	
    if (recharge_ct > 0) {
        recharge_ct--;
        if (recharge_ct == 0) {
            [self setOpacity:255];
            activated = NO;
        }
    }
    if(activated) {
        return;
    }
    
    if ([Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]) {		
        activated = YES;
        recharge_ct = RECHARGE_TIME;
        [self boostjump:player g:g];
        
        for(int i = 0; i < 8; i++) {
            float r = ((float)i);
            r = r/4.0 * M_PI;
            
            float dvx = cosf(r)*8+float_random(0, 1);
            float dvy = sinf(r)*8+float_random(0, 1);
            [g add_particle:[JumpPadParticle cons_x:[self position].x
                                                  y:[self position].y
                                                 vx:dvx
                                                 vy:dvy]];
        }
        [AudioManager playsfx:SFX_JUMPPAD];
		[GameControlImplementation set_nodash_time:10];
		
		[g shake_for:7 intensity:2];
		[g freeze_frame:4];
    }
}

-(void)reset {
    [super reset];
    activated = NO;
}

-(void)boostjump:(Player*)player g:(GameEngineLayer*)g {
    Vec3D jnormal = [VecLib cons_x:normal_vec.x y:normal_vec.y z:0];
    [player remove_temp_params:g];
    [[player get_current_params] add_airjump_count];
    
    /*
    float ang = [jnormal get_angle_in_rad];
    if (ABS(ang) > M_PI * (3/4)) {
        player.last_ndir = -1;
    }*/
	if ([labbody visible]) {
		[labbody stopAllActions];
		[labbody runAction:labanim];
	} else {
		[body stopAllActions];
		[body runAction:anim];
	}
    
    jnormal=[VecLib normalize:jnormal];
    jnormal=[VecLib scale:jnormal by:2];
    
    player.current_island = NULL;
    player.position = [VecLib transform_pt:player.position by:jnormal];
    
    
    jnormal = [VecLib normalize:jnormal ];
    jnormal = [VecLib scale:jnormal by:JUMP_POWER];
    
    player.vx = jnormal.x;
    player.vy = jnormal.y;
    
    
    
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_BTWN_PLAYER_ISLAND];
}

-(void)cons_anim {
    anim = [self make_anim_ofspeed:0.1];
	labanim = [self lab_make_anim_ofspeed:0.1];
    
    body = [CCSprite node];
    [body runAction:[self make_stand]];
    [body setScale:1];
    [body setAnchorPoint:ccp(0.5,0.5)];
    [self addChild:body];
	
	labbody = [CCSprite node];
	[labbody runAction:[self lab_make_stand]];
	[labbody setScale:2];
	[labbody setAnchorPoint:ccp(0.5,0.5)];
	[self addChild:labbody];
}

-(CCAction*)make_stand {
    return [JumpPad make_anim_frames:
            [NSMutableArray arrayWithObject:
             [CCSpriteFrame frameWithTexture:[Resource get_tex:TEX_JUMPPAD]
                                        rect:[JumpPad spritesheet_rect_tar:@"jumppad1"]]] speed:10];
}

-(id)make_anim_ofspeed:(float)speed {
	CCTexture2D *texture = [Resource get_tex:TEX_JUMPPAD];
	NSMutableArray *animFrames = [NSMutableArray array];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[JumpPad spritesheet_rect_tar:@"jumppad2"]]];
	[animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[JumpPad spritesheet_rect_tar:@"jumppad3"]]];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[JumpPad spritesheet_rect_tar:@"jumppad1"]]];
    return [JumpPad make_anim_frames:animFrames speed:speed];
}

-(CCAction*)lab_make_stand {
    return [JumpPad make_anim_frames:
            [NSMutableArray arrayWithObject:
             [CCSpriteFrame frameWithTexture:[Resource get_tex:TEX_JUMPPAD]
                                        rect:[JumpPad spritesheet_rect_tar:@"labjumppad1"]]] speed:10];
}

-(id)lab_make_anim_ofspeed:(float)speed {
	CCTexture2D *texture = [Resource get_tex:TEX_JUMPPAD];
	NSMutableArray *animFrames = [NSMutableArray array];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[JumpPad spritesheet_rect_tar:@"labjumppad2"]]];
	[animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[JumpPad spritesheet_rect_tar:@"labjumppad3"]]];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[JumpPad spritesheet_rect_tar:@"labjumppad1"]]];
    return [JumpPad make_anim_frames:animFrames speed:speed];
}



+(CCAction*)make_anim_frames:(NSMutableArray*)animFrames speed:(float)speed {
	id animate = [CCAnimate actionWithAnimation:[CCAnimation animationWithFrames:animFrames delay:speed] restoreOriginalFrame:NO];
	return animate;
}

+(CGRect)spritesheet_rect_tar:(NSString*)tar {
    return [FileCache get_cgrect_from_plist:TEX_JUMPPAD idname:tar];
}

-(void)set_dir:(Vec3D)vec {
    normal_vec = [VecLib cons_x:vec.x y:vec.y z:0];
    
    Vec3D tangent = [VecLib cross:vec with:[VecLib Z_VEC]];
    float tar_rad = -[VecLib get_angle_in_rad:tangent];
    //rotation_ = [Common rad_to_deg:tar_rad];
	[self setRotation:[Common rad_to_deg:tar_rad]];
}

-(void)dealloc {
    [self stopAllActions];
}

@end
