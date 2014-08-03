#import "Particle.h"
#import "UIIngameAnimation.h"

@interface OneUpParticle : Particle {
    int ct,ctmax;
}

+(OneUpParticle*)cons_pt:(CGPoint)pos;

@end

@interface OneUpUIAnimation : UIIngameAnimation
+(OneUpUIAnimation*)cons_pt:(CGPoint)pos;
@end