#import "GameRenderImplementation.h"
#import "GameEngineLayer.h"
#import "DogRocketEffect.h"

#define RENDER_PLAYER_ON_FG_ORD 9
#define RENDER_ABOVE_FG_ORD 8
#define RENDER_FG_ISLAND_ORD 7
#define RENDER_PLAYER_ORD 6
#define RENDER_PLAYER_SHADOW_ORD 5
#define RENDER_BTWN_ISLAND_PLAYER 4
#define RENDER_ISLAND_ORD 3
#define RENDER_GAMEOBJ_ORD 2
#define RENDER_BEHIND_GAMEOBJ_ORD 1
#define VERT_CAMERA_OFFSET_SPD 65

@implementation GameRenderImplementation

+(void)update_render_on:(GameEngineLayer*)layer {
    Player* player = layer.player;
    
    [GameRenderImplementation update_zoom:layer];
    
    BOOL player_on_fg_island = (player.current_island != NULL) && (!player.current_island.can_land);
    if (player_on_fg_island) {
        if (player.zOrder != RENDER_PLAYER_ON_FG_ORD) {
            [layer reorderChild:player z:RENDER_PLAYER_ON_FG_ORD];
        }
    } else {
        if (player.zOrder != RENDER_PLAYER_ORD) {
            [layer reorderChild:player z:RENDER_PLAYER_ORD];
        }
    }
}

+(float)calc_g_dist:(Player*)player islands:(NSMutableArray*)islands {
    if (player.current_island != NULL) {
        return 0;
    }
    
    float max = INFINITY;
    CGPoint pos = player.position;
    for (Island* i in islands) {
        float ipos = [i get_height:pos.x];
        if (ipos != [Island NO_VALUE] && pos.y > ipos) {
            max = MIN(max,pos.y - ipos);
        }
    }
    return max;
}

#define INIT_X 120
#define INIT_Y 110
#define INIT_Z 160

+(void)reset_camera:(CameraZoom*)c {    
    CameraZoom t = [Common cons_normalcoord_camera_zoom_x:INIT_X y:INIT_Y z:INIT_Z];
    c->x = t.x;
    c->y = t.y;
    c->z = t.z;
}

#define ZOOMSPD 50.0

//480x320
//rocket target {"x": 120, "z": 276, "y": 110}
+(void)update_zoom:(GameEngineLayer*)layer {
    float g_dist = [GameRenderImplementation calc_g_dist:layer.player islands:layer.islands];
    CameraZoom state = layer.camera_state;
    CameraZoom target = layer.tar_camera_state;
	
	if ([[layer.player get_current_params] class] == [DogRocketEffect class]) {
		target = [Common cons_normalcoord_camera_zoom_x:50 y:150 z:350];
	}
	
	if (![Common fuzzyeq_a:layer.camera_state.x b:target.x delta:0.1]) {
		state.x += (target.x - layer.camera_state.x)/ZOOMSPD;
	}
	
	if (![Common fuzzyeq_a:layer.camera_state.y b:target.y delta:0.1]) {
		state.y += (target.y - layer.camera_state.y)/ZOOMSPD;
	}
	
	if (![Common fuzzyeq_a:layer.camera_state.z b:target.z delta:0.1]) {
		state.z += (target.z - layer.camera_state.z)/(ZOOMSPD/4);
	}
	
	float YDIR_DEFAULT = layer.tar_camera_state.y;
	if ([layer get_follow_clamp_y_range].max == INFINITY) {
		
		if (g_dist > 5) {
			float tmp = g_dist > 400.0 ? 400.0 : g_dist;
			float tar_yoff = 30.0 + (tmp / 400.0)*40.0;
			state.y = drp(state.y, YDIR_DEFAULT+tar_yoff, ZOOMSPD);
			
		} else {
			state.y = drp(state.y, YDIR_DEFAULT, ZOOMSPD);
		}
	}
	
	layer.camera_state = state;
	[GameRenderImplementation update_camera_on:layer zoom:layer.camera_state];
}

+(void)update_camera_on:(GameEngineLayer*)layer zoom:(CameraZoom)state {
	float scfx = [Common SCREEN].width / 480.0;
	float scfy = [Common SCREEN].height / 320.0;
	CGPoint fg_offset = ccp(-25 * (CC_CONTENT_SCALE_FACTOR()-1),-10 * (CC_CONTENT_SCALE_FACTOR()-1));
	// (160,0.6) and (300,0.4)
	[layer set_layer_camera_x:scfx * state.x - 480.0/2 + fg_offset.x y:scfy * state.y - 320.0/2 + fg_offset.y z:0.828571-0.00142857*state.z];
}

+(int)GET_RENDER_FG_ISLAND_ORD { return RENDER_FG_ISLAND_ORD; }
+(int)GET_RENDER_PLAYER_ORD { return RENDER_PLAYER_ORD; }
+(int)GET_RENDER_ISLAND_ORD { return RENDER_ISLAND_ORD; }
+(int)GET_RENDER_GAMEOBJ_ORD { return RENDER_GAMEOBJ_ORD; }
+(int)GET_RENDER_BTWN_PLAYER_ISLAND { return RENDER_BTWN_ISLAND_PLAYER; }
+(int)GET_BEHIND_GAMEOBJ_ORD { return RENDER_BEHIND_GAMEOBJ_ORD; }

+(int)GET_RENDER_PLAYER_ON_FG_ORD { return RENDER_PLAYER_ON_FG_ORD; }
+(int)GET_RENDER_ABOVE_FG_ORD { return RENDER_ABOVE_FG_ORD; }
+(int)GET_RENDER_PLAYER_SHADOW_ORD { return RENDER_PLAYER_SHADOW_ORD; }

@end
