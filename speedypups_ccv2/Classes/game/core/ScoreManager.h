#import <Foundation/Foundation.h>
#import "FreeRunStartAtManager.h"

@interface ScoreManager : NSObject {
	int score;
	float multiplier;
}

+(int)get_world_highscore:(WorldNum)world;
+(BOOL)set_world:(WorldNum)world highscore:(int)score;

+(ScoreManager*)cons;
-(void)increment_score:(int)amt;
-(void)increment_multiplier:(float)amt;
-(void)reset_multiplier;
-(int)get_score;
-(float)get_multiplier;
-(void)reset_score;
-(void)decrement_score:(int)amt;
@end
