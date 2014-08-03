#import "GameObject.h"

@interface EnemyBomb : GameObject {
    CCSprite *body;
    CGPoint v;
    float vtheta;
    int ct;
    BOOL knockout;
}
+(EnemyBomb*)cons_pt:(CGPoint)pt v:(CGPoint)vel;
-(id)cons_pt:(CGPoint)pt v:(CGPoint)vel;
-(void)move:(GameEngineLayer*)g;
@end

@interface RelativePositionEnemyBomb : EnemyBomb {
	CGPoint player_rel_pos;
	int bg_to_front_ct;
	BOOL KILL;
}
+(RelativePositionEnemyBomb*)cons_pt:(CGPoint)pt v:(CGPoint)vel player:(CGPoint)player;
-(id)do_bg_to_front_anim;
@end

@interface BombSparkParticle : Particle {
    CGPoint vel;
    int ct;
	float sc;
}
+(BombSparkParticle*)cons_pt:(CGPoint)pt v:(CGPoint)v;
-(id)set_scale:(float)scale;
@end