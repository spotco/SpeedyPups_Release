#import "World3BGLayerSet.h"

@implementation World3BGLayerSet

+(World3BGLayerSet*)cons {
	World3BGLayerSet *rtv = [World3BGLayerSet node];
	return [rtv cons];
}

-(World3BGLayerSet*)cons {
	bg_objects = [NSMutableArray array];
	
	sky = [BackgroundObject backgroundFromTex:[Resource get_tex:TEX_BG3_SKY] scrollspd_x:0 scrollspd_y:0];
	[Common scale_to_fit_screen_y:sky];
	
	starsbg = [StarsBackgroundObject cons];
    [starsbg setOpacity:0];
	
	time = [BGTimeManager cons];
	clouds = [[[CloudGenerator cons_texkey:TEX_BG2_CLOUDS_SS scaley:0.003] set_speedmult:0.3] set_generate_speed:140];
	backmountains = [BackgroundObject backgroundFromTex:[Resource get_tex:TEX_BG3_BACKMOUNTAINS] scrollspd_x:0.025 scrollspd_y:0.005];
	castle = [BackgroundObject backgroundFromTex:[Resource get_tex:TEX_BG3_CASTLE] scrollspd_x:0.03 scrollspd_y:0.0075];
	backhills = [BackgroundObject backgroundFromTex:[Resource get_tex:TEX_BG3_BACKHILLS] scrollspd_x:0.05 scrollspd_y:0.015];
	fronthills = [BackgroundObject backgroundFromTex:[Resource get_tex:TEX_BG3_FRONTHILLS] scrollspd_x:0.1 scrollspd_y:0.03];
	
	[bg_objects addObject:sky];
	[bg_objects addObject:starsbg];
	[bg_objects addObject:time];
	[bg_objects addObject:clouds];
	[bg_objects addObject:backmountains];
	[bg_objects addObject:castle];
	[bg_objects addObject:backhills];
	[bg_objects addObject:fronthills];
	
	for (BackgroundObject *o in bg_objects) {
		[self addChild:o];
	}
	return self;
}

-(void)set_scrollup_pct:(float)pct{
    [clouds setPosition:ccp(clouds.position.x,-400*pct)];
	[backmountains setPosition:ccp(backmountains.position.x,backmountains.position.y-400*pct)];
	[castle setPosition:ccp(castle.position.x,castle.position.y-400*pct)];
    [backhills setPosition:ccp(backhills.position.x,backhills.position.y-400*pct)];
    [fronthills setPosition:ccp(fronthills.position.x,fronthills.position.y-400*pct)];
}

-(void)set_day_night_color:(float)val{
    float pctm = ((float)val) / 100;
    [sky setColor:ccc3(pb(20,pctm),pb(20,pctm),pb(60,pctm))];
    [clouds setColor:ccc3(pb(150,pctm),pb(150,pctm),pb(190,pctm))];
	[backmountains setColor:ccc3(pb(50,pctm),pb(50,pctm),pb(90,pctm))];
	[castle setColor:ccc3(pb(50,pctm),pb(50,pctm),pb(90,pctm))];
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
