#import "DogBone.h"

@interface OneUpObject : DogBone {
	GameEngineLayer *_g;
}
+(OneUpObject*)cons_pt:(CGPoint)pt;
-(void)set_only_appear_if_below_threshold;
@end
