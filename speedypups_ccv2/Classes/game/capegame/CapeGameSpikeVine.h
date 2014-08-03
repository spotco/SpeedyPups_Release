#import "CapeGameEngineLayer.h"
#import "PolyLib.h"
#import "Common.h"

@interface CapeGameSpikeVine : CapeGameObject {
    GLRenderObject *top,*bottom,*center;
    SATPoly r_hitbox;
	Vec3D dir_vec;
    
    BOOL active;
}

+(CapeGameSpikeVine*)cons_pt1:(CGPoint)pt1 pt2:(CGPoint)pt2;

@end
