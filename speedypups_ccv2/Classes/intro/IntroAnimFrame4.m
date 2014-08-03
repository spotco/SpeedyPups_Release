#import "IntroAnimFrame4.h"
#import "Resource.h"
#import "FileCache.h"
#import "AudioManager.h"

@implementation IntroAnimFrame4

+(IntroAnimFrame4*)cons {
	return [IntroAnimFrame4 node];
}

-(id)init {
	self = [super init];
	
	bg = [CCSprite spriteWithTexture:[Resource get_tex:TEX_INTRO_ANIM_SS]
								rect:[FileCache get_cgrect_from_plist:TEX_INTRO_ANIM_SS idname:@"frame4_bg"]];
	[bg setScaleX:[Common scale_from_default].x];
	[bg setScaleY:[Common scale_from_default].y];
	[bg setAnchorPoint:ccp(0,0)];
	[bg setPosition:[Common screen_pctwid:0 pcthei:0]];
	[self addChild:bg];
	
	dleft = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_INTRO_ANIM_SS]
								   rect:[FileCache get_cgrect_from_plist:TEX_INTRO_ANIM_SS idname:@"frame4_dog3"]];
	[dleft setPosition:[Common screen_pctwid:0.16 pcthei:0.23]];
	[self addChild:dleft];
	
	dright = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_INTRO_ANIM_SS]
									rect:[FileCache get_cgrect_from_plist:TEX_INTRO_ANIM_SS idname:@"frame4_dog2"]];
	[dright setPosition:[Common screen_pctwid:0.84 pcthei:0.27]];
	[self addChild:dright];
	
	copter = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_INTRO_ANIM_SS]
									rect:[FileCache get_cgrect_from_plist:TEX_INTRO_ANIM_SS idname:@"frame4_cage"]];
	[copter setPosition:[Common screen_pctwid:0.525 pcthei:0.55]];
	[self addChild:copter];
	

	spotlight = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_INTRO_ANIM_SS]
									   rect:[FileCache get_cgrect_from_plist:TEX_INTRO_ANIM_SS idname:@"frame4_spotlight"]];
	[spotlight setAnchorPoint:ccp(0.5,1)];
	[spotlight setPosition:[Common screen_pctwid:0.5 pcthei:1]];
	[self addChild:spotlight];
	
	curtains = [CCSprite spriteWithTexture:[Resource get_tex:TEX_INTRO_ANIM_SS]
									  rect:[FileCache get_cgrect_from_plist:TEX_INTRO_ANIM_SS idname:@"frame3_curtain"]];
	[curtains setAnchorPoint:ccp(0.5,1)];
	[curtains setScaleX:[Common scale_from_default].x];
	[curtains setScaleY:[Common scale_from_default].y];
	[curtains setPosition:[Common screen_pctwid:0.5 pcthei:1]];
	[self addChild:curtains];
	
	exclamation = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_INTRO_ANIM_SS]
										 rect:[FileCache get_cgrect_from_plist:TEX_INTRO_ANIM_SS idname:@"frame4_exclamation"]];
	[exclamation setPosition:[Common screen_pctwid:0.8 pcthei:0.75]];
	[self addChild:exclamation];
	
	ct = 0;
	return self;
}

static int END_AT = 250;


-(void)update {
	if (ct == 0) [AudioManager playsfx:SFX_INTRO_SURPRISE];
	ct++;
	
	CGPoint excl_tar = [Common screen_pctwid:0.8 pcthei:0.75];
	excl_tar.x += float_random(-2, 2);
	excl_tar.y += float_random(-2, 2);
	[exclamation setPosition:excl_tar];
	
	if (ct > 100) {
		CGPoint tar_pos = [Common screen_pctwid:0.525 pcthei:1.4];
		[copter setPosition:ccp(copter.position.x,copter.position.y+(tar_pos.y - copter.position.y)/15.0)];
	}
}

-(BOOL)should_continue {
	return ct >= END_AT;
}

-(void)force_continue {
	ct = END_AT;
}

@end
