#import "GameEngineStats.h"
#import "GameEngineLayer.h" 
#import "UICommon.h"
#import "ScoreManager.h"

@implementation GameEngineStats

NSValue* NSV(GEStat t) { return [NSValue value:&t withObjCType:@encode(GEStat)]; }

+(GameEngineStats*)cons {
	return [[GameEngineStats alloc] init];
}

-(id)init {
	self = [super init];
	stats = [NSMutableDictionary dictionary];
	return self;
}

-(void)increment:(GEStat)type {
	NSValue *kv = NSV(type);
	if ([stats objectForKey:kv] == nil) {
		stats[kv] = @1;
	} else {
		NSNumber *v = stats[kv];
		stats[kv] = [NSNumber numberWithInt:v.intValue+1];
	}
}

-(NSString*)get_disp_str_for_stat:(GEStat)type g:(GameEngineLayer *)g {
    if (type == GEStat_TIME) {
        return [UICommon parse_gameengine_time:g.get_time];
		
	} else if (type == GEStat_POINTS) {
		return strf("%d",[g.score get_score]);
		
    } else if (type == GEStat_BONES_COLLECTED) {
        return [NSString stringWithFormat:@"%d",g.get_num_bones];
        
    } else if (type == GEStat_DISTANCE) {
        return [NSString stringWithFormat:@"%.1fm",(g.player.position.x/100)];
        
    }
    
    
	NSValue *kv = NSV(type);
	if ([stats objectForKey:kv]) {
		NSNumber *v = stats[kv];
		return [NSString stringWithFormat:@"%d",v.intValue];
	} else {
		return @"0";
	}
}

-(void)copy_stats:(GameEngineStats*)copy {
	[stats removeAllObjects];
	for (NSValue *key in copy.dict) {
		stats[key] = copy.dict[key];
	}
}

-(NSDictionary*)dict {
	return stats;
}

-(NSArray*)get_all_stats {
	return @[
		NSV(GEStat_POINTS),
		NSV(GEStat_TIME),
		NSV(GEStat_BONES_COLLECTED),
		NSV(GEStat_DEATHS),
		NSV(GEStat_DISTANCE),
		NSV(GEStat_SECTIONS),
		NSV(GEStat_JUMPED),
		NSV(GEStat_DASHED),
		NSV(GEStat_DROWNED),
		NSV(GEStat_SPIKES),
		NSV(GEStat_FALLING),
		NSV(GEStat_ROBOT)
	];
}

@end
