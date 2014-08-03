#import "IntroAnimFrame1.h"
#import "Resource.h"
#import "FileCache.h"

@implementation IntroAnimFrame1

+(IntroAnimFrame1*)cons {
	return [IntroAnimFrame1 node];
}

-(id)init {
	self = [super init];
	
	bg = [CCSprite spriteWithTexture:[Resource get_tex:TEX_INTRO_ANIM_SS]
								rect:[FileCache get_cgrect_from_plist:TEX_INTRO_ANIM_SS idname:@"frame1_bg"]];
	[bg setScaleX:[Common scale_from_default].x];
	[bg setScaleY:[Common scale_from_default].y];
	[bg setAnchorPoint:ccp(0.5,0.5)];
	[bg setPosition:[Common screen_pctwid:0.5 pcthei:0.5]];
	[self addChild:bg];
	
	chars = [CCSprite node];
	[chars runAction:[Common cons_anim:@[@"frame1_chars_0",@"frame1_chars_1",@"frame1_chars_2",@"frame1_chars_1"]
								speed:0.25
							   tex_key:TEX_INTRO_ANIM_SS]];
	[chars setPosition:[Common screen_pctwid:0.565 pcthei:0.255]];
	[chars setPosition:ccp(chars.position.x/[Common scale_from_default].x,chars.position.y/[Common scale_from_default].y)];
	[bg addChild:chars];
	
	leftbush = [CCSprite spriteWithTexture:[Resource get_tex:TEX_INTRO_ANIM_SS]
									  rect:[FileCache get_cgrect_from_plist:TEX_INTRO_ANIM_SS idname:@"frame1_fgbush_left"]];
	[leftbush setAnchorPoint:CGPointZero];
	[leftbush setPosition:CGPointZero];
	[bg addChild:leftbush];
	
	rightbush = [CCSprite spriteWithTexture:[Resource get_tex:TEX_INTRO_ANIM_SS]
									  rect:[FileCache get_cgrect_from_plist:TEX_INTRO_ANIM_SS idname:@"frame1_fgbush_right"]];
	[rightbush setAnchorPoint:ccp(1,0)];
	[rightbush setPosition:ccp([Common screen_pctwid:1 pcthei:0].x/[Common scale_from_default].x,0)];
	[bg addChild:rightbush];
	
	ct = 0;
	return self;
}

static float BUSH_MOV = 0.5;
static int END_AT = 100;

-(void)update {
	ct++;
	[leftbush setPosition:ccp(leftbush.position.x-BUSH_MOV,leftbush.position.y-BUSH_MOV)];
	[rightbush setPosition:ccp(rightbush.position.x+BUSH_MOV,rightbush.position.y-BUSH_MOV)];
	[bg setScaleX:bg.scaleX*1.0005];
	[bg setScaleY:bg.scaleY*1.0005];
}

-(BOOL)should_continue {
	return ct >= END_AT;
}

-(void)force_continue {
	ct = END_AT;
}

@end
