#import "UIIngameAnimation.h"
#import "ChallengeInfoTitleCardAnimation.h"
#import "FreeRunStartAtManager.h"

typedef enum _FillerProgressUIAnimationPct {
	FillerProgressUIAnimation_ONE = 0,
	FillerProgressUIAnimation_TWO = 1,
	FillerProgressUIAnimation_THREE = 2
} FillerProgressUIAnimationPct;

@interface FillerProgressUIAnimation : ChallengeInfoTitleCardAnimation
+(FillerProgressUIAnimation*)cons_at:(FreeRunStartAt)pos pct:(FillerProgressUIAnimationPct)pct;
@end
