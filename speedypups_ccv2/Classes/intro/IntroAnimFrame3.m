#import "IntroAnimFrame3.h"
#import "Resource.h"
#import "FileCache.h"
#import "AudioManager.h"

@interface CCSprite_WithVr : CSF_CCSprite
@property(readwrite,assign) float v_r;
@end

@implementation CCSprite_WithVr
@synthesize v_r;
@end

@implementation IntroAnimFrame3

+(IntroAnimFrame3*)cons {
	return [IntroAnimFrame3 node];
}

-(id)init {
	self = [super init];
	
	bg = [CCSprite spriteWithTexture:[Resource get_tex:TEX_INTRO_ANIM_SS]
								rect:[FileCache get_cgrect_from_plist:TEX_INTRO_ANIM_SS idname:@"frame3_bg"]];
	[bg setScaleX:[Common scale_from_default].x];
	[bg setScaleY:[Common scale_from_default].y];
	[bg setAnchorPoint:ccp(0.5,0.5)];
	[bg setPosition:[Common screen_pctwid:0.5 pcthei:0.5]];
	[self addChild:bg];
	
	dleft = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_INTRO_ANIM_SS]
								   rect:[FileCache get_cgrect_from_plist:TEX_INTRO_ANIM_SS idname:@"frame3_dog3"]];
	[dleft setPosition:[Common screen_pctwid:0.2 pcthei:0.21]];
	[self addChild:dleft];
	
	dright = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_INTRO_ANIM_SS]
									rect:[FileCache get_cgrect_from_plist:TEX_INTRO_ANIM_SS idname:@"frame3_dog2"]];
	[dright setPosition:[Common screen_pctwid:0.8 pcthei:0.29]];
	[self addChild:dright];
	
	pups = [CSF_CCSprite node];
	[pups runAction:[Common cons_anim:@[@"frame3_pups_0",@"frame3_pups_1",@"frame3_pups_2",@"frame3_pups_1"]
								speed:0.11
							  tex_key:TEX_INTRO_ANIM_SS]];
	[pups setPosition:[Common screen_pctwid:0.5 pcthei:0.25]];
	[self addChild:pups];
	
	curtains = [CCSprite spriteWithTexture:[Resource get_tex:TEX_INTRO_ANIM_SS]
									  rect:[FileCache get_cgrect_from_plist:TEX_INTRO_ANIM_SS idname:@"frame3_curtain"]];
	[curtains setAnchorPoint:ccp(0.5,1)];
	[curtains setScaleX:[Common scale_from_default].x];
	[curtains setScaleY:[Common scale_from_default].y];
	[curtains setPosition:[Common screen_pctwid:0.5 pcthei:1]];
	
    debris = [NSMutableArray array];
    for (int i = 0; i < 16; i++) {
        CCSprite_WithVr *particle = [CCSprite_WithVr spriteWithTexture:[Resource get_tex:TEX_INTRO_ANIM_SS]
													rect:[FileCache get_cgrect_from_plist:TEX_INTRO_ANIM_SS
																				   idname:[NSString stringWithFormat:@"frame3_debris_%d",i%8]]];
        [particle setPosition:ccp([Common SCREEN].width/7*i+float_random(-50, 50),float_random([Common SCREEN].height, [Common SCREEN].height+500))];
		[particle setRotation:float_random(0, 360)];
		[debris addObject:particle];
		particle.v_r = float_random(10, 30);
		[self addChild:particle];
		
		particle = [CCSprite_WithVr spriteWithTexture:[Resource get_tex:TEX_INTRO_ANIM_SS]
												  rect:[FileCache get_cgrect_from_plist:TEX_INTRO_ANIM_SS
																				 idname:[NSString stringWithFormat:@"frame3_debris_%d",i%8]]];
        [particle setPosition:ccp([Common SCREEN].width/7*i+float_random(-50, 50),float_random([Common SCREEN].height+450, [Common SCREEN].height+750))];
		[particle setRotation:float_random(0, 360)];
		[debris addObject:particle];
		particle.v_r = float_random(10, 30);
		[self addChild:particle];
    }
	
	[self addChild:curtains];
	
	ct = 0;
	return self;
}

static int END_AT = 150;


-(void)update {
	if (ct <= 0) [AudioManager playsfx:SFX_INTRO_SNORE];
	ct++;
	if (ct > END_AT*0.5) {
		if (ct - 1 <= END_AT*0.5) [AudioManager playsfx:SFX_ROCKBREAK];
	
		if (ct%4==0) {
			[self setPosition:ccp(float_random(-1, 1),float_random(-1, 1))];
		}
		for (CCSprite_WithVr *particle in debris) {
			[particle setPosition:CGPointAdd(ccp(0,-10), particle.position)];
			[particle setRotation:particle.rotation+particle.v_r];
		}
	}
}

-(BOOL)should_continue {
	return ct >= END_AT;
}

-(void)force_continue {
	ct = END_AT;
}

@end
