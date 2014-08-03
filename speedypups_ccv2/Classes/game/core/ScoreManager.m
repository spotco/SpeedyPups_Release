#import "ScoreManager.h"
#import "DataStore.h"
#import "GEventDispatcher.h"

#define WORLD_HIGHSCORE(x) [NSString stringWithFormat:@"world_%d_highscore",x]

@implementation ScoreManager
+(ScoreManager*)cons {
	return [[ScoreManager alloc] init];
}

+(int)get_world_highscore:(WorldNum)world {
	return [DataStore get_int_for_key:WORLD_HIGHSCORE(world)];
}

+(BOOL)set_world:(WorldNum)world highscore:(int)score {
	int world_highscore = [self get_world_highscore:world];
	if (score > world_highscore) {
		[DataStore set_key:WORLD_HIGHSCORE(world) int_value:score];
		return YES;
	}
	return NO;
}

-(id)init {
	self = [super init];
	score = 0;
	multiplier = 1;
	return self;
}

-(void)increment_score:(int)amt {
	score += amt * multiplier;
}

-(void)increment_multiplier:(float)amt {
	amt *= 3;
	
	if (floor(multiplier) < floor(multiplier + amt) && multiplier < 5) {
		[GEventDispatcher push_event:[[GEvent cons_type:GEventType_COMBO_DISP_ANIM] add_f1:multiplier+amt f2:0]];
	}
	
	multiplier += amt;
	multiplier = MIN(5,multiplier);
}

-(void)reset_multiplier {
	multiplier = 1;
}

-(void)reset_score {
	score = 0;
}

-(int)get_score {
	return score;
}

-(float)get_multiplier {
	return multiplier;
}

-(void)decrement_score:(int)amt {
	score -= amt / multiplier;
	if (score < 0) score = 0;
}
@end
