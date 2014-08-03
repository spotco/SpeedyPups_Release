
#import "CaveLineIsland.h"

@implementation CaveLineIsland

+(CaveLineIsland*)cons_pt1:(CGPoint)start pt2:(CGPoint)end height:(float)height ndir:(float)ndir can_land:(BOOL)can_land {
	CaveLineIsland *new_island = [CaveLineIsland node];
    new_island.fill_hei = height;
    new_island.ndir = ndir;
	[new_island set_pt1:start pt2:end];
	[new_island calc_init];
	new_island.anchorPoint = ccp(0,0);
	new_island.position = ccp(new_island.startX,new_island.startY);
    new_island.can_land = can_land;
	[new_island cons_tex];
	[new_island cons_top];
	return new_island;
}

-(CCTexture2D*)get_tex_corner {
    return [Resource get_tex:TEX_GROUND_CORNER_TEX_1];
	//return [Resource get_tex:TEX_CAVE_CORNER_TEX];
}
-(CCTexture2D*)get_tex_top {
    return [Resource get_tex:TEX_GROUND_TOP_1];
	//return [Resource get_tex:TEX_CAVE_TOP_TEX];
}

@end
