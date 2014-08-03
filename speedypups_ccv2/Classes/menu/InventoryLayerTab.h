#import "MenuCommon.h"

@interface InventoryLayerTab : TouchButton {
	CallBack *callback;
	float tar_scale_y;
	CCSprite *tabcover;
}
+(InventoryLayerTab*)cons_pt:(CGPoint)pt text:(NSString*)str cb:(CallBack*)cb;
-(void)update;
-(void)set_selected:(BOOL)t;
@end


@interface PollingButton : TouchButton {
	CallBack *poll;
	
	CGRect yes;
	CGRect no;
}
+(PollingButton*)cons_pt:(CGPoint)pt texkey:(NSString*)texkey yeskey:(NSString*)yeskey nokey:(NSString*)nokey poll:(CallBack*)poll click:(CallBack*)click;
@end;
