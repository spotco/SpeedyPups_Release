#import "CCSprite.h"
#import "Vec3D.h"
@class GameEngineLayer;

@interface UIEnemyAlert : CCSprite {
	CCSprite *mainbody, *arrow;
	float enemy_alert_ui_ct;
}

+(UIEnemyAlert*)cons;
-(void)set_flash:(BOOL)v;
-(void)set_dir:(Vec3D)dir;
-(void)update:(GameEngineLayer*)g;
-(void)set_ct:(int)ct;

@end
