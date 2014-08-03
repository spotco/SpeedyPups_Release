#import "Lab1BGLayerSet.h"

@implementation Lab1BGLayerSet
+(Lab1BGLayerSet*)cons {
	Lab1BGLayerSet *rtv = [Lab1BGLayerSet node];
	return [rtv cons];
}

-(Lab1BGLayerSet*)cons {
	bg_objects = [NSMutableArray array];
	
	[bg_objects addObject:[LabBGObject cons]];
	[bg_objects addObject:[[BackgroundObject backgroundFromTex:[Resource get_tex:TEX_LAB_BG_LAYER]
										  scrollspd_x:0.1
										  scrollspd_y:0] set_clamp_y_min:0 max:-150]];
	
	for (BackgroundObject *o in bg_objects) {
		[self addChild:o];
	}
	
	return self;
}

-(void)update:(GameEngineLayer*)g curx:(float)curx cury:(float)cury {
	for (BackgroundObject *o in bg_objects) {
		[o update_posx:curx posy:cury];
	}
}
@end
