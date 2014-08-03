#import "ExtrasUnlockPopup.h"
#import "FileCache.h"
#import "Resource.h"
#import "MenuCommon.h"
#import "ExtrasManager.h"

@implementation ExtrasUnlockPopup

+(ExtrasUnlockPopup*)cons_unlocking:(NSString *)key {
	return [[ExtrasUnlockPopup node] cons_unlocking:key];
}

-(id)cons_unlocking:(NSString*)key {
	[super cons];
	
	[self addChild:[Common cons_label_pos:[Common pct_of_obj:self pctx:0.5 pcty:0.875]
									color:ccc3(30,30,30)
								 fontsize:35
									  str:@"Extra Get!"]];
	
	Extras_Type type = [ExtrasManager type_for_key:key];
	
	[self addChild:[Common cons_label_pos:[Common pct_of_obj:self pctx:0.5 pcty:0.75]
								 color:ccc3(20,20,20)
							  fontsize:15
								   str:@"Unlocked an extra!"]];
	
	CCLabelTTF *name = [[Common cons_label_pos:[Common pct_of_obj:self pctx:0.5 pcty:0.6]
										 color:ccc3(200,30,30)
									  fontsize:20
										   str:[NSString stringWithFormat:@"\"%@\"",[ExtrasManager name_for_key:key]]]
						anchor_pt:ccp(0.5,0.5)];
	[self addChild:name];
	
	TexRect *tr = [ExtrasManager texrect_for_type:type];
	CCSprite *iconl = [CCSprite spriteWithTexture:tr.tex rect:tr.rect];
	[iconl setScale:1];
	[iconl setPosition:CGPointAdd(name.position, ccp(-name.boundingBox.size.width/2 - 25,0))];
	
	CCSprite *iconr = [CCSprite spriteWithTexture:tr.tex rect:tr.rect];
	[iconr setScale:1];
	[iconr setPosition:CGPointAdd(name.position, ccp(name.boundingBox.size.width/2 + 25,0))];
	[self addChild:iconl];
	[self addChild:iconr];

	[self addChild:[Common cons_label_pos:[Common pct_of_obj:self pctx:0.5 pcty:0.45]
									color:ccc3(20,20,20)
								 fontsize:12
									  str:@"(View it in your inventory extras page)"]];
	
	
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

@end
