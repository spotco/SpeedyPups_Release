#import "World2BGLayerSet.h"

@implementation World2BGLayerSet
+(World2BGLayerSet*)cons {
	World2BGLayerSet *rtv = [World2BGLayerSet node];
	return [rtv cons];
}

-(World2BGLayerSet*)cons {
	bg_objects = [NSMutableArray array];
	
	sky = [BackgroundObject backgroundFromTex:[Resource get_tex:TEX_BG2_SKY] scrollspd_x:0 scrollspd_y:0];
	[Common scale_to_fit_screen_y:sky];
	
	starsbg = [StarsBackgroundObject cons];
    [starsbg setOpacity:0];
	
	time = [BGTimeManager cons];
	clouds = [[[CloudGenerator cons] set_speedmult:0.3] set_generate_speed:140];
	backhills = [BackgroundObject backgroundFromTex:[Resource get_tex:TEX_BG2_BACKHILLS] scrollspd_x:0.005 scrollspd_y:0.003];
	water = [BackgroundObject backgroundFromTex:[Resource get_tex:TEX_BG2_WATER] scrollspd_x:0.03 scrollspd_y:0.007];
	fronthills = [BackgroundObject backgroundFromTex:[Resource get_tex:TEX_BG2_FRONTHILLS] scrollspd_x:0.01 scrollspd_y:0.003];
	backislands = [BackgroundObject backgroundFromTex:[Resource get_tex:TEX_BG2_FRONTISLANDS_1] scrollspd_x:0.03 scrollspd_y:0.006];
	frontislands = [BackgroundObject backgroundFromTex:[Resource get_tex:TEX_BG2_FRONTISLANDS_0] scrollspd_x:0.04 scrollspd_y:0.007];
	
	[bg_objects addObject:sky];
	[bg_objects addObject:starsbg];
	[bg_objects addObject:time];
	[bg_objects addObject:clouds];
	[bg_objects addObject:backhills];
	[bg_objects addObject:water];
	[bg_objects addObject:fronthills];
	[bg_objects addObject:backislands];
	[bg_objects addObject:frontislands];
	
	for (BackgroundObject *o in bg_objects) {
		[self addChild:o];
	}
	
	return self;
}

-(void)set_scrollup_pct:(float)pct{
	[clouds setPosition:ccp(clouds.position.x,-400*pct)];
	[backhills setPosition:ccp(backhills.position.x,backhills.position.y-400*pct)];
	[fronthills setPosition:ccp(fronthills.position.x,fronthills.position.y-400*pct)];
	[water setPosition:ccp(water.position.x,water.position.y-400*pct)];
	[backislands setPosition:ccp(backislands.position.x,backislands.position.y-400*pct)];
	[frontislands setPosition:ccp(frontislands.position.x,frontislands.position.y-400*pct)];
}

-(void)set_day_night_color:(float)val{	
	float pctm = ((float)val) / 100;
	[sky setColor:PCT_CCC3(50,50,90,pctm)];
	[clouds setColor:PCT_CCC3(80, 80, 130, pctm)];
	[backhills setColor:PCT_CCC3(80, 80, 130, pctm)];
	[fronthills setColor:PCT_CCC3(100, 100, 150, pctm)];
	[water setColor:PCT_CCC3(80, 80, 130, pctm)];
	[backislands setColor:PCT_CCC3(140, 140, 180, pctm)];
	[frontislands setColor:PCT_CCC3(140, 140, 180, pctm)];
	[starsbg setOpacity:255-pctm*255];
}

-(void)update:(GameEngineLayer*)g curx:(float)curx cury:(float)cury {
	for (BackgroundObject *o in bg_objects) {
		[o update_posx:curx posy:cury];
	}
}
@end
