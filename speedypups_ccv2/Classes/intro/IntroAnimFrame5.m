#import "IntroAnimFrame5.h"
#import "Resource.h"
#import "FileCache.h"
#import "AudioManager.h"

@implementation IntroAnimFrame5

+(IntroAnimFrame5*)cons {
	return [IntroAnimFrame5 node];
}

-(id)init {
	self = [super init];
	
	bg = [CCSprite spriteWithTexture:[Resource get_tex:TEX_INTRO_ANIM_SS]
								rect:[FileCache get_cgrect_from_plist:TEX_INTRO_ANIM_SS idname:@"frame5_bg"]];
	[bg setScaleX:[Common scale_from_default].x];
	[bg setScaleY:[Common scale_from_default].y];
	[bg setAnchorPoint:ccp(0,0)];
	[bg setPosition:[Common screen_pctwid:0 pcthei:0]];
	[self addChild:bg];
	
	chars = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_INTRO_ANIM_SS]
								   rect:[FileCache get_cgrect_from_plist:TEX_INTRO_ANIM_SS idname:@"frame5_char"]];
	[chars setPosition:[Common screen_pctwid:0.45 pcthei:0.34]];
	[self addChild:chars];
	
	excl = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_INTRO_ANIM_SS]
								  rect:[FileCache get_cgrect_from_plist:TEX_INTRO_ANIM_SS idname:@"frame4_exclamation"]];
	[excl setPosition:[Common screen_pctwid:0.75 pcthei:0.75]];
	[self addChild:excl];
	
	ct = 0;
	return self;
}

static int END_AT = 150;


-(void)update {
	if (ct == 0) [AudioManager playsfx:SFX_BARK_MID];
	ct++;
	CGPoint excl_tar = [Common screen_pctwid:0.75 pcthei:0.75];
	excl_tar.x += float_random(-2, 2);
	excl_tar.y += float_random(-2, 2);
	[excl setPosition:excl_tar];
}

-(BOOL)should_continue {
	return ct >= END_AT;
}

-(void)force_continue {
	ct = END_AT;
}

@end
