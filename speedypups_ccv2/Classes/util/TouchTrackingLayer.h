#import "CCLayer.h"
#import "cocos2d.h"
#import "GEventDispatcher.h"

@interface TouchTrackingLayer : CCLayer <GEventListener> {
    CCMotionStreak *m;
    CGPoint lasttouchbegin;
    CCSprite *touchb;
    int dispdashct;
}

@end
