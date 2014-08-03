#import "cocos2d.h"
#import "GEventDispatcher.h"
@class MainSlotItemPane;
@class InventoryLayerTab;

@interface InventoryTabPane : CCSprite
-(void)set_pane_open:(BOOL)t;
-(void)update;
-(void)touch_begin:(CGPoint)pt;
-(void)touch_move:(CGPoint)pt;
-(void)touch_end:(CGPoint)pt;
@end

typedef enum InventoryLayerTab_Index {
	InventoryLayerTab_Index_Inventory,
	InventoryLayerTab_Index_Upgrades,
	InventoryLayerTab_Index_Settings,
	InventoryLayerTab_Index_Prizes,
	InventoryLayerTab_Index_Extras
} InventoryLayerTab_Index;

@interface MainMenuInventoryLayer : CCLayer <GEventListener> {
    CCSprite *inventory_window;
	 
	NSMutableArray *tabs;
	InventoryLayerTab *tab_inventory;
	InventoryLayerTab *tab_upgrades;
	InventoryLayerTab *tab_settings;
	InventoryLayerTab *tab_prizes;
	InventoryLayerTab *tab_extras;
	
	NSMutableArray *tabpanes;
	InventoryTabPane *tabpane_inventory;
	InventoryTabPane *tabpane_upgrades;
	InventoryTabPane *tabpane_settings;
	InventoryTabPane *tabpane_prizes;
	InventoryTabPane *tabpane_extras;
}

+(MainMenuInventoryLayer*)cons;
-(BOOL)window_open;
-(void)touch_begin:(CGPoint)pt;
-(void)touch_move:(CGPoint)pt;
-(void)touch_end:(CGPoint)pt;
-(void)update;
@end
