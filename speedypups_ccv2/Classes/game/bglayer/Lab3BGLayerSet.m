
#import "Lab3BGLayerSet.h"

@implementation Lab3BGLayerSet
+(Lab3BGLayerSet*)cons {
	Lab3BGLayerSet *rtv = [Lab3BGLayerSet node];
	return [rtv cons];
}

-(Lab3BGLayerSet*)cons {
	bg_objects = [NSMutableArray array];
	
	BackgroundObject *bgback = [BackgroundObject backgroundFromTex:[Resource get_tex:TEX_LAB3_BGBACK] scrollspd_x:0.05 scrollspd_y:0];
	[Common scale_to_fit_screen_y:bgback];
	[bg_objects addObject:bgback];
	
	BackgroundObject *bgwall = [BackgroundObject backgroundFromTex:[Resource get_tex:TEX_LAB3_BGWALL] scrollspd_x:0.07 scrollspd_y:0];
	[Common scale_to_fit_screen_y:bgwall];
	[bg_objects addObject:bgwall];
	
	[bg_objects addObject:[[BackgroundObject backgroundFromTex:[Resource get_tex:TEX_LAB3_BGFRONT] scrollspd_x:0.1 scrollspd_y:0] set_clamp_y_min:0 max:-50]];
	
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
