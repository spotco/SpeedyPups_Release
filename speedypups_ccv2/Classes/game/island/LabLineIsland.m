#import "LabLineIsland.h"
#import "BatchDraw.h"

@implementation LabLineIsland

@synthesize shift_mainfill;

#define OVERALL_OFFSET_Y 0.1

+(LabLineIsland*)cons_pt1:(CGPoint)start pt2:(CGPoint)end height:(float)height ndir:(float)ndir can_land:(BOOL)can_land {
	LabLineIsland *new_island = [LabLineIsland node];
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
-(CCTexture2D*)get_corner_fill_color {
    return [Resource get_tex:TEX_LAB_GROUND_CORNER];
}

-(CCTexture2D*)get_tex_corner {
    return [Resource get_tex:TEX_LAB_GROUND_TOP_EDGE];
}
-(CCTexture2D*)get_tex_top {
    return [Resource get_tex:TEX_LAB_GROUND_TOP];
}
-(CCTexture2D*)get_tex_fill {
	return [Resource get_tex:TEX_LAB_GROUND_1];
    
}

@end
