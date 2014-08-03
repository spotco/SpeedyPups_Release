#import "Challenge.h"
#import "DataStore.h"
#import "UICommon.h"
#import "Common.h"
#import "Resource.h"
#import "FileCache.h"


@implementation ChallengeInfo

@synthesize map_name;
@synthesize ct;
@synthesize type,reward;
@synthesize world;

+(ChallengeInfo*)cons_name:(NSString *)map_name type:(ChallengeType)type ct:(int)ct reward:(int)rw world:(WorldNum)w {
    ChallengeInfo *i = [[ChallengeInfo alloc] init];
    [i setMap_name:map_name];
    [i setType:type];
    [i setCt:ct];
    [i setReward:rw];
	[i setWorld:w];
    return i;
}

+(ChallengeInfo*)cons_name:(NSString *)map_name type:(ChallengeType)type ct:(int)ct reward:(int)rw {
	return [self cons_name:map_name type:type ct:ct reward:rw world:WorldNum_1];
}

-(NSString*)to_string {
    ChallengeInfo *cc = self;
    if (cc.type == ChallengeType_COLLECT_BONES) {
        return [NSString stringWithFormat:@"Collect at least %d bone(s) in one run.",cc.ct];
        
    } else if (cc.type == ChallengeType_TIMED) {
        return [NSString stringWithFormat:@"Complete this level in %@ or less.",[UICommon parse_gameengine_time:cc.ct]];
        
    } else if (cc.type == ChallengeType_FIND_SECRET) {
        return @"Find the treat.";
        
	} else if (cc.type == ChallengeType_BOSSRUSH) {
		return @"Beat all the bosses!";
		
    } else {
        return @"ERROR";
    }
}

@end

@implementation ChallengeRecord

static NSArray* _CHALLENGES;

+(void)initialize {
    _CHALLENGES = @[
        [ChallengeInfo cons_name:@"tutorial_breakrocks" type:ChallengeType_COLLECT_BONES ct:18 reward:1],
        [ChallengeInfo cons_name:@"tutorial_spikes" type:ChallengeType_FIND_SECRET ct:1 reward:1],
        [ChallengeInfo cons_name:@"tutorial_spikevine" type:ChallengeType_TIMED ct:1000 reward:1],
        [ChallengeInfo cons_name:@"tutorial_swipeget" type:ChallengeType_COLLECT_BONES ct:39 reward:1],
		[ChallengeInfo cons_name:@"capegame_easy_challenge" type:ChallengeType_FIND_SECRET ct:1 reward:1],
        [ChallengeInfo cons_name:@"easy_world1" type:ChallengeType_FIND_SECRET ct:1 reward:1],
        [ChallengeInfo cons_name:@"tutorial_swingvine" type:ChallengeType_COLLECT_BONES ct:36 reward:1 world:WorldNum_2],
        [ChallengeInfo cons_name:@"classic_trickytreas" type:ChallengeType_COLLECT_BONES ct:28 reward:2],
        [ChallengeInfo cons_name:@"easy_gottagofast" type:ChallengeType_COLLECT_BONES ct:60 reward:1],
        [ChallengeInfo cons_name:@"filler_directdrop" type:ChallengeType_FIND_SECRET ct:1 reward:1 world:WorldNum_2],
        [ChallengeInfo cons_name:@"classic_smgislands" type:ChallengeType_COLLECT_BONES ct:52 reward:1 world:WorldNum_2],
        [ChallengeInfo cons_name:@"swingvine_bounswindodg" type:ChallengeType_TIMED ct:1000 reward:2 world:WorldNum_2],
		[ChallengeInfo cons_name:@"classic_nubcave" type:ChallengeType_FIND_SECRET ct:1 reward:1],
		[ChallengeInfo cons_name:@"swingvine_awesome" type:ChallengeType_COLLECT_BONES ct:67 reward:3 world:WorldNum_2],
		[ChallengeInfo cons_name:@"swingvine_hillvine" type:ChallengeType_FIND_SECRET ct:1 reward:1 world:WorldNum_2],
		[ChallengeInfo cons_name:@"classic_nubcave" type:ChallengeType_COLLECT_BONES ct:77 reward:1],
		[ChallengeInfo cons_name:@"classic_manyoptredux" type:ChallengeType_TIMED ct:1550 reward:3 world:WorldNum_3],
		[ChallengeInfo cons_name:@"filler_genome" type:ChallengeType_COLLECT_BONES ct:57 reward:2],
		[ChallengeInfo cons_name:@"jumppad_crazyloop" type:ChallengeType_FIND_SECRET ct:1 reward:1 world:WorldNum_1],
		[ChallengeInfo cons_name:@"swingvine_totalmix" type:ChallengeType_COLLECT_BONES ct:54 reward:1 world:WorldNum_2],
		[ChallengeInfo cons_name:@"labintro_tutoriallauncher" type:ChallengeType_COLLECT_BONES ct:80 reward:2],
		[ChallengeInfo cons_name:@"jumppad_spikeceil" type:ChallengeType_FIND_SECRET ct:1 reward:1 world:WorldNum_1],
		[ChallengeInfo cons_name:@"lab_alladat_challenge" type:ChallengeType_TIMED ct:2600 reward:2 world:WorldNum_3],
		[ChallengeInfo cons_name:@"capegame_test_challenge" type:ChallengeType_FIND_SECRET ct:1 reward:1],
		[ChallengeInfo cons_name:@"lab_rocketarmy_challenge" type:ChallengeType_COLLECT_BONES ct:87 reward:2 world:WorldNum_3],
		[ChallengeInfo cons_name:@"jumppad_jumpgap" type:ChallengeType_FIND_SECRET ct:1 reward:1 world:WorldNum_2],
		[ChallengeInfo cons_name:@"hard_compilation" type:ChallengeType_TIMED ct:1830 reward:2 world:WorldNum_3],
		[ChallengeInfo cons_name:@"capegame_creative_challenge" type:ChallengeType_FIND_SECRET ct:1 reward:1],
		[ChallengeInfo cons_name:@"hard_sliptwist" type:ChallengeType_COLLECT_BONES ct:70 reward:3 world:WorldNum_3],
		[ChallengeInfo cons_name:@"connector_challenge_bossrush" type:ChallengeType_BOSSRUSH ct:1 reward:5 world:WorldNum_2]
    ];
}

+(TexRect*)get_for:(ChallengeType)type {
	NSString *tar = @"";
	
	if (type == ChallengeType_COLLECT_BONES) {
		tar = @"challengeicon_bone";
	} else if (type == ChallengeType_FIND_SECRET) {
		tar = @"challengeicon_coin";
	} else if (type == ChallengeType_TIMED) {
		tar = @"challengeicon_time";
	} else if (type == ChallengeType_BOSSRUSH) {
		tar = @"challengeicon_bossrush";
	}
	
	return [TexRect cons_tex:[Resource get_tex:TEX_NMENU_LEVELSELOBJ]
						rect:[FileCache get_cgrect_from_plist:TEX_NMENU_LEVELSELOBJ idname:tar]];
}

+(TexRect*)get_preview_for:(ChallengeType)type {
	NSString *cle = @"";
	if (type == ChallengeType_COLLECT_BONES) {
		cle = @"preview_collect_bones";
	} else if (type == ChallengeType_FIND_SECRET) {
		cle = @"preview_find_secrets";
	} else if (type == ChallengeType_TIMED) {
		cle = @"preview_timed";
	} else if (type == ChallengeType_BOSSRUSH) {
		cle = @"preview_bossrush";
	}
	return [TexRect cons_tex:[Resource get_tex:TEX_NMENU_LEVELSELOBJ]
						rect:[FileCache get_cgrect_from_plist:TEX_NMENU_LEVELSELOBJ idname:cle]];
}

+(TexRect*)get_small_preview_for:(ChallengeType)type {
	NSString *cle = @"";
	if (type == ChallengeType_COLLECT_BONES) {
		cle = @"preview_collect_bones_small";
	} else if (type == ChallengeType_FIND_SECRET) {
		cle = @"preview_find_secrets_small";
	} else if (type == ChallengeType_TIMED) {
		cle = @"preview_timed_small";
	} else if (type == ChallengeType_BOSSRUSH) {
		cle = @"preview_bossrush_small";
	}
	return [TexRect cons_tex:[Resource get_tex:TEX_NMENU_LEVELSELOBJ]
						rect:[FileCache get_cgrect_from_plist:TEX_NMENU_LEVELSELOBJ idname:cle]];
}

+(int)get_number_for_challenge:(ChallengeInfo *)c {
    return (int)[_CHALLENGES indexOfObject:c];
}

+(int)get_num_challenges {
    return (int)[_CHALLENGES count];
}

+(ChallengeInfo*)get_challenge_number:(int)i {
    if (i >= [self get_num_challenges]) [NSException raise:@"Challenge Not Found:" format:@"%d",i];
    return _CHALLENGES[i];
}

+(BOOL)get_beaten_challenge:(int)i {
    return [DataStore get_int_for_key:[self challenge_to_key:i]];
}

+(void)set_beaten_challenge:(int)i to:(BOOL)k {
    [DataStore set_key:[self challenge_to_key:i] int_value:k];
}

+(NSString*)challenge_to_key:(int)i {
    return [NSString stringWithFormat:@"challenge_%d",i];
}

+(int)get_highest_available_challenge {
    int max = 0;
    for (int i = 0; i<[self get_num_challenges]; i++) {
        if ([self get_beaten_challenge:i]) {
            max = i+1;
        }
    }
    if (max > [self get_num_challenges]) {
        max = [self get_num_challenges];
    }
    return max;
}

@end
