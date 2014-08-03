#import "BGLayer.h"
@class BackgroundObject;

@interface World1BGLayerSet : BGLayerSet {
	NSMutableArray *bg_objects;
	
	BackgroundObject *sky;
	BackgroundObject *starsbg;
	BGTimeManager *time;
	BackgroundObject *backhills;
	CloudGenerator *clouds;
	BackgroundObject *fronthills;
}

+(World1BGLayerSet*)cons;

@end
