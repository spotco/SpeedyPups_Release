#import "FreeRunProgressAnimation.h"
#import "Resource.h"
#import "FileCache.h"
#import "Player.h"

@implementation FreeRunProgressAnimation

#define DEFAULT_TRANS_LEN 20
#define DEFAULT_STAY_LEN 175
#define XPOS 0.5
#define DEFAULT_YPOS_START 1.3
#define DEFAULT_YPOS_END 0.875

+(FreeRunProgressAnimation*)cons_at:(FreeRunStartAt)pos {
	return [[FreeRunProgressAnimation node] cons_at:pos];
}

-(id)cons_at:(FreeRunStartAt)pos {
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
	
	[base addChild:[[[Common cons_label_pos:[Common pct_of_obj:base pctx:0.025 pcty:0.8]
									color:ccc3(200,30,30)
									fontsize:14
									str:@"Now Entering..."] anchor_pt:ccp(0,0.5)] set_scale:1/CC_CONTENT_SCALE_FACTOR()]];
	
	[base addChild:[[[Common cons_label_pos:[Common pct_of_obj:base pctx:0.2 pcty:0.4]
									 color:ccc3(0,0,0)
								  fontsize:28
									   str:[FreeRunStartAtManager name_for_loc:pos]] anchor_pt:ccp(0,0.5)] set_scale:1/CC_CONTENT_SCALE_FACTOR()]];
	
	
	TexRect *tr = [FreeRunStartAtManager get_icon_for_loc:pos];
	[base addChild:[[CCSprite spriteWithTexture:tr.tex rect:tr.rect] pos:[Common pct_of_obj:base pctx:0.75 pcty:0.45]]];
	
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
