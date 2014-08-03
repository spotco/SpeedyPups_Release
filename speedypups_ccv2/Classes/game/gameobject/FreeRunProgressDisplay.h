#import "GameObject.h"

@interface FreeRunProgressDisplay : GameObject {
	BOOL lab;
}
+(FreeRunProgressDisplay*)cons_pt:(CGPoint)pt lab:(BOOL)lab;
@end
