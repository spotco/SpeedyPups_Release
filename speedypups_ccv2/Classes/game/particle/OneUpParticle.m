#import "OneUpParticle.h"
#import "GameRenderImplementation.h"
#import "GameEngineLayer.h"

@implementation OneUpParticle {
	CGPoint vel;
}

+(OneUpParticle*)cons_pt:(CGPoint)pos {
    return [[OneUpParticle spriteWithTexture:[Resource get_tex:TEX_PARTICLES] rect:[FileCache get_cgrect_from_plist:TEX_PARTICLES idname:@"1up"]] cons_pt:pos];
}

-(id)cons_pt:(CGPoint)pt {
    [self setPosition:pt];
    ct = 30;
    ctmax = ct;
    [self csf_setScale:0.75];
	vel = ccp(0,1);
    return self;
}

-(void)set_vel:(CGPoint)_vel {
	vel = _vel;
}

-(void)update:(GameEngineLayer *)g {
	float dts = [Common get_dt_Scale];
    [self setPosition:CGPointAdd(self.position,ccp(vel.x*dts,vel.y*dts))];
    [self setOpacity:255*((float)ct)/ctmax];
    ct--;
}

-(BOOL)should_remove {
    return ct <= 0;
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_ABOVE_FG_ORD];
}

@end

@implementation OneUpUIAnimation {
	OneUpParticle *inner;
}

+(OneUpUIAnimation*)cons_pt:(CGPoint)pos {
	return [[OneUpUIAnimation node] cons_pt:pos];
}

-(id)cons_pt:(CGPoint)pos {
	inner = [OneUpParticle cons_pt:pos];
	[self addChild:inner];
	[self setScale:1];
	[inner csf_setScale:0.4];
	self.ct = 1;
	return self;
}

-(void)update {
	[inner update:NULL];
	if ([inner should_remove]) {
		self.ct = 0;
	}
}

@end