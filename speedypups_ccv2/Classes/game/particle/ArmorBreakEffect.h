#import "Particle.h"

@interface ArmorBreakEffect : Particle {
    CGPoint vel;
    int ct;
}

+(void)cons_at:(CGPoint)pos in:(GameEngineLayer*)g;

@end
