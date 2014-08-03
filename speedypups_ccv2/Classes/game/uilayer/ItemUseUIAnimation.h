#import "UIIngameAnimation.h"

@interface ItemUseUIAnimation : UIIngameAnimation {
	NSMutableArray *particles;
}

+(ItemUseUIAnimation*)cons_around:(CGPoint)pt;

@end
