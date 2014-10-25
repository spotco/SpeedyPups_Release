#import "FillerProgressUIAnimation.h"
#import "Resource.h"
#import "FileCache.h"
#import "Player.h"
#import "Common.h"

@implementation FillerProgressUIAnimation

#define DEFAULT_TRANS_LEN 20
#define DEFAULT_STAY_LEN 175
#define XPOS 0.5
#define DEFAULT_YPOS_START 1.3
#define DEFAULT_YPOS_END 0.875

+(FillerProgressUIAnimation*)cons_at:(FreeRunStartAt)pos pct:(FillerProgressUIAnimationPct)pct;{
	return [[FillerProgressUIAnimation node] cons_at:pos pct:pct];
}

-(FillerProgressUIAnimation*)cons_at:(FreeRunStartAt)pos pct:(FillerProgressUIAnimationPct)pct; {
	self.TRANS_LEN = DEFAULT_TRANS_LEN;
	self.STAY_LEN = DEFAULT_STAY_LEN;
	self.YPOS_START = DEFAULT_YPOS_START;
	self.YPOS_END = DEFAULT_YPOS_END;
	
	[self setScale:1];
	
	base = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
									  rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"progresspanel"]];
	[base setPosition:[Common screen_pctwid:XPOS pcthei:self.YPOS_START]];
	[self addChild:base];
	
	ct = 1;
	mode = TitleCardMode_DOWN;
	animct = self.TRANS_LEN;
	
	[base addChild:[[[Common cons_label_pos:[Common pct_of_obj:base pctx:0.5 pcty:0.84]
									  color:ccc3(20,20,20)
								   fontsize:14
										str:@"Progress"] anchor_pt:ccp(0.5,0.5)] set_scale:1/CC_CONTENT_SCALE_FACTOR()]];
	
	[base addChild:[[CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
										   rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"fillerprogressline"]]
					pos:[Common pct_of_obj:base pctx:0.5 pcty:0.24]]];
	
	TexRect *tr1 = [FreeRunStartAtManager get_icon_for_loc:pos];
	[base addChild:[[[CCSprite spriteWithTexture:tr1.tex rect:tr1.rect] pos:[Common pct_of_obj:base pctx:0.12 pcty:0.285]] scale:0.6]];
	[base addChild:[[[CCSprite spriteWithTexture:[Resource get_tex:TEX_FREERUNSTARTICONS] rect:[FileCache get_cgrect_from_plist:TEX_FREERUNSTARTICONS idname:@"icon_question"]] pos:[Common pct_of_obj:base pctx:0.88 pcty:0.285]] scale:0.6]];
	
	CCSprite *dogicon = [CCSprite node];
	[dogicon runAction:[Common cons_anim:@[@"dog_selector_0",@"dog_selector_1"] speed:0.2 tex_key:TEX_NMENU_ITEMS]];
	[dogicon setPosition:[Common pct_of_obj:base pctx:(pct == FillerProgressUIAnimation_ONE?0.3:(pct == FillerProgressUIAnimation_TWO?0.5:0.7)) pcty:0.475]];
	[dogicon setScale:0.6];
	[base addChild:dogicon];
	return self;
}

static TitleCardMode last_mode;
-(void)update {
	[super update];
	if (last_mode == TitleCardMode_DOWN && mode == TitleCardMode_STAY) {
		[Player character_bark];
	}
	last_mode = mode;
}


@end
