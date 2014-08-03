#import "cocos2d.h"
#import "Resource.h"
#import "BackgroundObject.h"
#import "LabBGObject.h"
#import "CloudGenerator.h"
#import "BGTimeManager.h"
#import "GameEngineLayer.h"
#import "GameMain.h"
#import "GEventDispatcher.h"

@class World1BGLayerSet;
@class Lab1BGLayerSet;
@class World2BGLayerSet;
@class SubBossBGObject;

@interface BGLayerSet : CCNode {
	int fadein_ct;
	int fadeout_ct;
	int ct;
}
-(void)set_scrollup_pct:(float)pct;
-(void)set_day_night_color:(float)pct;
-(void)update:(GameEngineLayer*)g curx:(float)curx cury:(float)cury;

-(void)fadeout_in:(int)ticks;
-(void)fadein_in:(int)ticks;
-(void)update_fadeout;
-(void)set_opacity:(float)pct;
@end


@interface BGLayer : CCLayer <GEventListener> {
/*
	BGLayerSet *bglayerset_world1;
	BGLayerSet *bglayerset_lab1;
	BGLayerSet *bglayerset_world2;
	BGLayerSet *bglayerset_lab2;
	BGLayerSet *bglayerset_world3;
	BGLayerSet *bglayerset_lab3;
	
#define ALL_SETS @[bglayerset_world1,bglayerset_world2,bglayerset_world3,bglayerset_lab1,bglayerset_lab2,bglayerset_lab3]
	BGLayerSet *current_set;
*/
	
	BGLayerSet *normal_set;
	BGLayerSet *lab_set;
 
    GameEngineLayer* __unsafe_unretained game_engine_layer;
    
    float lastx,lasty, curx,cury;
    
    
}

+(BGLayer*)cons_with_gamelayer:(GameEngineLayer*)g;

-(SubBossBGObject*)get_subboss_bgobject;
@end
