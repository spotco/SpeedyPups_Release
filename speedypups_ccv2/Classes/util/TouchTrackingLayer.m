#import "TouchTrackingLayer.h"
#import "Resource.h"
#import "FileCache.h"

@implementation TouchTrackingLayer

-(id)init{
    self=[super init];
    self.isTouchEnabled = YES;
	//m = [CCMotionStreak streakWithFade:0.2 minSeg:5 width:5 color:ccc3(255,255,255) texture:[Resource get_tex:TEX_BLANK]];
    m = [CCMotionStreak streakWithFade:0.2 minSeg:5 image:[Resource get_tex:TEX_BLANK] width:5 length:15 color:ccc4(255,255,255,255)];
    
	touchb = [CCSprite spriteWithTexture:[Resource get_tex:TEX_PARTICLES] rect:[FileCache get_cgrect_from_plist:TEX_PARTICLES idname:@"grey_particle"]];
    [self addChild:touchb];
    [touchb setOpacity:0];
    [GEventDispatcher add_listener:self];
    [self addChild:m];
    
    return self;
}

-(void)dispatch_event:(GEvent *)e {
    if (e.type == GEventType_DASH) {
        dispdashct=20;
    } else if (e.type == GEventType_JUMP) {
        [touchb setPosition:lasttouchbegin];
        [touchb setOpacity:255];
        [touchb setScale:5];
    } else if (e.type == GEventType_GAME_TICK || e.type == GEventType_UIANIM_TICK) {
        [self update];
    }
}

-(void)update {
    if (dispdashct > 0) {
        [m setVisible:YES];
        dispdashct--;
    } else {
        [m setVisible:NO];
    }
    if ([touchb opacity] > 20) {
        float t = [touchb opacity];
        t/=1.05;
        [touchb setOpacity:t];
    } else {
        [touchb setOpacity:0];
    }
    if ([touchb scale]>0.5) {
        [touchb setScale:[touchb scale]/1.05];
    } else {
        [touchb setScale:0.5];
    }
    
}

-(void) ccTouchesBegan:(NSSet*)pTouches withEvent:(UIEvent*)pEvent {
    CGPoint touch;
    for (UITouch *t in pTouches) {
        touch = [self convertTouchToNodeSpace:t];
    }
    lasttouchbegin = touch;
}
-(void) ccTouchesMoved:(NSSet *)pTouches withEvent:(UIEvent *)event {
    CGPoint touch;
    for (UITouch *t in pTouches) {
        touch = [self convertTouchToNodeSpace:t];
    }
    [m setPosition:touch];
}

@end
