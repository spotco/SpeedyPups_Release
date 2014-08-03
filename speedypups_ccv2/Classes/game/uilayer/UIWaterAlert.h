#import "CCSprite.h"
@class GameEngineLayer;


@interface UIWaterAlert : CCSprite {
	CCSprite *body;
}

+(UIWaterAlert*)cons;
-(void)update:(GameEngineLayer*)g;

@end
