#import "MainMenuInventoryLayer.h"
#import "GameItemCommon.h" 
@class InventoryLayerTabScrollList;
@class TouchButton;
@class GenericListTouchButton;


@interface InventoryTabPane_Inventory : InventoryTabPane {
	InventoryLayerTabScrollList *list;
	
	NSMutableArray *touches;
	TouchButton *equip_button;
	CCLabelTTF *equipped_label;
	
	CCLabelTTF *name_disp;
	CCLabelTTF *desc_disp;
	
	GameItem selected_item;
	
	NSMutableDictionary *added_items;
	
	GenericListTouchButton *bones_button;
	GenericListTouchButton *coins_button;
	CCMenuItemImage *wheel_ad_button;
}

+(InventoryTabPane_Inventory*)cons:(CCSprite*)parent;
-(void)update_available_items;

@end
