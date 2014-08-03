#import "CCSprite.h"
#import "cocos2d.h"
#import "Resource.h"
#import "Common.h"
#import "FileCache.h"

@interface FishGenerator : CCSprite {
    float bwidth,bheight;
    NSMutableArray *fishes;
}

+(FishGenerator*)cons_ofwidth:(float)wid basehei:(float)hei;
-(void)update;

@end
