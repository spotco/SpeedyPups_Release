#import "CapeGameEngineLayer.h"

@interface CapeGameBossBomb : CapeGameObject {
	float out_ct;
	CGPoint out_vel;
}

+(CapeGameBossBomb*)cons_pos:(CGPoint)pos;
@end

@interface CapeGameBossPowerupRocket : CapeGameObject {
	float rotation_theta;
}
+(CapeGameBossPowerupRocket*)cons_pos:(CGPoint)pos;
@end
