#import "Blocker.h"

@interface RocketWall : Blocker {
	NSMutableArray *to_remove;
}

+(RocketWall*)cons_x:(float)x y:(float)y width:(float)width height:(float)height;

@end

@interface DogRocketWall : Blocker
+(DogRocketWall*)cons_x:(float)x y:(float)y width:(float)width height:(float)height;
@end
