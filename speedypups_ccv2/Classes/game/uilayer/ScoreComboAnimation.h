#import "UIIngameAnimation.h"

@interface ScoreComboAnimation : UIIngameAnimation {
	BOOL is_in;
	BOOL hold;
	float pct;
}

+(ScoreComboAnimation*)cons_combo:(float)combo;

@end
