#import "PlayerEffectParams.h"

@interface DogRocketEffect : PlayerEffectParams {
    int fulltime;
	float sound_ct;
}

+(DogRocketEffect*)cons_from:(PlayerEffectParams*)base time:(int)time;

@end
