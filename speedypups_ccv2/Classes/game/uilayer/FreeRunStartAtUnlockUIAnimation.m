#import "FreeRunStartAtUnlockUIAnimation.h"
#import "Resource.h"
#import "FileCache.h"
#import "FreeRunStartAtManager.h"

#define DEFAULT_TRANS_LEN 20
#define DEFAULT_STAY_LEN 175
#define XPOS 0.5

@implementation FreeRunStartAtUnlockUIAnimation
+(FreeRunStartAtUnlockUIAnimation*)cons_for_unlocking:(FreeRunStartAt)startat {
	return [[[FreeRunStartAtUnlockUIAnimation alloc] init] cons_for_unlocking:startat];
}
-(id)cons_for_unlocking:(FreeRunStartAt)startat {
	[FreeRunStartAtManager set_starting_loc:startat];
	self.TRANS_LEN = DEFAULT_TRANS_LEN;
	self.STAY_LEN = DEFAULT_STAY_LEN;
	self.YPOS_START = -0.3;
	self.YPOS_END = 0.125;
	
	[self setScale:1];
	
	base = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
								  rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"challengeintrocard"]];
	[base setPosition:[Common screen_pctwid:XPOS pcthei:self.YPOS_START]];
	[self addChild:base];
	
	CCLabelTTF *text_disp = [[[Common cons_label_pos:[Common pct_of_obj:base pctx:0.15 pcty:0.5]
											 color:ccc3(0,0,0)
										  fontsize:16
											   str:[NSString stringWithFormat:@"Unlocked: %@!",[FreeRunStartAtManager name_for_loc:startat]]]
							 anchor_pt:ccp(0,0.5)] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
	[base addChild:text_disp];
	TexRect *tr = [FreeRunStartAtManager get_icon_for_loc:startat];
	CGPoint iconpt = text_disp.position;
	iconpt.x += text_disp.boundingBox.size.width + tr.rect.size.width * 0.5;
	
	
	[base addChild:[[CCSprite spriteWithTexture:tr.tex rect:tr.rect] pos:iconpt]];
	
	
	ct = 1;
	mode = TitleCardMode_DOWN;
	animct = self.TRANS_LEN;
	
	return self;
}
@end

@implementation FreePupsUIAnimation

+(FreePupsUIAnimation*)cons {
	return [FreePupsUIAnimation node];
}

-(id)init {
	self = [super init];
	self.TRANS_LEN = DEFAULT_TRANS_LEN;
	self.STAY_LEN = DEFAULT_STAY_LEN;
	self.YPOS_START = -0.3;
	self.YPOS_END = 0.125;
	
	[self setScale:1];
	
	base = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
								  rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"challengeintrocard"]];
	[base setPosition:[Common screen_pctwid:XPOS pcthei:self.YPOS_START]];
	[self addChild:base];
	
	ct = 1;
	mode = TitleCardMode_DOWN;
	animct = self.TRANS_LEN;
	
	[base addChild:[[Common cons_label_pos:[Common pct_of_obj:base pctx:0.5 pcty:0.65]
									color:ccc3(0,0,0)
								 fontsize:18
									  str:@"You freed the pups!"] set_scale:1/CC_CONTENT_SCALE_FACTOR()]];
	[base addChild:[[Common cons_label_pos:[Common pct_of_obj:base pctx:0.5 pcty:0.3]
									color:ccc3(40,40,40)
								 fontsize:11
									  str:@"(But there are still more to free!)"] set_scale:1/CC_CONTENT_SCALE_FACTOR()]];
	return self;
}

@end
