#import "GameObject.h"
#import "GameItemCommon.h"
#import "DogBone.h"

@interface ItemGen : DogBone {
	GameItem item;
	BOOL immediate;
}
+(ItemGen*)cons_pt:(CGPoint)pt;
+(ItemGen*)cons_pt:(CGPoint)pt item:(GameItem)imm_item;
@end
