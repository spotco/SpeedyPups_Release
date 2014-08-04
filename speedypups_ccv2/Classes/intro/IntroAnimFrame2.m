#import "IntroAnimFrame2.h"
#import "Resource.h"
#import "FileCache.h"
#import "RepeatFillSprite.h"
#import "BackgroundObject.h"
#import "Common.h"
#import "AudioManager.h"

@implementation IntroAnimFrame2

+(IntroAnimFrame2*)cons {
	return [IntroAnimFrame2 node];
}

static int GROUND_TEX_WID;

-(id)init {
	self = [super init];
	
    BackgroundObject *sky = [BackgroundObject backgroundFromTex:[Resource get_tex:TEX_BG_SKY] scrollspd_x:0 scrollspd_y:0];
	[Common scale_to_fit_screen_y:sky];
	
	
	BackgroundObject *starsbg = [BackgroundObject backgroundFromTex:[Resource get_tex:TEX_BG_STARS] scrollspd_x:0 scrollspd_y:0];
    [Common scale_to_fit_screen_y:starsbg];
	
	BackgroundObject *moon = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_BG_MOON]];
    [moon setPosition:[Common screen_pctwid:0.75 pcthei:0.8]];
    
    float pctm = 0;
    [sky setColor:ccc3(pb(20,pctm),pb(20,pctm),pb(60,pctm))];
    [self addChild:sky];
    [self addChild:starsbg];
    [self addChild:moon];
	
	GROUND_TEX_WID = [FileCache get_cgrect_from_plist:TEX_INTRO_ANIM_SS idname:@"frame2_ground"].size.width;
	ground = [RepeatFillSprite cons_tex:[Resource get_tex:TEX_INTRO_ANIM_SS]
								   rect:[FileCache get_cgrect_from_plist:TEX_INTRO_ANIM_SS idname:@"frame2_ground"]
									rep:6];
	[ground setScale:CC_CONTENT_SCALE_FACTOR()];
	[ground setPosition:[Common screen_pctwid:0 pcthei:0.55]];
	[self addChild:ground];
	
	robot1 = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_INTRO_ANIM_SS]
										rect:[FileCache get_cgrect_from_plist:TEX_INTRO_ANIM_SS idname:@"frame2_robolauncher"]];
	[robot1 setPosition:[Common screen_pctwid:1.42 pcthei:0.7]];
	[self addChild:robot1];
	
	robot2 = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_INTRO_ANIM_SS]
										rect:[FileCache get_cgrect_from_plist:TEX_INTRO_ANIM_SS idname:@"frame2_copter"]];
	[robot2 setPosition:[Common screen_pctwid:1.7 pcthei:0.76]];
	[self addChild:robot2];
	
	robot3 = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_INTRO_ANIM_SS]
										rect:[FileCache get_cgrect_from_plist:TEX_INTRO_ANIM_SS idname:@"frame2_robominion"]];
	[robot3 setPosition:[Common screen_pctwid:1.9 pcthei:0.68]];
	[self addChild:robot3];
	
	ct = 0;
	return self;
}

static int END_AT = 125;


-(void)update {
	if (ct <= 0) [AudioManager playsfx:SFX_INTRO_NIGHT];
	
	ct+=[Common get_dt_Scale];
	[robot1 setPosition:ccp(robot1.position.x-12*[Common get_dt_Scale],robot1.position.y)];
	[robot2 setPosition:ccp(robot2.position.x-12.2*[Common get_dt_Scale],robot2.position.y)];
	[robot3 setPosition:ccp(robot3.position.x-12.1*[Common get_dt_Scale],robot3.position.y)];
}

-(BOOL)should_continue {
	return ct >= END_AT;
}

-(void)force_continue {
	ct = END_AT;
}

@end
