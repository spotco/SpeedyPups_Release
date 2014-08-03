#import "cocos2d.h"
#import "GEventDispatcher.h"
#import "Resource.h"
#import "BackgroundObject.h"
#import "BGTimeManager.h"
#import "GEventDispatcher.h"

@interface MainMenuBGLayer : CCLayer <GEventListener>  {
    CCSprite *fg;
    BackgroundObject *sky,*clouds,*hills,*starsbg;
    
    NSMutableArray *particles,*particles_tba;
    BGTimeManager *time;
}

+(MainMenuBGLayer*)cons;

-(void)update;

-(void)move_fg:(CGPoint)pt;
-(CGPoint)get_fg_pos;

@end