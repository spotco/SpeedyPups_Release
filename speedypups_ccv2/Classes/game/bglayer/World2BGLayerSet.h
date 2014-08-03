#import "BGLayer.h"

@interface World2BGLayerSet : BGLayerSet {
	NSMutableArray *bg_objects;
	
	BackgroundObject *sky;
	BackgroundObject *starsbg;
	BGTimeManager *time;
	CloudGenerator *clouds;
	BackgroundObject *backhills;
	BackgroundObject *fronthills;
	BackgroundObject *water;
	BackgroundObject *backislands;
	BackgroundObject *frontislands;
}
+(World2BGLayerSet*)cons;
@end
