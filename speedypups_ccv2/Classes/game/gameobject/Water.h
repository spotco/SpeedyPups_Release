#import "GameObject.h"
#import "SplashEffect.h"
#import "GameRenderImplementation.h"
#import "FishGenerator.h"

@interface Water : GameObject {
    GLRenderObject* body;
	GLRenderObject* body_offset;
    
    float bwidth,bheight,offset_ct;
    
    BOOL activated;
    
    FishGenerator *fishes;
}

+(Water*)cons_x:(float)x y:(float)y width:(float)width height:(float)height;
-(CGPoint)get_size;

@end
