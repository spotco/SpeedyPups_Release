#import "GameObject.h"
#import "DogBone.h"

@interface DogCape : DogBone

+(DogCape*)cons_x:(float)x y:(float)y;
+(DogCape*)cons_x:(float)x y:(float)y map:(NSString*)map;

@end
