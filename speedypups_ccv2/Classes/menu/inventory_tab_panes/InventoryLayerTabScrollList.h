#import "CCSprite.h"
#import "ShopListTouchButton.h"

@class CallBack;
@class GenericListTouchButton;

@interface InventoryLayerTabScrollList : NSObject {
	CCSprite *clipperholder;
	ClippingNode *clipper;
	CGPoint clipper_anchor;
	float clippedholder_y_min, clippedholder_y_max;
	CCSprite *can_scroll_down, *can_scroll_up;
	
	BOOL is_scroll;
	CGPoint last_scroll_pt;
	int scroll_move_ct;
	float vy;
	
	NSMutableArray *touches;
	
	int mult;
}

+(InventoryLayerTabScrollList*)cons_parent:(CCSprite*)parent add_to:(CCSprite*)add_to;
-(GenericListTouchButton*)add_tab:(CCTexture2D*)tex rect:(CGRect)rect main_text:(NSString*)main_text sub_text:(NSString*)sub_text callback:(CallBack*)cb;

-(void)clear_tabs;
-(int)get_num_tabs;

-(void)update;
-(void)touch_begin:(CGPoint)pt;
-(void)touch_move:(CGPoint)pt;
-(void)touch_end:(CGPoint)pt;

@end

@interface GenericListTouchButton : ShopListTouchButton {
	CCLabelTTF *main_text, *sub_text;
	CCSprite *disp_sprite;
}
@property(readwrite,strong) CallBack *val;
+(GenericListTouchButton*)cons_pt:(CGPoint)pt texrect:(TexRect*)texrect val:(CallBack*)val cb:(CallBack*)tcb;
-(void)repool;
-(void)set_main_text:(NSString*)s;
-(void)set_sub_text:(NSString*)s;
@end
