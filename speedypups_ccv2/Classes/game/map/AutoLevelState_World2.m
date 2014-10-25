#import "AutoLevelState_World2.h"
#import "GameMain.h"

@implementation AutoLevelState (AutoLevelState_World2)

-(NSString*)get_level_world2 {
	if (mode == AutoLevelStateMode_FREERUN_START) {
		if (startat.bg_start == BGMode_LAB) {
			mode = AutoLevelStateMode_FREERUN_PROGRESS_TO_LAB;
			
		} else {
			mode = AutoLevelStateMode_FREERUN_PROGRESS_TO_SET;
		}
		return [[levelsets[L_AUTOSTART] allKeys] random];
		
	} else if (mode == AutoLevelStateMode_FREERUN_PROGRESS_TO_SET) {
		mode = AutoLevelStateMode_WORLD2_TUTORIAL;
		return [[levelsets[L_FREERUN_PROGRESS_WORLD] allKeys] random];
		
	} else if (mode == AutoLevelStateMode_WORLD2_TUTORIAL) {
		mode = AutoLevelStateMode_SET;
		cur_set = L_WORLD2_SWINGVINE;
		[recently_picked_sets addObject:L_WORLD2_SWINGVINE];
		cur_set_completed_levels = 0;
		sets_completed = 0;
		return [world2_tutorial_levels random];
		
	} else if (mode == AutoLevelStateMode_SET) {
		cur_set_completed_levels++;
		if (cur_set_completed_levels >= LEVELS_IN_SET) {
			mode = AutoLevelStateMode_FILLER;
			sets_completed++;
			[AutoLevelState set_filler_progress:sets_completed];
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
			mode = AutoLevelStateMode_BOSS2_ENTER;
		} else {
			mode = AutoLevelStateMode_LAB;
		}
		
		cur_set_completed_levels = 0;
		return [[levelsets[L_LABINTRO] allKeys] random];
		
	} else if (mode == AutoLevelStateMode_LAB) {
		cur_set_completed_levels++;
		if (cur_set_completed_levels >= LEVELS_IN_LAB_SET) {
			mode = AutoLevelStateMode_BOSS2_ENTER;
		}
		return [labsetgen get_from_bucket:L_LAB_2];
		
	} else if (mode == AutoLevelStateMode_BOSS2_ENTER) {
		return [[levelsets[L_BOSS2START] allKeys] random];
		
	} else if (mode == AutoLevelStateMode_BOSS2) {
		return [[levelsets[L_BOSS2AREA] allKeys] random];
		
	} else if (mode == AutoLevelStateMode_LABEXIT) {
		return [[levelsets[L_LABEXIT] allKeys] random];
		
	} else {
		NSLog(@"GET_LEVEL_WORLD2 ERROR");
		return @"";
	}
}

@end
