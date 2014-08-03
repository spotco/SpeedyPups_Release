#import "RotateFadeOutParticle.h"
#import "GameRenderImplementation.h"

@implementation RotateFadeOutParticle {
	float _ct, _ctmax;
	float _vr;
}

+(RotateFadeOutParticle*)cons_tex:(CCTexture2D*)tex rect:(CGRect)rect {
	return [RotateFadeOutParticle spriteWithTexture:tex rect:rect];
}

-(RotateFadeOutParticle*)set_ctmax:(float)ctmax {
	_ctmax = ctmax;
	_ct = _ctmax;
	return self;
}

-(RotateFadeOutParticle*)set_vr:(float)vr {
	_vr = vr;
	return self;
}

-(void)update:(GameEngineLayer *)g {
	float pct = _ct/_ctmax;
	_ct -= [Common get_dt_Scale];
	[self setOpacity:255 * pct];
	[self setRotation:self.rotation + _vr * [Common get_dt_Scale]];
}

-(BOOL)should_remove {
	return _ct <= 0;
}

-(int)get_render_ord {
	return [GameRenderImplementation GET_RENDER_FG_ISLAND_ORD];
}



@end
