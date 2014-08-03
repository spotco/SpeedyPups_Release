#import "DailyLoginPopup.h"
#import "FileCache.h"
#import "Resource.h"
#import "MenuCommon.h"
#import "Common.h" 
#import "Player.h"

@implementation DailyLoginPopup

+(DailyLoginPopup*)cons {
	return [[DailyLoginPopup node] i_cons];
}

-(DailyLoginPopup*)i_cons {
	[super cons];
	
	return self;
}

-(void)add_close_button:(CallBack *)on_close {
	[super add_close_button:on_close];
	
    CCMenuItem *closebutton = [MenuCommon item_from:TEX_NMENU_ITEMS
											   rect:@"nmenu_okbutton"
												tar:on_close.target sel:on_close.selector
												pos:CGPointZero];
	[closebutton setScale:0.8];
	[closebutton setAnchorPoint:ccp(0.5,0)];
    [closebutton setPosition:[Common pct_of_obj:self pctx:0.5 pcty:0.05]];
	CCMenu *invmh = [CCMenu menuWithItems:closebutton, nil];
	[invmh setPosition:CGPointZero];
    [self addChild:invmh];
}

+(BasePopup*)character_unlock_popup:(NSString *)key {
	BasePopup *p = [DailyLoginPopup cons];
	[p addChild:[Common cons_label_pos:[Common pct_of_obj:p pctx:0.5 pcty:0.85]
								 color:ccc3(30,30,30)
							  fontsize:32
								   str:@"Character Unlocked!"]];
	[p addChild:[Common cons_label_pos:[Common pct_of_obj:p pctx:0.5 pcty:0.72]
								 color:ccc3(200,30,30)
							  fontsize:16
								   str:[NSString stringWithFormat:@"Unlocked %@!",[Player get_full_name:key]]]];
	[p addChild:[Common cons_label_pos:[Common pct_of_obj:p pctx:0.65 pcty:0.6]
								 color:ccc3(200,30,30)
							  fontsize:16
								   str:@"Special Power:"]];
	[p addChild:[Common cons_label_pos:[Common pct_of_obj:p pctx:0.65 pcty:0.5]
								 color:ccc3(30,30,30)
							  fontsize:14
								   str:[NSString stringWithFormat:@"%@",[Player get_power_desc:key]]]];
	[p addChild:[[CCSprite spriteWithTexture:[Resource get_tex:key]
										rect:[FileCache get_cgrect_from_plist:key idname:@"run_0"]]
				 pos:[Common pct_of_obj:p pctx:0.3 pcty:0.45]]];
	return p;
}

@end
