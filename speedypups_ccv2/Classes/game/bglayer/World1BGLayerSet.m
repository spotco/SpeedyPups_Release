#import "World1BGLayerSet.h"
#import "BackgroundObject.h"
#import "BGTimeManager.h"


@implementation World1BGLayerSet

+(World1BGLayerSet*)cons {
	World1BGLayerSet *rtv = [World1BGLayerSet node];
	return [rtv cons];
}

-(World1BGLayerSet*)cons {
	bg_objects = [NSMutableArray array];
	
	sky = [BackgroundObject backgroundFromTex:[Resource get_tex:TEX_BG_SKY] scrollspd_x:0 scrollspd_y:0]; 
	[Common scale_to_fit_screen_y:sky];
	
	starsbg = [StarsBackgroundObject cons];
    [starsbg setOpacity:0];
	
	time = [BGTimeManager cons];
	backhills = [BackgroundObject backgroundFromTex:[Resource get_tex:TEX_BG_LAYER_3] scrollspd_x:0.025 scrollspd_y:0.005];
	[Common scale_to_screen_expected:backhills];
	
	clouds = [[[CloudGenerator cons] set_speedmult:0.3] set_generate_speed:140];
	//[Common scale_to_screen_expected:clouds];
	//[CloudGenerator cons];
	fronthills = [BackgroundObject backgroundFromTex:[Resource get_tex:TEX_BG_LAYER_1] scrollspd_x:0.05 scrollspd_y:0.03];
	[Common scale_to_screen_expected:fronthills];
	
	[bg_objects addObject:sky];
	[bg_objects addObject:starsbg];
	[bg_objects addObject:time];
	[bg_objects addObject:clouds];
	[bg_objects addObject:backhills];
	[bg_objects addObject:fronthills];
	
	
	 
	for (BackgroundObject *o in bg_objects) {
		[self addChild:o];
	}
	
	return self;
}

-(void)set_scrollup_pct:(float)pct{
    [clouds setPosition:ccp(clouds.position.x,-400*pct)];
    [backhills setPosition:ccp(backhills.position.x,backhills.position.y-400*pct)];
    [fronthills setPosition:ccp(fronthills.position.x,fronthills.position.y-400*pct)];
}

-(void)set_day_night_color:(float)val{
    float pctm = ((float)val) / 100;
    [sky setColor:ccc3(pb(20,pctm),pb(20,pctm),pb(60,pctm))];
    [clouds setColor:ccc3(pb(150,pctm),pb(150,pctm),pb(190,pctm))];
    [backhills setColor:ccc3(pb(50,pctm),pb(50,pctm),pb(90,pctm))];
    [fronthills setColor:ccc3(pb(140,pctm),pb(140,pctm),pb(180,pctm))];
    [starsbg setOpacity:255-pctm*255];
}

-(void)update:(GameEngineLayer*)g curx:(float)curx cury:(float)cury {
	for (BackgroundObject *o in bg_objects) {
		[o update_posx:curx posy:cury];
	}
}

@end
