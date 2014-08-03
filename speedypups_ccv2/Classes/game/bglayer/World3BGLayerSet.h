#import "BGLayer.h"

@interface World3BGLayerSet : BGLayerSet {
	NSMutableArray *bg_objects;

	BackgroundObject *sky;
	BackgroundObject *starsbg;
	BGTimeManager *time;
	CloudGenerator *clouds;
	BackgroundObject *backmountains;
	BackgroundObject *castle;
	BackgroundObject *backhills;
	BackgroundObject *fronthills;
}

+(World3BGLayerSet*)cons;

@end
