#import "IslandFill.h"
#import "GameEngineLayer.h"
#import "Island.h"

@implementation IslandFill
+(IslandFill*)cons_x:(float)x y:(float)y width:(float)width height:(float)height g:(GameEngineLayer*)g {
    IslandFill* n = [IslandFill node];
    n.active = YES;
    [n cons_x:x y:y width:width height:height g:g];
    
    return n;
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    if (has_lazy_setrenderord) {
        return;
    }
    HitRect hr = [self get_hit_rect];
    for (Island *i in g.islands) {
        if (!i.can_land && [Common hitrect_touch:hr b:[i get_hitrect]]) {
            [self.parent reorderChild:self z:[GameRenderImplementation GET_RENDER_ABOVE_FG_ORD]];
        }
    }
    has_lazy_setrenderord = YES;
}

-(CCTexture2D*)get_tex:(GameEngineLayer*)g {
	if (g.world_mode.cur_world == WorldNum_3) {
		return [Resource get_tex:TEX_BG3_ISLAND_FILL];
	}
    return [Resource get_tex:TEX_GROUND_TEX_1];
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_BTWN_PLAYER_ISLAND];
}
@end

@implementation LabFill

+(LabFill*)cons_x:(float)x y:(float)y width:(float)width height:(float)height g:(GameEngineLayer*)g {
    LabFill* n = [LabFill node];
    n.active = YES;
    [n cons_x:x y:y width:width height:height g:g];
    
    return n;
}

-(CCTexture2D*)get_tex:(GameEngineLayer *)g {
    return [Resource get_tex:TEX_LAB_GROUND_1];
}

@end
