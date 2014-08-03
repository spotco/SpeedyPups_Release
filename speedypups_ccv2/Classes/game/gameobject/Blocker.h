#import "GameObject.h"
#import "BlockerEffect.h"

@interface Blocker : GameObject {
    float width,height;
}

+(Blocker*)cons_x:(float)x y:(float)y width:(float)width height:(float)height;
-(void)cons_x:(float)x y:(float)y width:(float)pwidth height:(float)pheight;

@end
