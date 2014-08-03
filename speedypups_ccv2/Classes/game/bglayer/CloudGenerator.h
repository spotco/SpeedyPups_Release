#import "BackgroundObject.h"
#import "cocos2d.h"

@interface Cloud : CSF_CCSprite {
	float movspd;
}
+(Cloud*)cons_pt:(CGPoint)pt sc:(float)sc texkey:(NSString*)texkey scaley:(float)sy;
-(void)update_dv:(CGPoint)dv;
-(void)repool;
@property(readwrite,assign) float scaley;
@property(readwrite,assign) float speedmult;
@end

@interface CloudGenerator : BackgroundObject {
    NSMutableArray *clouds;
    float prevx,prevy;
    
    int nextct,alternator;
	
	NSString* texkey;
	float scaley;
	float speedmult;
	int generatespeed;
    
}
+(CloudGenerator*)cons;
+(CloudGenerator*)cons_texkey:(NSString*)key scaley:(float)sy;
-(void)random_seed_clouds;
-(CloudGenerator*)set_speedmult:(float)spd;
-(CloudGenerator*)set_generate_speed:(int)spd;
@end
