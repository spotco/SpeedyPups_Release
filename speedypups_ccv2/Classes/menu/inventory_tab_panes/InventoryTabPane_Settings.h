#import "MainMenuInventoryLayer.h"

@interface InventoryTabPane_Settings : InventoryTabPane {
	NSMutableArray *touches;
}

+(InventoryTabPane_Settings*)cons:(CCSprite*)parent;

@end
