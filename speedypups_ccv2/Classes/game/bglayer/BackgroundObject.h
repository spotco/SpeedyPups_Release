
#import "cocos2d.h"
#import "CCSprite.h"
#import "Common.h"

@interface BackgroundObject : CSF_CCSprite {
    float scrollspd_x;
    float scrollspd_y;
	
	float clamp_y_min,clamp_y_max;
}

@property(readwrite,assign) float scrollspd_x, scrollspd_y;
+(BackgroundObject*) backgroundFromTex:(CCTexture2D *)tex scrollspd_x:(float)spdx scrollspd_y:(float)spdy;
-(void) update_posx:(float)posx posy:(float)posy;
-(BackgroundObject*)set_clamp_y_min:(float)min max:(float)max;
@end

@interface StarsBackgroundObject : BackgroundObject
+(StarsBackgroundObject*)cons;
@end
