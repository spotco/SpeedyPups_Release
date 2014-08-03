#import "GameObject.h"
@class MagnetItemEffectParticle;

@interface MagnetItemEffect : GameObject <GEventListener> {
    NSArray* particles;
    BOOL kill;
}

+(MagnetItemEffect*)cons;
-(MagnetItemEffectParticle*)conspt_center:(CGPoint)center radius:(float)radius phase:(float)phase;
@end

@interface HeartItemEffect : MagnetItemEffect
+(HeartItemEffect*)cons;
@end

@interface ClockItemEffect : MagnetItemEffect
+(ClockItemEffect*)cons;
@end