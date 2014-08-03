#import "ChallengeInfoTitleCardAnimation.h"
#import "FreeRunStartAtManager.h"

@interface FreeRunStartAtUnlockUIAnimation : ChallengeInfoTitleCardAnimation
+(FreeRunStartAtUnlockUIAnimation*)cons_for_unlocking:(FreeRunStartAt)startat;
@end

@interface FreePupsUIAnimation : FreeRunStartAtUnlockUIAnimation
+(FreePupsUIAnimation*)cons;
@end
