#import "BGLayer.h"
#import "GameEngineLayer.h"

#import "World1BGLayerSet.h"
#import "Lab1BGLayerSet.h"
#import "World2BGLayerSet.h"
#import "Lab2BGLayerSet.h"
#import "World3BGLayerSet.h"
#import "Lab3BGLayerSet.h"

@implementation BGLayerSet
-(void)set_scrollup_pct:(float)pct{}
-(void)set_day_night_color:(float)pct{}
-(void)update:(GameEngineLayer*)g curx:(float)curx cury:(float)cury{}

-(void)fadeout_in:(int)ticks{
	fadein_ct = 0;
	fadeout_ct = ticks;
	ct = ticks;
	[self setVisible:YES];
	[self set_opacity:1];
}
-(void)fadein_in:(int)ticks{
	fadein_ct = ticks;
	fadeout_ct = 0;
	ct = ticks;
	[self setVisible:YES];
	[self set_opacity:0];
}
-(void)update_fadeout{
	if (fadein_ct > 0) {
		ct--;
		[self set_opacity:1-ct/((float)fadein_ct)];
		if (ct == 0) {
			fadein_ct = 0;
		}
		
	} else if (fadeout_ct > 0) {
		ct--;
		[self set_opacity:ct/((float)fadeout_ct)];
		if (ct == 0) {
			[self setVisible:NO];
			fadeout_ct = 0;
		}
	}
}
-(void)set_opacity:(float)pct {
	for (CCSprite *c in self.children) {
		[c setOpacity:pct*255];
	}
}
@end


@implementation BGLayer

+(BGLayer*)cons_with_gamelayer:(GameEngineLayer*)g {
    BGLayer *l = [[BGLayer node] cons_with:g];
    [GEventDispatcher add_listener:l];
    [l update];
    return l;
}

-(void)bglayer_addChild:(CCNode*)node {
	if ([GameMain GET_USE_BG]) {
		[self addChild:node];
	}
}

-(id) cons_with:(GameEngineLayer*)ref {
	game_engine_layer = ref;
	
	if (game_engine_layer.world_mode.cur_world == WorldNum_1) {
		normal_set = [World1BGLayerSet cons];;
		lab_set = [Lab1BGLayerSet cons];
		
	} else if (game_engine_layer.world_mode.cur_world == WorldNum_2) {
		normal_set = [World2BGLayerSet cons];
		lab_set = [Lab2BGLayerSet cons];
		
	} else if (game_engine_layer.world_mode.cur_world == WorldNum_3) {
		normal_set = [World3BGLayerSet cons];
		lab_set = [Lab3BGLayerSet cons];
		
	} else {
		NSLog(@"BGLayer cons world error");
	}
	[normal_set setVisible:YES];
	[lab_set setVisible:NO];
	
	[self bglayer_addChild:normal_set];
	[self bglayer_addChild:lab_set];
	
	return self;
}

-(void)dispatch_event:(GEvent *)e {
    if (e.type == GEventType_GAME_TICK) {
        [self update];
        
    } else if (e.type == GEventType_ENTER_LABAREA) {
		[normal_set fadeout_in:10];
		[lab_set fadein_in:10];
		
        
    } else if (e.type == GEventType_DAY_NIGHT_UPDATE) {
		[normal_set set_day_night_color:e.i1];
		[lab_set set_day_night_color:e.i1];
        
    } else if (e.type == GEventType_MENU_SCROLLBGUP_PCT) {
		[normal_set set_scrollup_pct:e.f1];
		[lab_set set_scrollup_pct:e.f1];
        
    } else if (e.type == GEventType_BOSS2_ACTIVATE) {
		[[self labset_as_lab2set] do_sink_anim];
		
	} else if (e.type == GEventType_PLAYER_DIE) {
		if ([lab_set class] == [Lab2BGLayerSet class]) [[self labset_as_lab2set] reset];
		
	}
}

-(SubBossBGObject*)get_subboss_bgobject {
	return [[self labset_as_lab2set] get_subboss_bgobject];
}

-(Lab2BGLayerSet*)labset_as_lab2set {
	if ([lab_set class] == [Lab2BGLayerSet class]) {
		return (Lab2BGLayerSet*)lab_set;
	} else {
		NSLog(@"ERROR ATTEMPTING TO USE %@ AS LAB2 SET",[lab_set class]);
		return NULL;
	}
}

-(void)update {    
    float posx = game_engine_layer.player.position.x;
    float posy = game_engine_layer.player.position.y;
	//float posy = clampf(game_engine_layer.player.position.y, game_engine_layer.get_follow_clamp_y_range.min, game_engine_layer.get_follow_clamp_y_range.max);
    
    float dx = posx - lastx;
    float dy = posy - lasty;
    
    curx += dx;
    cury = MAX(0,MIN(3000,cury+dy)); //SCROLL_LIMIT
    
    lastx = posx;
    lasty = posy;
    
	[normal_set update:game_engine_layer curx:curx cury:cury];
	[lab_set update:game_engine_layer curx:curx cury:cury];
	
	[normal_set update_fadeout];
	[lab_set update_fadeout];
}

-(void)dealloc {
    [self removeAllChildrenWithCleanup:YES];
}

@end