#import "MenuCommon.h"

@interface ShopTabTouchButton : TouchButton {
	float tar_scale_y;
	CCSprite *tabcover;
}

+(ShopTabTouchButton*)cons_pt:(CGPoint)pt text:(NSString*)text cb:(CallBack*)tcb;
-(void)update;
-(void)set_selected:(BOOL)t;
@end
