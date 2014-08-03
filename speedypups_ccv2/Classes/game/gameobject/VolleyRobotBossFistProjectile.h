#import "GameObject.h"
@class GameEngineLayer;

@interface VolleyRobotBossFistProjectile : GameObject {
	CGPoint startpos, tarpos;
	float time_left;
	float time_total;
	float groundlevel;
	int mode;
	
	CGPoint bosspos;
}
#define RobotBossFistProjectileDirection_AT_PLAYER 0
#define RobotBossFistProjectileDirection_AT_BOSS 1
#define RobotBossFistProjectileDirection_AT_CAT 2
@property(readwrite,assign) int direction;

+(VolleyRobotBossFistProjectile*)cons_g:(GameEngineLayer*)g relpos:(CGPoint)relpos tarpos:(CGPoint)tarpos time:(float)time groundlevel:(float)groundlevel;

-(id)set_startpos:(CGPoint)_startpos tarpos:(CGPoint)_tarpos time_left:(float)_time_left time_total:(float)_time_total;

-(id)mode_parabola_a;
-(id)mode_parabola_a2;
-(id)mode_parabola_b;
-(id)mode_line;
-(id)mode_parabola_at_cat;
-(id)mode_parabola_at_cat_left;

-(id)set_boss_pos:(CGPoint)pos;

-(float)time_left;

-(void)force_remove;
-(BOOL)should_remove;
-(void)do_remove:(GameEngineLayer*)g;
@end
