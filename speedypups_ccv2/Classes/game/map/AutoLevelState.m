#import "AutoLevelState.h"
#import "AutoLevelState_World1.h"
#import "AutoLevelState_World2.h"
#import "AutoLevelState_World3.h" 

#import "Common.h"
#import "GameMain.h" 
#import "FreeRunStartAtManager.h"
#import "GameEngineLayer.h"
#import "DailyLoginPrizeManager.h"

@implementation AutoLevelState {
	AutoLevelStateMode _coin_goto_mode;
}

-(void)to_boss_mode {
	if (startat.world_num == WorldNum_1) {
		mode = AutoLevelStateMode_BOSS1;
	} else if (startat.world_num == WorldNum_2) {
		mode = AutoLevelStateMode_BOSS2;
	} else if (startat.world_num == WorldNum_3) {
		mode = AutoLevelStateMode_BOSS3;
	}
}
-(void)to_labexit_mode { mode = AutoLevelStateMode_LABEXIT; }

-(void)cons_level_defs{
	tutorial_levels = @[
		@"tutorial2_jumpwater",
		@"tutorial2_doublejumphover",
		@"tutorial_sanicloop",
		@"tutorial2_swipeget",
		@"tutorial_breakrocks",
		@"tutorial_upsidebounce",
		@"capegame_launcher"
	];
	
	lab_tutorial_levels = @[
		@"labintro_tutorialbop",
		@"labintro_tutoriallauncher"
	];
	
	world2_tutorial_levels = @[
		@"tutorial_swingvine"
	];
	world3_tutorial_levels = @[
		@"tutorial_cannons"
	];
	
	levelsets = @{
		L_FILLER:@{
			@"filler_sanicloop" : @1,
			@"filler_curvedesc" : @1,
			@"filler_islandjump" : @1,
			@"filler_rollinghills" : @1,
			@"filler_directdrop" : @1,
			@"filler_steepdec" : @1,
			@"filler_genome" : @1,
			@"filler_manyopt" : @1,
			@"filler_cuhrazyloop" : @1,
			@"filler_chickennuggets" : @1,
			@"filler_skippingstones" : @1,
			@"filler_godog" : @1,
			@"filler_goslow" : @1
		},
		L_WORLD1_CLASSIC:@{
			@"classic_trickytreas" : @1,
			@"classic_bridgenbwall" : @1,
			@"classic_cavewbwall" : @1,
			@"classic_huegcave" : @1,
			@"classic_tomslvl1" : @1,
			@"classic_nubcave" : @1,
			@"classic_doublehelix" : @1
		},
		L_WORLD1_EASY:@{
			@"easy_puddles" : @1,
			@"easy_world1" : @1,
			@"easy_gottagofast" : @1,
			@"easy_curvywater" : @1,
			@"easy_simplespikes" : @1,
			@"easy_curvybreak" : @1,
			@"easy_breakdetail" : @1
		},
		L_WORLD1_JUMPPAD:@{
			@"jumppad_bigjump" : @1,
			@"jumppad_crazyloop" : @1,
			@"jumppad_hiddenislands" : @1,
			@"jumppad_launch" : @1
		},

		L_WORLD2_SWINGVINE:@{
			@"swingvine_swingintro" : @1,
			@"swingvine_dodgespike" : @1,
			@"swingvine_swingbreak" : @1,
			@"swingvine_datbounce" : @1,
			@"swingvine_someswings" : @1,
			@"swingvine_hillvine" : @1,
			@"swingvine_kingofswing" : @1
		},
		L_WORLD2_JUMPPAD:@{
			@"jumppad_jumpgap" : @1,
			@"jumppad_jumpislands" : @1,
			@"jumppad_lotsobwalls" : @1,
			@"jumppad_spikeceil" : @1,
			@"classic_trickytreas" : @1
		},
		L_WORLD2_HARD:@{
			@"classic_smgislands" : @1,
			@"classic_manyoptredux" : @1,
			@"classic_twopath" : @1,
			@"swingvine_bounswindodg" : @1,
			@"swingvine_morecave" : @1,
		},
		L_WORLD3_CANNON:@{
			@"cannon_cannonsandrobots" : @1,
			@"cannon_cannoncave" : @1,
			@"cannon_jetpackthorns" : @1,
			@"cannon_jumprobotbounce" : @1,
			@"cannon_clockwork" : @1
		},
		L_WORLD3_SWINGVINE:@{
			@"swingvine_bounswindodg" : @1,
			@"swingvine_awesome" : @1,
			@"swingvine_morecave" : @1,
			@"swingvine_totalmix" : @1,
			@"classic_huegcave" : @1
		},
		L_WORLD3_HARD:@{
			@"classic_manyoptredux" : @1,
			@"hard_compilation" : @1,
			@"hard_sliptwist" : @1,
			@"hard_easypowerup" : @1,
			@"classic_trickytreas" : @1
		},
		L_LAB_1: @{
			@"lab_basicmix" : @1,
			@"lab_minionwalls" : @1,
			@"lab_towerfall" :@1,
			@"lab_easyloops":@1,
			@"lab_rocketarmy":@1
		},
		L_LAB_2: @{
			@"lab_tube" : @1,
			@"lab_ezshiz" : @1,
			@"lab_ezrocketshz" : @1,
			@"lab_clusterphobia" : @1,
			@"lab_swingers" : @1,
			@"lab_alladat" : @1,
			@"lab_muhfiller" :@1
		},
		L_LAB_3: @{
			@"lab_rocketfever" : @1,
			@"lab_bounceycannon" : @1,
			@"lab_cage_cannons" : @1,
			@"lab_minionwallshard" : @1,
			@"lab_rocketarmyhard" : @1
		},
		L_COIN: @{
			@"coin_freecoin" : @1
		},
		L_AUTOSTART: @{
			//@"shittytest":@1
			@"autolevel_start2": @1
		},
		L_FREERUN_PROGRESS_WORLD: @{
			@"freerun_progress": @1
		},
		L_FREERUN_PROGRESS_TO_LAB: @{
			@"freerun_progress_to_lab": @1
		},
		L_BOSS1START: @{
			@"boss1_start": @1
		},
		L_BOSS1AREA: @{
			@"boss1_area": @1
		},
		L_BOSS2START: @{
			@"boss2_start":@1
		},
		L_BOSS2AREA: @{
			@"boss2_area":@1
		},
		L_BOSS3START: @{
			@"boss3_start":@1
		},
		L_BOSS3AREA: @{
			@"boss3_area":@1
		},
		L_LABINTRO: @{
			@"labintro_entrance" : @1
		},
		L_LABEXIT: @{
			@"labintro_labexit" : @1
		},
		L_CAPEGAME_LAUNCHER: @{
			@"capegame_launcher": @1
		}
	};
}

+(NSArray*)get_all_levels {
	WorldStartAt rtv;
	AutoLevelState *state = [AutoLevelState cons_startat:rtv];
	return [state get_all_levels];
}

-(NSArray*)get_all_levels {
	NSMutableSet *lvls = [[NSMutableSet alloc] init];
	for (NSString *setname in [levelsets allKeys]) {
		for (NSString *lvl in [levelsets[setname] allKeys]) {
			[lvls addObject:lvl];
		}
	}
	return [lvls allObjects];
}

+(AutoLevelState*)cons_startat:(WorldStartAt)startat {
    return [[AutoLevelState alloc] init_startat:startat];
}

-(id)init_startat:(WorldStartAt)_startat {
    self = [super init];
	[self cons_level_defs];
	startat = _startat;
	mode = AutoLevelStateMode_FREERUN_START;
	sets_completed = 0;
	cur_set_completed_levels = 0;
	
	setgen = [WeightedSorter cons_vals:levelsets use:@[
		L_WORLD1_EASY,
		L_WORLD1_JUMPPAD,
		L_WORLD1_CLASSIC,
		L_WORLD2_SWINGVINE,
		L_WORLD2_JUMPPAD,
		L_WORLD2_HARD,
		L_WORLD3_CANNON,
		L_WORLD3_SWINGVINE,
		L_WORLD3_HARD
	]];
	fillersetgen = [WeightedSorter cons_vals:levelsets use:@[L_FILLER]];
	labsetgen = [WeightedSorter cons_vals:levelsets use:@[
		L_LAB_1,
		L_LAB_2,
		L_LAB_3
	]];
	
	recently_picked_sets = [NSMutableArray array];
    return self;
}

-(NSString*)pick_set:(WorldNum)worldnum {
	NSArray *available;
	if (worldnum == WorldNum_1) {
		available = @[L_WORLD1_EASY, L_WORLD1_JUMPPAD, L_WORLD1_CLASSIC];
		
	} else if (worldnum == WorldNum_2) {
		available = @[L_WORLD2_SWINGVINE, L_WORLD2_JUMPPAD, L_WORLD2_HARD];
		
	} else if (worldnum == WorldNum_3) {
		available = @[L_WORLD3_CANNON, L_WORLD3_SWINGVINE, L_WORLD3_HARD];
		
	} else {
		available = @[L_WORLD1_EASY];
		NSLog(@"autolevelstate pick_set error");
	}
	
	NSArray *usem = [available copy_removing:recently_picked_sets];
	if (usem.count == 0) {
		[recently_picked_sets removeAllObjects];
		usem = available;
	}
	
	NSString *tar = usem.random;
	[recently_picked_sets addObject:tar];
	return tar;
}

-(NSString*)get_level {
	if (mode == AutoLevelState_COIN) {
		mode = _coin_goto_mode;
		[DailyLoginPrizeManager increment_coins_spawned_today];
		return [[levelsets[L_COIN] allKeys] random];
		
	} else if (startat.world_num == WorldNum_1) {
		return [self get_level_world1];
		
	} else if (startat.world_num == WorldNum_2) {
		return [self get_level_world2];
		
	} else if (startat.world_num == WorldNum_3) {
		return [self get_level_world3];
		
	} else {
		NSLog(@"pick set world error");
		return [[levelsets[L_AUTOSTART] allKeys] random];
	}
}

-(void)conditional_go_to_coin_level_or_mode:(AutoLevelStateMode)_mode {
	if ([DailyLoginPrizeManager conditional_do_coin_level]) {
		_coin_goto_mode = _mode;
		mode = AutoLevelState_COIN;
	} else {
		mode = _mode;
	}
}

static int FILLER_PROGRESS = 1;
+(void)set_filler_progress:(int)fillerprogress {
	FILLER_PROGRESS = fillerprogress;
}
+(int)get_filler_progress {
	return FILLER_PROGRESS;
}

@end
