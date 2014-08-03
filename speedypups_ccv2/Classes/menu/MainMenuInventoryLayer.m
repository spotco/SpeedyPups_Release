#import "MainMenuInventoryLayer.h"
#import "Resource.h"
#import "FileCache.h"
#import "MenuCommon.h"
#import "UserInventory.h"
#import "GameItemCommon.h"
#import "Player.h"
#import "AudioManager.h" 
#import "InventoryLayerTab.h"
#import "DataStore.h"
#import "WebRequest.h"
#import "InventoryTabPane_Inventory.h"
#import "InventoryTabPane_Upgrades.h" 
#import "InventoryTabPane_Settings.h"
#import "InventoryTabPane_Prizes.h"
#import "InventoryTabPane_Extras.h"

#import "AudioManager.h"

@implementation InventoryTabPane
-(void)set_pane_open:(BOOL)t{}
-(void)update{}
-(void)touch_begin:(CGPoint)pt{}
-(void)touch_move:(CGPoint)pt{}
-(void)touch_end:(CGPoint)pt{};
@end

@implementation MainMenuInventoryLayer

+(MainMenuInventoryLayer*)cons {
    return [MainMenuInventoryLayer node];
}

-(id)init {
    self = [super init];
    
    [GEventDispatcher add_listener:self];
	 
    inventory_window = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_NMENU_ITEMS]
                                              rect:[FileCache get_cgrect_from_plist:TEX_NMENU_ITEMS idname:@"nmenu_inventorypane"]];
    [inventory_window setPosition:[Common screen_pctwid:0.5 pcthei:0.55]];
    [self addChild:inventory_window];
	
    CCMenuItem *closebutton = [MenuCommon item_from:TEX_NMENU_ITEMS
                                             rect:@"nmenu_closebutton"
                                              tar:self sel:@selector(close)
                                              pos:CGPointZero];
	[closebutton setScale:1];
    [closebutton setPosition:[Common pct_of_obj:inventory_window pctx:0.975 pcty:0.95]];
	CCMenu *invmh = [CCMenu menuWithItems:closebutton, nil];
	[invmh setPosition:CGPointZero];
    [inventory_window addChild:invmh];
    [inventory_window setVisible:NO];
	
	
	[self cons_panes];
	[self cons_tabs];

	
    return self;
}

-(void)cons_panes {
	tabpanes = [NSMutableArray array];
	
	tabpane_inventory = [InventoryTabPane_Inventory cons:inventory_window];
	tabpane_upgrades = [InventoryTabPane_Upgrades cons:inventory_window];
	tabpane_settings = [InventoryTabPane_Settings cons:inventory_window];
	tabpane_prizes = [InventoryTabPane_Prizes cons:inventory_window];
	tabpane_extras = [InventoryTabPane_Extras cons:inventory_window];
	
	[inventory_window addChild:tabpane_inventory];
	[inventory_window addChild:tabpane_upgrades];
	[inventory_window addChild:tabpane_settings];
	[inventory_window addChild:tabpane_prizes];
	[inventory_window addChild:tabpane_extras];
	
	[tabpanes addObject:tabpane_inventory];
	[tabpanes addObject:tabpane_upgrades];
	[tabpanes addObject:tabpane_settings];
	[tabpanes addObject:tabpane_prizes];
	[tabpanes addObject:tabpane_extras];
	
	for (InventoryTabPane *pane in tabpanes) [pane set_pane_open:NO];
	[tabpane_inventory set_pane_open:YES];
}

-(void)cons_tabs {
	tabs = [NSMutableArray array];
	CGPoint lefttab_pos = [Common pct_of_obj:inventory_window pctx:0 pcty:0.985];
	tab_inventory = [InventoryLayerTab cons_pt:ccp(lefttab_pos.x+1,lefttab_pos.y)
										  text:@"Inventory"
											cb:[Common cons_callback:self sel:@selector(tab_inventory)]];
	
	CGRect tab_inventory_boundingbox = tab_inventory.boundingBox;
	tab_inventory_boundingbox.size.width /= CC_CONTENT_SCALE_FACTOR();
	
	tab_upgrades = [InventoryLayerTab cons_pt:ccp(tab_inventory.position.x + tab_inventory_boundingbox.size.width,tab_inventory.position.y)
										 text:@"Upgrades"
										   cb:[Common cons_callback:self sel:@selector(tab_upgrades)]];
	
	tab_settings = [InventoryLayerTab cons_pt:ccp(tab_inventory.position.x + tab_inventory_boundingbox.size.width*2,tab_inventory.position.y)
										 text:@"Settings"
										   cb:[Common cons_callback:self sel:@selector(tab_settings)]];
	
	tab_prizes = [InventoryLayerTab cons_pt:ccp(tab_inventory.position.x + tab_inventory_boundingbox.size.width*3,tab_inventory.position.y)
									   text:@"Prizes "
										 cb:[Common cons_callback:self sel:@selector(tab_prizes)]];
	
	tab_extras = [InventoryLayerTab cons_pt:ccp(tab_inventory.position.x + tab_inventory_boundingbox.size.width*4,tab_inventory.position.y)
									   text:@"Extras"
										 cb:[Common cons_callback:self sel:@selector(tab_extras)]];
	
	[inventory_window addChild:tab_inventory];
	[inventory_window addChild:tab_upgrades];
	[inventory_window addChild:tab_settings];
	[inventory_window addChild:tab_prizes];
	[inventory_window addChild:tab_extras];
	
	[tabs addObject:tab_inventory];
	[tabs addObject:tab_upgrades];
	[tabs addObject:tab_settings];
	[tabs addObject:tab_prizes];
	[tabs addObject:tab_extras];
	
	for (InventoryLayerTab *tab in tabs) [tab set_selected:NO];
	[tab_inventory set_selected:YES];
}

-(void)unselect_all {
	for (InventoryLayerTab *tab in tabs) [tab set_selected:NO];
	for (InventoryTabPane *pane in tabpanes) [pane set_pane_open:NO];
}

-(void)tab_inventory {
	[self unselect_all];
	[tab_inventory set_selected:YES];
	[tabpane_inventory set_pane_open:YES];
	[AudioManager playsfx:SFX_MENU_UP];
}

-(void)tab_settings {
	[self unselect_all];
	[tab_settings set_selected:YES];
	[tabpane_settings set_pane_open:YES];
	[AudioManager playsfx:SFX_MENU_UP];
}

-(void)tab_upgrades {
	[self unselect_all];
	[tab_upgrades set_selected:YES];
	[tabpane_upgrades set_pane_open:YES];
	[AudioManager playsfx:SFX_MENU_UP];
}

-(void)tab_extras {
	[self unselect_all];
	[tab_extras set_selected:YES];
	[tabpane_extras set_pane_open:YES];
	[AudioManager playsfx:SFX_MENU_UP];
}

-(void)tab_prizes {
	[self unselect_all];
	[tab_prizes set_selected:YES];
	[tabpane_prizes set_pane_open:YES];
	[AudioManager playsfx:SFX_MENU_UP];
}

-(void)update {
	for (InventoryLayerTab *tab in tabs) [tab update];
	for (InventoryTabPane *pane in tabpanes) [pane update];
}

-(void)open:(InventoryLayerTab_Index)page {
    [inventory_window setVisible:YES];
	[AudioManager playsfx:SFX_MENU_UP];
	if (page == InventoryLayerTab_Index_Inventory) {
		[self tab_inventory];
	} else if (page == InventoryLayerTab_Index_Upgrades) {
		[self tab_upgrades];
	} else if (page == InventoryLayerTab_Index_Settings) {
		[self tab_settings];
	} else if (page == InventoryLayerTab_Index_Prizes) {
		[self tab_prizes];
	} else if (page == InventoryLayerTab_Index_Extras) {
		[self tab_extras];
	}
}

-(void)close {
    [GEventDispatcher push_event:[GEvent cons_type:GEVentType_MENU_CLOSE_INVENTORY]];
	[AudioManager playsfx:SFX_MENU_DOWN];
}

-(void)dispatch_event:(GEvent *)e {
    if (e.type == GEventType_MENU_INVENTORY) {
        [self open:e.i1];
		
    } else if (e.type == GeventType_MENU_UPDATE_INVENTORY) {
		[(InventoryTabPane_Inventory*)tabpane_inventory update_available_items];
		[(InventoryTabPane_Upgrades*)tabpane_upgrades update_labels_and_buttons];
		
	} else if (e.type == GEventType_MENU_TICK) {
		[self update];
		
	} else if (e.type == GEVentType_MENU_CLOSE_INVENTORY) {
		[inventory_window setVisible:NO];
	}
}

-(BOOL)window_open {
	return inventory_window.visible;
}

-(void)touch_begin:(CGPoint)pt {
	if (![self window_open]) return;
	for (InventoryLayerTab *tab in tabs) if ([Common is_visible:tab]) [tab touch_begin:pt];
	for (InventoryTabPane *pane in tabpanes) if ([Common is_visible:pane]) [pane touch_begin:pt];
}
-(void)touch_move:(CGPoint)pt{
	if (![self window_open]) return;
	for (InventoryLayerTab *tab in tabs) if ([Common is_visible:tab])  [tab touch_move:pt];
	for (InventoryTabPane *pane in tabpanes) if ([Common is_visible:pane])  [pane touch_move:pt];
}
-(void)touch_end:(CGPoint)pt{
	if (![self window_open]) return;
	for (InventoryLayerTab *tab in tabs) if ([Common is_visible:tab])  [tab touch_end:pt];
	for (InventoryTabPane *pane in tabpanes) if ([Common is_visible:pane])  [pane touch_end:pt];
}

-(void)dealloc {
	[tabs removeAllObjects];
	[tabpanes removeAllObjects];
	[self removeAllChildrenWithCleanup:YES];
}

@end
