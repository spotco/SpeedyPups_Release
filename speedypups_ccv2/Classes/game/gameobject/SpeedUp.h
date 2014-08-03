#import "GameObject.h"
#import "JumpPadParticle.h"

@interface SpeedUp : GameObject {
    id anim;
    int recharge_ct;
    Vec3D normal_vec;
}

+(SpeedUp*)cons_x:(float)x y:(float)y dirvec:(Vec3D)vec;

@end
