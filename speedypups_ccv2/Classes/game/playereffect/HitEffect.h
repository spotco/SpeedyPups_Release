#import "PlayerEffectParams.h"
#import "GEventDispatcher.h"

@class FlashEffect;

@interface HitEffect : PlayerEffectParams

+(HitEffect*)cons_from:(PlayerEffectParams*)base time:(int)time;
+(HitEffect*)cons_from:(PlayerEffectParams*)base time:(int)time nograv:(BOOL)nograv;
@property(readwrite,assign) player_anim_mode tmode;
@property(readwrite,assign) BOOL nograv;
@end


@interface FlashHitEffect : HitEffect
+(FlashHitEffect*)cons_from:(PlayerEffectParams*)base time:(int)time;
@end