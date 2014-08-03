#import "GameObject.h"
#import "MapLoader.h"
#import "MapSection.h"
#import "AutoLevelState.h"
#import "FreeRunStartAtManager.h"

@interface AutoLevel : GameObject <GEventListener> {
    GameEngineLayer* __unsafe_unretained tglayer;
    float cur_x,cur_y;
    NSMutableArray* __strong map_sections; //current ingame mapsections
    NSMutableArray* __strong queued_sections; //next mapsections
    NSMutableArray* __strong stored; //past, not removed yet
    
    AutoLevelState* __strong cur_state;
    BOOL has_pos_initial;
}

+(AutoLevel*)cons_with_glayer:(GameEngineLayer*)glayer startat:(WorldStartAt)world;

-(void)load_into_queue:(NSString*)key;
-(void)game_quit;
@end