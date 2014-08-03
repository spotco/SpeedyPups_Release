#import "Spike.h"
#import "Island.h"
#import "GameEngineLayer.h"
#import "BreakableWallRockParticle.h"

@implementation Spike
@synthesize img;

+(Spike*)cons_x:(float)posx y:(float)posy islands:(NSMutableArray*)islands {
    Spike *s = [Spike node];
    s.position = ccp(posx,posy);
    s.active = YES;
    
    CCTexture2D *tex = [Resource get_tex:TEX_SPIKE];
    s.img = [CCSprite spriteWithTexture:tex];
    [s attach_toisland:islands];
    [s addChild:s.img];
    return s;
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_BTWN_PLAYER_ISLAND];
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:[self position].x-10 y1:[self position].y-10 wid:20 hei:20];
}

-(void)set_active:(BOOL)t_active {
    active = t_active;
}

-(void)update:(Player*)player g:(GameEngineLayer *)g {
    [super update:player g:g];
	[self csf_setScale:self.csf_scale+(1-self.csf_scale)/4];
    if(activated) {
        return;
    }
    
    if ([Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]) {
		if ([player is_armored]) {
			activated = YES;
			[img setVisible:NO];
			for (float i = M_PI*0.1; i < M_PI*0.9; i+=M_PI/12) {
				CGPoint vel = ccp(cosf(i),sinf(i));
				float scale = float_random(2, 8);
				[g add_particle:[BreakableWallRockParticle cons_spike_x:[self position].x y:[self position].y vx:vel.x*scale vy:vel.y*scale]];
			}
			[AudioManager playsfx:SFX_SPIKEBREAK];
			
			[g freeze_frame:6];
			[g shake_for:10 intensity:4];
			
			
		} else if (!player.dead && ![player is_armored]) {
			[player reset_params];
			player.current_swingvine = NULL;
			activated = YES;
			[player add_effect:[HitEffect cons_from:[player get_default_params] time:40]];
			[DazedParticle cons_effect:g tar:player time:40];
			[AudioManager playsfx:SFX_HIT];
			[g.get_stats increment:GEStat_SPIKES];
			[self csf_setScale:2];
			
			[g freeze_frame:6];
			[g shake_for:15 intensity:6];
			
		}
		
        //[DazedParticle cons_effect:g x:player.position.x y:player.position.y+60*(player.current_island != NULL?player.last_ndir:1) time:40];
    }
    
    return;
}

-(void)reset {
    [super reset];
    activated = NO;
	[img setVisible:YES];
}

-(void)attach_toisland:(NSMutableArray*)islands {
    Island* i = [self get_connecting_island:islands];
    if (i != NULL) {
        Vec3D tangent_vec = [i get_tangent_vec];
        tangent_vec = [VecLib scale:tangent_vec by:[i ndir]];
        float tar_rad = -[VecLib get_angle_in_rad:tangent_vec];
        float tar_deg = [Common rad_to_deg:tar_rad];
        img.rotation = tar_deg;
        
        tangent_vec = [VecLib normalize:tangent_vec ];
        Vec3D normal_vec = [VecLib cross:[VecLib Z_VEC] with:tangent_vec];
        normal_vec = [VecLib scale:normal_vec by:15/CC_CONTENT_SCALE_FACTOR()];
        img.position = ccp(normal_vec.x,normal_vec.y);
        
    }
}

@end
