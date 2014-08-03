#import "CreditsFlybyObject.h"
#import "Resource.h" 
#import "FileCache.h"

@implementation CreditsFlybyObject

+(CreditsFlybyObject*)cons_logo {
	return [[CreditsFlybyObject node] cons_logo];
}

-(id)cons_logo {
	[self setScale:1];
	
	logo_base = [CSF_CCSprite node];
	[logo_base setPosition:[Common screen_pctwid:0.5 pcthei:0.75]];
	[self addChild:logo_base];
	
	CCSprite *logo_bg = [CCSprite spriteWithTexture:[Resource get_tex:TEX_INTRO_ANIM_SS]
											   rect:[FileCache get_cgrect_from_plist:TEX_INTRO_ANIM_SS idname:@"logo_flyin_base"]];
	[logo_base addChild:logo_bg];
	
	CCSprite *logo_circle = [CCSprite node];
	[logo_circle setPosition:ccp(25/CC_CONTENT_SCALE_FACTOR(),25/CC_CONTENT_SCALE_FACTOR())];
	[logo_circle runAction:[self cons_logobounce_anim]];
	[logo_base addChild:logo_circle];
	
	CCSprite *logo_pups = [CCSprite spriteWithTexture:[Resource get_tex:TEX_INTRO_ANIM_SS]
												 rect:[FileCache get_cgrect_from_plist:TEX_INTRO_ANIM_SS idname:@"logo_flyin_pups"]];
	[logo_base addChild:logo_pups];
	
	CCSprite *logo_speedy = [CCSprite spriteWithTexture:[Resource get_tex:TEX_INTRO_ANIM_SS]
												   rect:[FileCache get_cgrect_from_plist:TEX_INTRO_ANIM_SS idname:@"logo_flyin_speedy"]];
	[logo_base addChild:logo_speedy];
	
	[(CSF_CCSprite*)logo_base csf_setScale:0.75];
	[logo_base setPosition:[Common screen_pctwid:1.2 pcthei:0.65]];
	do_exit = NO;
	
	return self;
}

+(CreditsFlybyObject*)cons_text:(NSString *)text {
	return [[CreditsFlybyObject node] cons_text:text];
}

-(id)cons_text:(NSString*)text {
	[self setScale:1];
	logo_base = (CCLabelTTF_Pooled*)[[Common cons_pooled_label_pos:ccp(0,0)
								 color:ccc3(0,0,0)
							  fontsize:18
								   str:@""] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
	[(CCLabelTTF*)logo_base set_dimensions:CGSizeMake(350, 350)];
	[(CCLabelTTF*)logo_base set_textalign:CCTextAlignmentCenter];
	[(CCLabelTTF*)logo_base setAnchorPoint:ccp(0.5,1)];
	[(CCLabelTTF*)logo_base setString:text];
	
	
	
	[self addChild:logo_base];
	[logo_base setPosition:[Common screen_pctwid:1.2 pcthei:0.4]];
	do_exit = NO;
	return self;
}

#define ENTER_TARGET [Common screen_pctwid:0.7 pcthei:0]

-(void)update:(CapeGameEngineLayer *)g {
	if (logo_base.position.x > ENTER_TARGET.x) {
		[logo_base setPosition:ccp(MAX(logo_base.position.x-7*[Common get_dt_Scale],ENTER_TARGET.x),logo_base.position.y)];
		
	} else {
		if (do_exit) {
			[logo_base setPosition:ccp(logo_base.position.x-7,logo_base.position.y)];
		}
	}
}

-(BOOL)has_enter {
	return !(logo_base.position.x > ENTER_TARGET.x);
}

-(void)do_exit {
	do_exit = YES;
}

-(BOOL)has_exit {
	return logo_base.position.x < [Common screen_pctwid:-0.2 pcthei:0].x;
}

-(void)setPosition:(CGPoint)position{}

-(CCAnimate*)cons_logobounce_anim {
    NSString *tar = TEX_INTRO_ANIM_SS;
    CCTexture2D *texture = [Resource get_tex:tar];
    NSMutableArray *animFrames = [NSMutableArray array];
    for (int i = 0; i < 5; i++) {
        [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:tar idname:@"logo_headcircle_5"]]];
        [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:tar idname:@"logo_headcircle_6"]]];
        [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:tar idname:@"logo_headcircle_7"]]];
    }
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:tar idname:@"logo_headcircle_8"]]];
    return [Common make_anim_frames:animFrames speed:0.15];
}

-(void)dealloc {
	[self removeAllChildrenWithCleanup:YES];
	if ([logo_base class] == [CCLabelTTF_Pooled class]) {
		[(CCLabelTTF_Pooled*)logo_base repool];
	}
}

@end
