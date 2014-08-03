#import "ShopBuyFlyoffTextParticle.h"
#import "Common.h"

@implementation ShopBuyFlyoffTextParticle

+(ShopBuyFlyoffTextParticle*)cons_pt:(CGPoint)pt text:(NSString *)text {
	return [[ShopBuyFlyoffTextParticle node] cons_pt:pt text:text color:ccc3(200,30,30)];
}

+(ShopBuyFlyoffTextParticle*)cons_pt:(CGPoint)pt text:(NSString *)text color:(ccColor3B)_color {
	return [[ShopBuyFlyoffTextParticle node] cons_pt:pt text:text color:_color];
}

#define MAX_CT 20.0

-(id)cons_pt:(CGPoint)pt text:(NSString *)text color:(ccColor3B)_color {
	ct = MAX_CT;
	[self addChild:[[Common cons_label_pos:CGPointZero
									color:_color fontsize:22 str:text] set_scale:1/CC_CONTENT_SCALE_FACTOR()]];
	[self setPosition:pt];
	vel = ccp(0,3);
	return self;
}

-(void)update:(GameEngineLayer *)g {
	ct--;
	float pct = 1-ct/MAX_CT;
	[self setOpacity:255-pct*255];
	[self setPosition:CGPointAdd([self position], vel)];
}

-(BOOL)should_remove {
	return ct <= 0;
}

@end
