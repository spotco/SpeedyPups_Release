#import "CCSprite.h"

@interface TutorialAnim : CCSprite {
    CCSprite *body,*hand,*effect,*nosign;
    CGRect *frames,*effectframes;
    CGPoint *handposframes,*nosignframes,defaulthandpos;
    int animlen,curframe,animspeed;
    
    int animdelayct;
}

+(TutorialAnim*)cons_msg:(NSString*)msg;
-(void)update ;

@end
