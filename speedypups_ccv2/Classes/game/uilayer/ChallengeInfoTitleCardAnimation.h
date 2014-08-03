#import "UIIngameAnimation.h"
#import "GEventDispatcher.h"
@class GameEngineLayer;

typedef enum {
	TitleCardMode_DOWN,
	TitleCardMode_STAY,
	TitleCardMode_UP
} TitleCardMode;

@interface ChallengeInfoTitleCardAnimation : UIIngameAnimation {
	CCSprite *base;
	float animct;
	TitleCardMode mode;
}
@property(readwrite,assign) int TRANS_LEN,STAY_LEN;
@property(readwrite,assign) float YPOS_START,YPOS_END;
+(ChallengeInfoTitleCardAnimation*)cons_g:(GameEngineLayer*)g;
-(void)on_remove;
@end

@interface FreerunInfoTitleCardAnimation : ChallengeInfoTitleCardAnimation
+(FreerunInfoTitleCardAnimation*)cons_g:(GameEngineLayer*)g;
@end

@interface TutorialInfoTitleCardAnimation : ChallengeInfoTitleCardAnimation <GEventListener> {
	NSString *msg;
}
+(TutorialInfoTitleCardAnimation*)cons_g:(GameEngineLayer*)g msg:(NSString*)msg;
+(TutorialInfoTitleCardAnimation*)cons_msg:(NSString*)msg; //not used
@end

@interface MessageTitleCardAnimation :ChallengeInfoTitleCardAnimation
+(MessageTitleCardAnimation*)cons_msg:(NSString*)msg;
@end