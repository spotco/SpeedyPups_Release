#import "AutoLevelState_World1.h"
#import "GameMain.h"

@implementation AutoLevelState (AutoLevelState_World1)

-(NSString*)get_level_world1 {
	if (mode == AutoLevelStateMode_FREERUN_START) {
		if (startat.tutorial) {
			mode = AutoLevelStateMode_WORLD1_TUTORIAL;
			tutorial_ct = 0;
			
		} else if (startat.bg_start == BGMode_LAB) {
			mode = AutoLevelStateMode_FREERUN_PROGRESS_TO_LAB;
			
		} else {
			mode = AutoLevelStateMode_FREERUN_PROGRESS_TO_SET;
		}
		return [[levelsets[L_AUTOSTART] allKeys] random];
		
	} else if (mode == AutoLevelStateMode_WORLD1_TUTORIAL) {
		NSString *tar = [tutorial_levels get:tutorial_ct];
		tutorial_ct++;
		if (tutorial_ct >= tutorial_levels.count) {
			mode = AutoLevelStateMode_FREERUN_PROGRESS_TO_SET;
			
		}
		return tar;
		
	} else if (mode == AutoLevelStateMode_FREERUN_PROGRESS_TO_SET) {
		mode = AutoLevelStateMode_SET;
		cur_set = L_WORLD1_EASY;
		[recently_picked_sets addObject:L_WORLD1_EASY];
		cur_set_completed_levels = 0;
		sets_completed = 0;
		 return [[levelsets[L_FREERUN_PROGRESS_WORLD] allKeys] random];
		
	} else if (mode == AutoLevelStateMode_SET) {
		cur_set_completed_levels++;
		if (cur_set_completed_levels >= LEVELS_IN_SET) {
			mode = AutoLevelStateMode_FILLER;
			[AutoLevelState set_filler_progress:sets_completed];
			sets_completed++;
		}
		return [setgen get_from_bucket:cur_set];
		//return @"shittytest";
		
	} else if (mode == AutoLevelStateMode_FILLER) {
		if (sets_completed < SETS_BETWEEN_LABS) {
			//mode = AutoLevelStateMode_SET;
			[self conditional_go_to_coin_level_or_mode:AutoLevelStateMode_SET];
			cur_set = [self pick_set:startat.world_num];
			cur_set_completed_levels = 0;
		} else {
			//mode = AutoLevelStateMode_SET_OVER_CAPEGAME;
			[self conditional_go_to_coin_level_or_mode:AutoLevelStateMode_SET_OVER_CAPEGAME];
			tutorial_ct = 0;
		}
		return [fillersetgen get_from_bucket:L_FILLER];
		//return @"test_quick";
		
	} else if (mode == AutoLevelStateMode_SET_OVER_CAPEGAME) {
		mode = AutoLevelStateMode_WORLD1_LAB_TUTORIAL;
		return [[levelsets[L_CAPEGAME_LAUNCHER] allKeys] random];
		
	} else if (mode == AutoLevelStateMode_WORLD1_LAB_TUTORIAL) {
		NSString *tar = [lab_tutorial_levels get:tutorial_ct];
		tutorial_ct++;
		if (tutorial_ct >= lab_tutorial_levels.count) {
			mode = AutoLevelStateMode_FREERUN_PROGRESS_TO_LAB;
		}
		return tar;
		
	} else if (mode == AutoLevelStateMode_FREERUN_PROGRESS_TO_LAB) {
		mode = AutoLevelStateMode_LABINTRO;
		return [[levelsets[L_FREERUN_PROGRESS_TO_LAB] allKeys] random];
		
	} else if (mode == AutoLevelStateMode_LABINTRO) {
		if ([GameMain GET_IMMEDIATE_BOSS]) {
			mode = AutoLevelStateMode_BOSS1_ENTER;
		} else {
			mode = AutoLevelStateMode_LAB;
		}
		cur_set_completed_levels = 0;
		return [[levelsets[L_LABINTRO] allKeys] random];
		
	} else if (mode == AutoLevelStateMode_LAB) {
		NSString *rtv;
		
		retry:
		rtv = [labsetgen get_from_bucket:L_LAB_1];
		if (cur_set_completed_levels == 0 && streq(rtv, @"lab_rocketarmy")) goto retry;
		
		cur_set_completed_levels++;
		if (cur_set_completed_levels >= LEVELS_IN_LAB_SET) {
			mode = AutoLevelStateMode_BOSS1_ENTER;
		}
		return rtv;
		
	} else if (mode == AutoLevelStateMode_BOSS1_ENTER) {
		return [[levelsets[L_BOSS1START] allKeys] random];
		
	} else if (mode == AutoLevelStateMode_BOSS1) {
		return [[levelsets[L_BOSS1AREA] allKeys] random];
		
	} else if (mode == AutoLevelStateMode_LABEXIT) {
		return [[levelsets[L_LABEXIT] allKeys] random];
		
	} else {
		NSLog(@"GET_LEVEL_WORLD1 ERROR");
		return @"";
	}
}

@end
