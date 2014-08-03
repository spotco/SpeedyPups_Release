#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "UIAnim.h"


@interface GameStartAnim : UIAnim {
    CCSprite* readyimg;
    CCSprite* goimg;
	
	BOOL played_ready;
	BOOL played_go;
    
    int ct;
}

+(GameStartAnim*)cons_with_callback:(CallBack*)cb;

@end
