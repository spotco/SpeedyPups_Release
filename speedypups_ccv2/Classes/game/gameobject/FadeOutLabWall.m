#import "FadeOutLabWall.h"

@implementation FadeOutLabWall

+(FadeOutLabWall*)cons_x:(float)x y:(float)y width:(float)width height:(float)height {
    FadeOutLabWall* n = [FadeOutLabWall node];
    [n cons_x:x y:y width:width height:height];
    [GEventDispatcher add_listener:n];
    return n;
}

-(void)cons_x:(float)x y:(float)y width:(float)width height:(float)height {
    tar_opacity = 255;
	
	
	CCSprite *body = [CCSprite spriteWithTexture:[Resource get_tex:TEX_LAB_WALL] rect:CGRectMake(0, 0, width, height)];
	[self setPosition:ccp(x,y)];
	[body setAnchorPoint:ccp(0,0)];
	[self addChild:body];
	
	ccTexParams par = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
    [body.texture setTexParameters:&par];
}

-(void)check_should_render:(GameEngineLayer *)g {
    do_render = YES;
}

-(void)dispatch_event:(GEvent *)e {
    if (e.type == GEventType_ENTER_LABAREA) {
        tar_opacity = 0;
    }
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    if (self.opacity != tar_opacity) {
        int dif = tar_opacity - self.opacity;
        if (ABS(dif) < 10) {
            [self setOpacity:tar_opacity];
        } else {
            [self setOpacity:self.opacity+dif/10];
        }
    }
}

-(void)reset {
    [super reset];
    //tar_opacity = 255;
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_ABOVE_FG_ORD];
}

-(void)cleanup {
    [GEventDispatcher remove_listener:self];
}

@end
