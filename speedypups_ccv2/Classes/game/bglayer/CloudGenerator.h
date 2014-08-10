#import "BackgroundObject.h"
#import "cocos2d.h"
#import "BatchSpriteManager.h" 

@interface Cloud : CSF_CCSprite <BatchableSprite> {
	float movspd;
}
+(Cloud*)cons_pt:(CGPoint)pt sc:(float)sc scaley:(float)sy;
-(void)update_dv:(CGPoint)dv;
-(void)repool;
@property(readwrite,assign) float scaley;
@property(readwrite,assign) float speedmult;
@end

@interface CloudGenerator : BackgroundObject {
    NSMutableArray *clouds;
    float prevx,prevy;
    
    int nextct,alternator;
	float scaley;
	float speedmult;
	int generatespeed;
    
}
+(CloudGenerator*)cons;
-(void)random_seed_clouds;
-(CloudGenerator*)set_speedmult:(float)spd;
-(CloudGenerator*)set_generate_speed:(int)spd;
@end
