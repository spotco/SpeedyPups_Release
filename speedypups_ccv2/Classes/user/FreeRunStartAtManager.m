#import "FreeRunStartAtManager.h"
#import "Common.h"
#import "DataStore.h"
#import "Resource.h"
#import "FileCache.h"

@implementation FreeRunStartAtManager

#define STARTING_LOC_KEY @"STARTING_AT"
+(FreeRunStartAt)get_starting_loc {
	return [DataStore get_int_for_key:STARTING_LOC_KEY];
}

+(void)set_starting_loc:(FreeRunStartAt)loc {
	[DataStore set_key:STARTING_LOC_KEY int_value:loc];
}

+(NSString*)string_for_loc:(FreeRunStartAt)loc {
	return strf("START_AT_%d",loc);
}

+(BOOL)get_can_start_at:(FreeRunStartAt)loc {
	if (loc == FreeRunStartAt_TUTORIAL) {
		return YES;
	}
	return [DataStore get_int_for_key:[self string_for_loc:loc]];
}

+(void)set_can_start_at:(FreeRunStartAt)loc {
	[DataStore set_key:[self string_for_loc:loc] int_value:1];
}

+(TexRect*)get_icon_for_loc:(FreeRunStartAt)loc {
	if (loc == FreeRunStartAt_TUTORIAL) {
		return [TexRect cons_tex:[Resource get_tex:TEX_FREERUNSTARTICONS] rect:[FileCache get_cgrect_from_plist:TEX_FREERUNSTARTICONS idname:@"icon_tutorial"]];
		
	} else if (loc == FreeRunStartAt_WORLD1) {
		return [TexRect cons_tex:[Resource get_tex:TEX_FREERUNSTARTICONS] rect:[FileCache get_cgrect_from_plist:TEX_FREERUNSTARTICONS idname:@"icon_world1"]];
		
	} else if (loc == FreeRunStartAt_LAB1) {
		return [TexRect cons_tex:[Resource get_tex:TEX_FREERUNSTARTICONS] rect:[FileCache get_cgrect_from_plist:TEX_FREERUNSTARTICONS idname:@"icon_lab1"]];
		
	} else if (loc == FreeRunStartAt_WORLD2) {
		return [TexRect cons_tex:[Resource get_tex:TEX_FREERUNSTARTICONS] rect:[FileCache get_cgrect_from_plist:TEX_FREERUNSTARTICONS idname:@"icon_world2"]];
		
	} else if (loc == FreeRunStartAt_LAB2) {
		return [TexRect cons_tex:[Resource get_tex:TEX_FREERUNSTARTICONS] rect:[FileCache get_cgrect_from_plist:TEX_FREERUNSTARTICONS idname:@"icon_lab2"]];
		
	} else if (loc == FreeRunStartAt_WORLD3) {
		return [TexRect cons_tex:[Resource get_tex:TEX_FREERUNSTARTICONS] rect:[FileCache get_cgrect_from_plist:TEX_FREERUNSTARTICONS idname:@"icon_world3"]];
		
	} else if (loc == FreeRunStartAt_LAB3) {
		return [TexRect cons_tex:[Resource get_tex:TEX_FREERUNSTARTICONS] rect:[FileCache get_cgrect_from_plist:TEX_FREERUNSTARTICONS idname:@"icon_lab3"]];
		
	} else {
		NSLog(@"FreeRunStartAtManager get_icon_for_loc is null");
		return NULL;
	}
}

+(NSString*)name_for_loc:(FreeRunStartAt)loc {
	if (loc == FreeRunStartAt_WORLD1) {
		return @"World 1";
	} else if (loc == FreeRunStartAt_TUTORIAL) {
		return @"Tutorial";
	} else if (loc == FreeRunStartAt_LAB1) {
		return @"Lab 1";
	} else if (loc == FreeRunStartAt_WORLD2) {
		return @"World 2";
	} else if (loc == FreeRunStartAt_LAB2) {
		return @"Lab 2";
	} else if (loc == FreeRunStartAt_WORLD3) {
		return @"World 3";
	} else if (loc == FreeRunStartAt_LAB3) {
		return @"Lab 3";
	} else {
		return @"ERROR";
	}
}

+(WorldStartAt)get_startingat {
	WorldStartAt rtv;
	FreeRunStartAt loc = [self get_starting_loc];
	if (loc == FreeRunStartAt_TUTORIAL || loc == FreeRunStartAt_WORLD1 || loc == FreeRunStartAt_LAB1) {
		rtv.world_num = WorldNum_1;
		
	} else if (loc == FreeRunStartAt_WORLD2 || loc == FreeRunStartAt_LAB2) {
		rtv.world_num = WorldNum_2;
		
	} else if (loc == FreeRunStartAt_WORLD3 || loc == FreeRunStartAt_LAB3) {
		rtv.world_num = WorldNum_3;
	} else {
		NSLog(@"get_startingat error");
	}
	
	
	if (loc == FreeRunStartAt_TUTORIAL) {
		rtv.tutorial = YES;
	} else {
		rtv.tutorial = NO;
	}
	
	if (loc == FreeRunStartAt_LAB1 || loc == FreeRunStartAt_LAB2 || loc == FreeRunStartAt_LAB3) {
		rtv.bg_start = BGMode_LAB;
		
	} else {
		rtv.bg_start = BGMode_NORMAL;
	}
	return rtv;
}
@end

@implementation GameWorldMode
@synthesize cur_world;
@synthesize cur_mode;

+(GameWorldMode*)cons_worldnum:(WorldNum)world {
	GameWorldMode *rtv = [[GameWorldMode alloc] init];
	rtv.cur_world = world;
	rtv.cur_mode = BGMode_NORMAL;
	return rtv;
}

-(WorldStartAt)get_next_world_startat {
	WorldStartAt rtv;
	rtv.tutorial = NO;
	rtv.bg_start = BGMode_NORMAL;
	rtv.world_num = cur_world;
	rtv.world_num++;
	if (rtv.world_num != WorldNum_1 && rtv.world_num != WorldNum_2 && rtv.world_num != WorldNum_3) {
		rtv.world_num = WorldNum_1;
	}
	return rtv;
}

-(FreeRunStartAt)get_freerun_progress {
	if (cur_mode == BGMode_NORMAL) {
		if (cur_world == WorldNum_1) {
			return FreeRunStartAt_WORLD1;
			
		} else if (cur_world == WorldNum_2) {
			return FreeRunStartAt_WORLD2;
			
		} else if (cur_world == WorldNum_3) {
			return FreeRunStartAt_WORLD3;
			
		} else { return 0; }
		
	} else {
		if (cur_world == WorldNum_1) {
			return FreeRunStartAt_LAB1;
			
		} else if (cur_world == WorldNum_2) {
			return FreeRunStartAt_LAB2;
			
		} else if (cur_world == WorldNum_3) {
			return FreeRunStartAt_LAB3;
			
		} else { return 0; }
	}
}
@end
