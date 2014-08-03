#import "ShopBuyBoneFlyoutParticle.h"
#import "Common.h"
#import "FileCache.h"

@implementation ShopBuyBoneFlyoutParticle

+(ShopBuyBoneFlyoutParticle*)cons_pt:(CGPoint)pt vel:(CGPoint)vel {
	return [[ShopBuyBoneFlyoutParticle node] cons_pt:pt vel:vel];
}

-(void)set_body {
	[self setTexture:[Resource get_tex:TEX_ITEM_SS]];
	[self setTextureRect:[FileCache get_cgrect_from_plist:TEX_ITEM_SS idname:@"star_coin"]];
}

#define MAX_CT 23.0

-(id)cons_pt:(CGPoint)pt vel:(CGPoint)tvel {
	[self set_body];
	ct = MAX_CT;
	[self setPosition:pt];
	vel = tvel;
	[self setRotation:float_random(0, 360)];
	vr = float_random(25, 35) * [Common sig:float_random(-100, 100)];
	init_scale = float_random(0.3, 0.9);
	[self setScale:init_scale];
	
	return self;
}

-(void)update:(GameEngineLayer *)g {
	ct--;
	float pct = 1-ct/MAX_CT;
	[self setPosition:CGPointAdd([self position], vel)];
	[self setRotation:[self rotation]+vr];
	[self setScale:init_scale+pct*1.2];
	[self setOpacity:220-pct*220];
}

-(BOOL)should_remove {
	return ct <= 0;
}

@end
