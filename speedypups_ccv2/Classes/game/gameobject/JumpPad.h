#import "GameObject.h"
#import "JumpPadParticle.h"
#import "FileCache.h"

@interface JumpPad : GameObject {
    id anim,stand,labanim;
    Vec3D normal_vec;
    int recharge_ct;
    BOOL activated;
    
    CCSprite *body,*labbody;
}

+(JumpPad*)cons_x:(float)x y:(float)y dirvec:(Vec3D)vec;

@end
