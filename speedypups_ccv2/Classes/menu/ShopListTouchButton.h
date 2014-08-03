#import "MenuCommon.h"
@class ItemInfo;

@interface ShopListTouchButton : TouchButton {
	BOOL has_clipping_area;
	CGRect clipping_area;
	
	float tar_scale;
}

@property(readwrite,strong) ItemInfo* sto_info;

+(ShopListTouchButton*)cons_pt:(CGPoint)pt info:(ItemInfo*)info cb:(CallBack *)tcb;

-(void)repool;

-(id)set_screen_clipping_area:(CGRect)clippingrect;
-(void)set_selected:(BOOL)t;
-(void)update;
@end