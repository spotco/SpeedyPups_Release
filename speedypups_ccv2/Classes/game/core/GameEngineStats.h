#import <Foundation/Foundation.h>
@class GameEngineLayer;

typedef enum {
	GEStat_POINTS,
	GEStat_TIME,
	GEStat_BONES_COLLECTED,
	GEStat_DEATHS,
	GEStat_DISTANCE,
	GEStat_SECTIONS,
	GEStat_JUMPED,
	GEStat_DASHED,
	GEStat_DROWNED,
	GEStat_SPIKES,
	GEStat_FALLING,
	GEStat_ROBOT
} GEStat;

NSValue* NSV(GEStat t);

@interface GameEngineStats : NSObject {
	NSMutableDictionary *stats;
}

+(GameEngineStats*)cons;
-(void)increment:(GEStat)type;
-(NSString*)get_disp_str_for_stat:(GEStat)type g:(GameEngineLayer*)g;
-(NSArray*)get_all_stats;

-(void)copy_stats:(GameEngineStats*)copy;
@end
