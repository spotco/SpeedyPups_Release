#import "GameObject.h"
@class ChallengeInfo;

@interface ChallengeEnd : GameObject {
    ChallengeInfo *info;
    BOOL procced;
	
	int particlect;
}

+(ChallengeEnd*)cons_pt:(CGPoint)pt;

@end
