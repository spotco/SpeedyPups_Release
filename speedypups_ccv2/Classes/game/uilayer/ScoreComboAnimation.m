#import "ScoreComboAnimation.h"
#import "Common.h"
#import "Player.h"
#import "AudioManager.h"

@implementation ScoreComboAnimation

+(ScoreComboAnimation*)cons_combo:(float)combo {
	return [[ScoreComboAnimation node] cons_combo:combo];
}

-(id)cons_combo:(float)combo {
	[self addChild:[CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
										  rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:strf("combo_%d",(int)combo)]]];
	
	[self csf_setScale:4];
	[self setOpacity:0];
	[self setPosition:[Common screen_pctwid:0.5 pcthei:0.7]];
	[Player character_bark];
	[AudioManager playsfx:SFX_CHEER];
	ct = 1;
	pct = 1;
	is_in = YES;
	
	return self;
}

-(void)update {
	if (is_in) {
		pct = MAX(0,pct-0.035*[Common get_dt_Scale]);
		[self csf_setScale:pct*3+1];
		[self setOpacity:(1-pct)*255];
		if (pct <= 0) {
			is_in = NO;
			hold = YES;
			pct = 1;
		}
		
	} else if (hold) {
		pct -= 0.05*[Common get_dt_Scale];
		if (pct <= 0) {
			hold = NO;
			pct = 1;
		}
		
	} else {
		pct = MAX(0,pct-0.1*[Common get_dt_Scale]);
		[self setOpacity:pct*255];
		if (pct <= 0) {
			ct = 0;
		}
	}
}

-(void)setOpacity:(GLubyte)opacity {
	[super setOpacity:opacity];
	for(CCSprite *sprite in [self children]) {
		if ([sprite respondsToSelector:@selector(setOpacity:)]) sprite.opacity = opacity;
	}
}

@end
