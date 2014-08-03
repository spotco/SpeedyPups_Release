#import <Foundation/Foundation.h>
#import "FreeRunProgressAnimation.h" 
#import "WeightedSorter.h"

#define L_TUTORIAL @"levelset_tutorial"
#define L_LAB_TUTORIAL @"levelset_lab_tutorial"
#define L_CAPEGAME_LAUNCHER @"levelset_capegame_launcher"

#define L_FILLER @"levelset_filler"

#define L_WORLD1_CLASSIC @"levelset_world1_classic"
#define L_WORLD1_EASY @"levelset_world1_easy"
#define L_WORLD1_JUMPPAD @"levelset_world1_jumppad"

#define L_WORLD2_SWINGVINE @"levelset_world2_swingvine"
#define L_WORLD2_JUMPPAD @"levelset_world2_jumppad"
#define L_WORLD2_HARD @"levelset_world2_hard"

#define L_WORLD3_CANNON @"levelset_world3_cannon"
#define L_WORLD3_SWINGVINE @"levelset_world3_swingvine"
#define L_WORLD3_HARD @"levelset_world3_hard"

//#define L_FREERUN_PROGRESS @"levelset_freerun_progress"
#define L_FREERUN_PROGRESS_WORLD @"levelset_freerun_progress_world"
#define L_FREERUN_PROGRESS_TO_LAB @"levelset_freerunprogress_to_lab"

#define L_BOSS1START @"levelset_boss1start"
#define L_BOSS1AREA @"levelset_boss1area"
#define L_AUTOSTART @"levelset_autostart"

#define L_BOSS2START @"levelset_boss2start"
#define L_BOSS2AREA @"levelset_boss2area"

#define L_BOSS3START @"levelset_boss3start"
#define L_BOSS3AREA @"levelset_boss3area"

#define L_LABINTRO @"levelset_labintro"
#define L_LABEXIT @"levelset_labexit"

#define L_LAB_1 @"levelset_lab_1"
#define L_LAB_2 @"levelset_lab_2"
#define L_LAB_3 @"levelset_lab_3"

#define L_COIN @"levelset_coin" 

#define SETS_BETWEEN_LABS 3
#define LEVELS_IN_LAB_SET 3
#define LEVELS_IN_SET 3

typedef enum AutoLevelStateMode {
	AutoLevelStateMode_FREERUN_START,
	AutoLevelStateMode_FREERUN_PROGRESS_TO_SET,
	AutoLevelStateMode_FREERUN_PROGRESS_TO_LAB,
	AutoLevelStateMode_WORLD1_TUTORIAL,
	AutoLevelStateMode_WORLD2_TUTORIAL,
	AutoLevelStateMode_WORLD3_TUTORIAL,
	AutoLevelStateMode_WORLD1_LAB_TUTORIAL,
	AutoLevelStateMode_SET,
	AutoLevelStateMode_SET_OVER_CAPEGAME,
	AutoLevelStateMode_FILLER,
	AutoLevelStateMode_LABINTRO,
	AutoLevelStateMode_LABEXIT,
	AutoLevelStateMode_LAB,
	AutoLevelStateMode_BOSS1_ENTER,
	AutoLevelStateMode_BOSS2_ENTER,
	AutoLevelStateMode_BOSS3_ENTER,
	AutoLevelStateMode_BOSS1,
	AutoLevelStateMode_BOSS2,
	AutoLevelStateMode_BOSS3,
	
	AutoLevelState_COIN
} AutoLevelStateMode;

@interface AutoLevelState : NSObject {
	AutoLevelStateMode mode;
	NSString *cur_set;
	WorldStartAt startat;
	
	int tutorial_ct;
	int sets_completed;
	int cur_set_completed_levels;
	
	NSMutableArray *recently_picked_sets;
	WeightedSorter *setgen, *fillersetgen, *labsetgen;
	
	
	NSDictionary *levelsets;
	NSArray *tutorial_levels;
	NSArray *lab_tutorial_levels;
	NSArray *world2_tutorial_levels;
	NSArray *world3_tutorial_levels;
}
+(AutoLevelState*)cons_startat:(WorldStartAt)startat ;
-(NSString*)get_level;
+(NSArray*)get_all_levels;

-(NSString*)pick_set:(WorldNum)worldnum;

-(void)to_boss_mode;
-(void)to_labexit_mode;

-(void)conditional_go_to_coin_level_or_mode:(AutoLevelStateMode)_mode;

@end
