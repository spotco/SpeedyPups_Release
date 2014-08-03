#import "LineIsland.h"

@interface LabLineIsland : LineIsland


+(LabLineIsland*)cons_pt1:(CGPoint)start pt2:(CGPoint)end height:(float)height ndir:(float)ndir can_land:(BOOL)can_land;

@property(readwrite,assign) BOOL shift_mainfill;

@end
