#import "MainMenuLayer.h"
#import "ShopRecord.h"
@class ShopListTouchButton;
@class ShopTabTouchButton;
@class TouchButton;

@interface NMenuTabShopPage : NMenuPage <GEventListener> {
	CCSprite *tabbedpane;
	
	CCLabelTTF *itemname;
	CCLabelTTF *itemdesc;
	CCLabelTTF *itemprice;
	
	CCNode *itemprice_x;
	CCSprite *itemprice_icon;
	
	CCSprite *price_disp;
	
	CCSprite *buy_button_pane;
	CCSprite *loading_button_pane;
	TouchButton *buybutton;
	CCLabelTTF *notenoughdisp;
	
	CCLabelTTF *total_disp;
	
	NSString *sto_val;
	int sto_price;
	
	NSMutableArray *touches;
	
	BOOL is_scroll;
	CGPoint last_scroll_pt;
	int scroll_move_ct;
	float vy;
	float clippedholder_y_min, clippedholder_y_max;
	
	CCSprite *clipperholder;
	ClippingNode *clipper;
	CGPoint clipper_anchor;
	
	ShopTab current_tab;
	int current_tab_index;
	int current_scroll_index;
	
	NSMutableArray *scroll_items;
	
	CCSprite *can_scroll_up, *can_scroll_down;
	
	ShopListTouchButton *cur_selected_list_button;
	ShopTabTouchButton *cur_selected_tab;
	
	NSMutableArray *particles;
	CCSprite *particleholder;
}

+(NMenuTabShopPage*)cons;
@end
