#import "CCSprite.h"
#import "UIAnim.h"

@interface UIIngameAnimation : CSF_CCSprite  {
    float ct;
}

@property(readwrite,assign) float ct;
-(void)update;
-(void)repool;

@end
