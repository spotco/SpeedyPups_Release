#import "MainMenuInventoryLayer.h"

@interface InventoryTabPane_Settings : InventoryTabPane <GEventListener> {
	NSMutableArray *touches;
}

+(InventoryTabPane_Settings*)cons:(CCSprite*)parent;

@end
