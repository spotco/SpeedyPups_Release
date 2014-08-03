#import "BreakableWall.h"
#import "GameEngineLayer.h"
#import "ScoreManager.h"

@implementation BreakableWall

#define BASE_IMG_WID 82.0
#define BASE_IMG_HEI 32.0

#define CENTER_IMG_WID 82.0
#define CENTER_IMG_HEI 128.0

+(BreakableWall*)cons_x:(float)x y:(float)y x2:(float)x2 y2:(float)y2 {
    BreakableWall *n = [BreakableWall node];
    [n cons_x:x y:y x2:x2 y2:y2];
    return n;
}

-(void)cons_x:(float)x y:(float)y x2:(float)x2 y2:(float)y2 {
    [super cons_x:x y:y x2:x2 y2:y2];
    broken = NO;
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
	if (g.world_mode.cur_mode == BGMode_LAB) {
		top.texture = [Resource get_tex:TEX_LAB_ROCKWALL_BASE];
		bottom.texture = [Resource get_tex:TEX_LAB_ROCKWALL_BASE];
		center.texture = [Resource get_tex:TEX_LAB_ROCKWALL_SECTION];
		
	} else {
		top.texture = [Resource get_tex:TEX_CAVE_ROCKWALL_BASE];
		bottom.texture = [Resource get_tex:TEX_CAVE_ROCKWALL_BASE];
		center.texture = [Resource get_tex:TEX_CAVE_ROCKWALL_SECTION];
		
	}
	
	[super update:player g:g];
}

-(void)hit:(Player *)player g:(GameEngineLayer *)g {
    if (player.dashing || [player is_armored]) {
		[g.score increment_multiplier:0.01];
		[g.score increment_score:20];
        activated = YES;
        broken = YES;
        
        float len = [VecLib length:dir_vec];
        for(float i = 0; i < len; i+=float_random(8, 30)) {
			if (g.world_mode.cur_mode == BGMode_LAB) {
				[g add_particle:
					[BreakableWallRockParticle cons_lab_x:[self position].x + (i/len)*dir_vec.x
													y:[self position].y + (i/len)*dir_vec.y
												   vx:float_random(-5, 5) 
												   vy:float_random(-5, 5)]
				];
			} else {
				[g add_particle:
					[BreakableWallRockParticle cons_x:[self position].x + (i/len)*dir_vec.x
													y:[self position].y + (i/len)*dir_vec.y
												   vx:float_random(-5, 5) 
												   vy:float_random(-5, 5)]
				];
			}
        }
        [AudioManager playsfx:SFX_ROCKBREAK];
		[g shake_for:7 intensity:2];
        
    } else {
        [player reset_params];
        player.current_swingvine = NULL;
        activated = YES;
        [player add_effect:[HitEffect cons_from:[player get_default_params] time:40]];
        [DazedParticle cons_effect:g tar:player time:40];
        [AudioManager playsfx:SFX_HIT];
		[g shake_for:15 intensity:6];
    }
	
	[g freeze_frame:6];
}

-(void)reset {
    [super reset];
    broken = NO;
}

-(void)draw_o {
    [Common draw_renderobj:top n_vtx:4];
    [Common draw_renderobj:bottom n_vtx:4];
    if (broken == NO) {
        [Common draw_renderobj:center n_vtx:4];
    }
}

-(CCTexture2D*)get_base_tex {
    return [Resource get_tex:TEX_CAVE_ROCKWALL_BASE];
}

-(CCTexture2D*)get_section_tex {
    return [Resource get_tex:TEX_CAVE_ROCKWALL_SECTION];
}

-(CGSize)get_base_size {
    return CGSizeMake(BASE_IMG_WID, BASE_IMG_HEI);
}

-(CGSize)get_section_size {
    return CGSizeMake(CENTER_IMG_WID, CENTER_IMG_HEI);
}

@end
