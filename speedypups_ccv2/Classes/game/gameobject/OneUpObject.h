#import "DogBone.h"

@interface OneUpObject : DogBone {
	GameEngineLayer *_g;
}
+(OneUpObject*)cons_pt:(CGPoint)pt;
@end
