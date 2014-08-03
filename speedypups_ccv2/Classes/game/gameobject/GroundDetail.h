
#import "Resource.h"
#import "GameObject.h"

@interface GroundDetail : GameObject

+(GroundDetail*)cons_x:(float)posx y:(float)posy type:(int)type islands:(NSMutableArray*)islands g:(GameEngineLayer*)g;
@property(readwrite,assign) int imgtype;
@property(readwrite,strong)CCSprite* img;
@end
