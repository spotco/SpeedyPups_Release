#import "GameObject.h"

@interface BirdFlock : GameObject {
    NSMutableArray *birds;
    BOOL activated;
}

+(BirdFlock*)cons_x:(float)x y:(float)y;
-(void)activate_birds;
-(BOOL)get_activated;

@end
