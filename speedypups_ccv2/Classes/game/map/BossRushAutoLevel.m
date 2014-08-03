#import "BossRushAutoLevel.h"

@interface BossRushAutoLevelState : AutoLevelState
+(BossRushAutoLevelState*)cons;
-(void)dispatch_event:(GEvent*)e;
-(int)get_display_count;
-(void)reset;
@end

@implementation BossRushAutoLevel

+(BossRushAutoLevel*)cons_with_glayer:(GameEngineLayer *)glayer {
    BossRushAutoLevel* a = [BossRushAutoLevel node];
    [a cons_with_glayer:glayer];
    [GEventDispatcher add_listener:a];
	return a;
}

-(void)cons_with_glayer:(GameEngineLayer *)glayer {
    cur_state = [BossRushAutoLevelState cons];
    tglayer = glayer;
	
    map_sections = [[NSMutableArray alloc] init];
    stored = [[NSMutableArray alloc] init];
    queued_sections = [[NSMutableArray alloc] init];
    [self load_into_queue:[cur_state get_level]];
}

-(int)get_display_count {
	return [(BossRushAutoLevelState*)cur_state get_display_count];
}

-(void)reset {
	[(BossRushAutoLevelState*)cur_state reset];
	[super reset];
}

-(void)dispatch_event:(GEvent *)e {
	[(BossRushAutoLevelState*)cur_state dispatch_event:e];
	[super dispatch_event:e];
}

@end

typedef enum BossRushState{
	BossRushState_Start,
	BossRushState_Boss1Start,
	BossRushState_Boss1Battle,
	BossRushState_Boss2Start,
	BossRushState_Boss2Battle,
	BossRushState_Boss3Start,
	BossRushState_Boss3Battle,
	BossRushState_Boss4Battle,
	BossRushState_End
} BossRushState;

@implementation BossRushAutoLevelState {
	BossRushState cur_state;
}

+(BossRushAutoLevelState*)cons {
	return [[BossRushAutoLevelState alloc] init];
}

-(id)init {
	self = [super init];
	
	cur_state = BossRushState_Start;
	
	return self;
}

-(int)get_display_count {
	if (cur_state == BossRushState_Start || cur_state == BossRushState_Boss1Start || cur_state == BossRushState_Boss1Battle) {
		return 0;
	} else if (cur_state == BossRushState_Boss2Start || cur_state == BossRushState_Boss2Battle) {
		return 1;
	} else if (cur_state == BossRushState_Boss3Start || cur_state == BossRushState_Boss3Battle) {
		return 2;
	} else if (cur_state == BossRushState_Boss4Battle) {
		return 3;
	} else {
		return 4;
	}
}

-(void)dispatch_event:(GEvent *)e {
	if (e.type == GEventType_BOSS1_ACTIVATE) {
		cur_state = BossRushState_Boss1Battle;
		
	} else if (e.type == GEventType_BOSS1_DEFEATED) {
		cur_state = BossRushState_Boss2Start;
		
	} else if (e.type == GEventType_BOSS2_ACTIVATE) {
		cur_state = BossRushState_Boss2Battle;
		
	} else if (e.type == GEventType_BOSS2_DEFEATED) {
		cur_state = BossRushState_Boss3Start;
		
	} else if (e.type == GEventType_BOSS3_ACTIVATE) {
		cur_state = BossRushState_Boss3Battle;
		
	} else if (e.type == GEventType_BEGIN_BOSS_CAPE_GAME) {
		cur_state = BossRushState_Boss4Battle;
		
	} else if (e.type == GEventType_BOSS3_DEFEATED) {
		cur_state = BossRushState_End;
		
	}
}

-(void)reset {
	cur_state = BossRushState_Boss1Start;
}

-(NSString*)get_level {
	if (cur_state == BossRushState_Start) {
		cur_state = BossRushState_Boss1Start;
		return @"labintro_entrance";
		
	} else if (cur_state == BossRushState_Boss1Start) {
		return @"boss1_start";
		
	} else if (cur_state == BossRushState_Boss1Battle) {
		return @"boss1_area";
		
	} else if (cur_state == BossRushState_Boss2Start) {
		return @"boss2_start";
		
	} else if (cur_state == BossRushState_Boss2Battle) {
		return @"boss2_area";
		
	} else if (cur_state == BossRushState_Boss3Start) {
		return @"boss3_start";
		
	} else if (cur_state == BossRushState_Boss3Battle) {
		return @"boss3_area";
		
	} else {
		return @"";
	}
	
}

@end
