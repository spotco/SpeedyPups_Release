#import "AutoLevelState_World3.h"
#import "GameMain.h"

@implementation AutoLevelState (AutoLevelState_World3)

-(NSString*)get_level_world3{
	if (mode == AutoLevelStateMode_FREERUN_START) {
		if (startat.bg_start == BGMode_LAB) {
			mode = AutoLevelStateMode_FREERUN_PROGRESS_TO_LAB;
			
		} else {
			mode = AutoLevelStateMode_FREERUN_PROGRESS_TO_SET;
		}
		return [[levelsets[L_AUTOSTART] allKeys] random];
		
	} else if (mode == AutoLevelStateMode_FREERUN_PROGRESS_TO_SET) {
		mode = AutoLevelStateMode_WORLD3_TUTORIAL;
		return [[levelsets[L_FREERUN_PROGRESS_WORLD] allKeys] random];
		
	} else if (mode == AutoLevelStateMode_WORLD3_TUTORIAL) {
		mode = AutoLevelStateMode_SET;
		cur_set = L_WORLD3_CANNON;
		[recently_picked_sets addObject:L_WORLD3_CANNON];
		cur_set_completed_levels = 0;
		sets_completed = 0;
		return [world3_tutorial_levels random];
		
	} else if (mode == AutoLevelStateMode_SET) {
		cur_set_completed_levels++;
		if (cur_set_completed_levels >= LEVELS_IN_SET) {
			mode = AutoLevelStateMode_FILLER;
			[AutoLevelState set_filler_progress:sets_completed];
			sets_completed++;
		}
		return [setgen get_from_bucket:cur_set];
		
	} else if (mode == AutoLevelStateMode_FILLER) {
		if (sets_completed < SETS_BETWEEN_LABS) {
			[self conditional_go_to_coin_level_or_mode:AutoLevelStateMode_SET];
			//mode = AutoLevelStateMode_SET;
			cur_set = [self pick_set:startat.world_num];
			cur_set_completed_levels = 0;
		} else {
			[self conditional_go_to_coin_level_or_mode:AutoLevelStateMode_SET_OVER_CAPEGAME];
			//mode = AutoLevelStateMode_SET_OVER_CAPEGAME;
			tutorial_ct = 0;
		}
		return [fillersetgen get_from_bucket:L_FILLER];
		
	} else if (mode == AutoLevelStateMode_SET_OVER_CAPEGAME) {
		mode = AutoLevelStateMode_FREERUN_PROGRESS_TO_LAB;
		return [[levelsets[L_CAPEGAME_LAUNCHER] allKeys] random];
		
	} else if (mode == AutoLevelStateMode_FREERUN_PROGRESS_TO_LAB) {
		mode = AutoLevelStateMode_LABINTRO;
		return [[levelsets[L_FREERUN_PROGRESS_TO_LAB] allKeys] random];
		
	} else if (mode == AutoLevelStateMode_LABINTRO) {
		if ([GameMain GET_IMMEDIATE_BOSS]) {
			mode = AutoLevelStateMode_BOSS3_ENTER;
		} else {
			mode = AutoLevelStateMode_LAB;
		}
		
		cur_set_completed_levels = 0;
		return [[levelsets[L_LABINTRO] allKeys] random];
		
	} else if (mode == AutoLevelStateMode_LAB) {
		cur_set_completed_levels++;
		if (cur_set_completed_levels >= LEVELS_IN_LAB_SET) {
			mode = AutoLevelStateMode_BOSS3_ENTER;
		}
		return [labsetgen get_from_bucket:L_LAB_3];
		
	} else if (mode == AutoLevelStateMode_BOSS3_ENTER) {
		return [[levelsets[L_BOSS3START] allKeys] random];
		
	} else if (mode == AutoLevelStateMode_BOSS3) {
		return [[levelsets[L_BOSS3AREA] allKeys] random];
		
	} else if (mode == AutoLevelStateMode_LABEXIT) {
		return [[levelsets[L_LABEXIT] allKeys] random];
		
	} else {
		NSLog(@"GET_LEVEL_WORLD3 ERROR");
		return @"";
	}
}

@end
