#import "InventoryTabPane_Settings.h"
#import "Common.h"
#import "Resource.h"
#import "FileCache.h"
#import "AudioManager.h"
#import "InventoryLayerTab.h"
#import "DataStore.h"
#import "Player.h"
#import "DailyLoginPrizeManager.h"
#import "GameMain.h"
#import "BasePopup.h"
#import "GameMain.h"
#import "DailyLoginPrizeManager.h"
#import "UserInventory.h"
#import "TrackingUtil.h"

@implementation InventoryTabPane_Settings {
	CCLabelTTF *version;
}

+(InventoryTabPane_Settings*)cons:(CCSprite *)parent {
	return [[InventoryTabPane_Settings node] cons:parent];
}
-(id)cons:(CCSprite*)parent {
	touches = [NSMutableArray array];
	
	PollingButton *playbgmb = [PollingButton cons_pt:CGPointZero
											  texkey:TEX_NMENU_ITEMS
											  yeskey:@"nmenu_checkbutton"
											   nokey:@"nmenu_xbutton"
												poll:[Common cons_callback:(NSObject*)[AudioManager class] sel:@selector(get_play_bgm)]
											   click:[Common cons_callback:self sel:@selector(toggle_play_bgm)]];
	[self addChild:[MenuCommon cons_descaler_for:playbgmb pos:[Common pct_of_obj:parent pctx:0.125 pcty:0.8]]];
	[touches addObject:playbgmb];
	
	[self addChild:[[[Common cons_label_pos:[Common pct_of_obj:parent pctx:0.2 pcty:0.8]
												   color:ccc3(0,0,0)
												fontsize:16
													 str:@"play music"] anchor_pt:ccp(0,0.5)] set_scale:1/CC_CONTENT_SCALE_FACTOR()]];
	
	PollingButton *playsfxb = [PollingButton cons_pt:CGPointZero
											  texkey:TEX_NMENU_ITEMS
											  yeskey:@"nmenu_checkbutton"
											   nokey:@"nmenu_xbutton"
												poll:[Common cons_callback:(NSObject*)[AudioManager class] sel:@selector(get_play_sfx)]
											   click:[Common cons_callback:self sel:@selector(toggle_play_sfx)]];
	[self addChild:[MenuCommon cons_descaler_for:playsfxb pos:[Common pct_of_obj:parent pctx:0.125 pcty:0.55]]];
	[touches addObject:playsfxb];
	[self addChild:[[[Common cons_label_pos:[Common pct_of_obj:parent pctx:0.2 pcty:0.55]
												   color:ccc3(0,0,0)
												fontsize:16
													 str:@"play sfx"] anchor_pt:ccp(0,0.5)] set_scale:1/CC_CONTENT_SCALE_FACTOR()]];
	
	TouchButton *cleardata = [AnimatedTouchButton cons_pt:CGPointZero
													  tex:[Resource get_tex:TEX_NMENU_ITEMS]
												  texrect:[FileCache get_cgrect_from_plist:TEX_NMENU_ITEMS idname:@"nmenu_shoptab"]
													   cb:[Common cons_callback:self sel:@selector(clear_data)]];
	[cleardata addChild:[[Common cons_label_pos:[Common pct_of_obj:cleardata pctx:0.5 pcty:0.5]
										 color:ccc3(0,0,0)
									  fontsize:13
										   str:@"Reset Data"] set_scale:1/CC_CONTENT_SCALE_FACTOR()]];
	[self addChild:[MenuCommon cons_descaler_for:cleardata pos:[Common pct_of_obj:parent pctx:0.4 pcty:0.25]]];
	[touches addObject:cleardata];
	
	TouchButton *replay_intro = [AnimatedTouchButton cons_pt:CGPointZero
													  tex:[Resource get_tex:TEX_NMENU_ITEMS]
												  texrect:[FileCache get_cgrect_from_plist:TEX_NMENU_ITEMS idname:@"nmenu_shoptab"]
													   cb:[Common cons_callback:self sel:@selector(replay_intro)]];
	[replay_intro addChild:[[Common cons_label_pos:[Common pct_of_obj:replay_intro pctx:0.5 pcty:0.5]
										 color:ccc3(0,0,0)
									  fontsize:13
										   str:@"Replay Intro"] set_scale:1/CC_CONTENT_SCALE_FACTOR()]];
	[self addChild:[MenuCommon cons_descaler_for:replay_intro pos:[Common pct_of_obj:parent pctx:0.16 pcty:0.25]]];
	[touches addObject:replay_intro];
	

	if ([GameMain GET_DEBUG_UI]) {
		TouchButton *next_day = [AnimatedTouchButton cons_pt:CGPointZero
															 tex:[Resource get_tex:TEX_NMENU_ITEMS]
														 texrect:[FileCache get_cgrect_from_plist:TEX_NMENU_ITEMS idname:@"nmenu_shoptab"]
															  cb:[Common cons_callback:self sel:@selector(none)]];
		[next_day addChild:[[Common cons_label_pos:[Common pct_of_obj:next_day pctx:0.5 pcty:0.5]
												color:ccc3(0,0,0)
											 fontsize:13
												  str:@"(DBG) None"] set_scale:1/CC_CONTENT_SCALE_FACTOR()]];
		[self addChild:[MenuCommon cons_descaler_for:next_day pos:[Common pct_of_obj:parent pctx:0.64 pcty:0.25]]];
		[touches addObject:next_day];
		
		
		TouchButton *unlock_all = [AnimatedTouchButton cons_pt:CGPointZero
														 tex:[Resource get_tex:TEX_NMENU_ITEMS]
													 texrect:[FileCache get_cgrect_from_plist:TEX_NMENU_ITEMS idname:@"nmenu_shoptab"]
														  cb:[Common cons_callback:self sel:@selector(debug_unlock_all)]];
		[unlock_all addChild:[[Common cons_label_pos:[Common pct_of_obj:next_day pctx:0.5 pcty:0.5]
											color:ccc3(0,0,0)
										 fontsize:13
											  str:@"(DBG) Unlock All"] set_scale:1/CC_CONTENT_SCALE_FACTOR()]];
		[self addChild:[MenuCommon cons_descaler_for:unlock_all pos:[Common pct_of_obj:parent pctx:0.88 pcty:0.25]]];
		[touches addObject:unlock_all];
		
	} else {
		TouchButton *spotcos_website = [AnimatedTouchButton cons_pt:CGPointZero
																tex:[Resource get_tex:TEX_NMENU_ITEMS]
															texrect:[FileCache get_cgrect_from_plist:TEX_NMENU_ITEMS idname:@"tshop_itemdisppane"]
																 cb:[Common cons_callback:self sel:@selector(open_spotcos_website)]];
		[self addChild:[MenuCommon cons_descaler_for:spotcos_website pos:[Common pct_of_obj:parent pctx:0.7 pcty:0.25]]];
		[touches addObject:spotcos_website];
		CCSprite *goober = [CCSprite node];
		[goober runAction:[Common cons_anim:@[@"goober1",@"goober2"] speed:0.3 tex_key:TEX_SPOTCOS_LOGO_SS]];
		[goober setPosition:[Common pct_of_obj:spotcos_website pctx:0.5 pcty:0.65]];
		[goober setScale:0.5];
		[spotcos_website addChild:goober];
		CCSprite *spotcos_logo = [CCSprite spriteWithTexture:[Resource get_tex:TEX_SPOTCOS_LOGO_SS] rect:[FileCache get_cgrect_from_plist:TEX_SPOTCOS_LOGO_SS idname:@"spotcos"]];
		[spotcos_logo setScale:0.3];
		[spotcos_logo setPosition:[Common pct_of_obj:spotcos_website pctx:0.5 pcty:0.05]];
		[spotcos_website addChild:spotcos_logo];
	}
	
	
	NSString *maxstr = @"000000000000000000000000000000000000\n000000000000000000000000000000000000\n000000000000000000000000000000000000\n000000000000000000000000000000000000\n000000000000000000000000000000000000\n000000000000000000000000000000000000\n";
    CGSize actualSize = [maxstr sizeWithFont:[UIFont fontWithName:@"Carton Six" size:13]
													  constrainedToSize:CGSizeMake(1000, 1000)
														  lineBreakMode:(NSLineBreakMode)UILineBreakModeWordWrap];
	version = [[CCLabelTTF labelWithString:@""
							   dimensions:actualSize
								alignment:UITextAlignmentCenter
								 fontName:@"Carton Six"
								 fontSize:13] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
	
	[version setColor:ccc3(20,20,20)];
	[version setPosition:[Common pct_of_obj:parent pctx:0.7 pcty:0.725]];
	
	[self setVisible:YES];
	
	[self addChild:version];
	
	return self;
}

-(void)none {
}

-(void)open_spotcos_website {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.spotcos.com"]];
}

-(void)set_pane_open:(BOOL)t {
	[self setVisible:t];
	
	[version setString:[NSString stringWithFormat:
		@"%@\n%@\n%@\n\nUUID:\n%@ ",
		[GameMain GET_VERSION_STRING],
		@"Online at (speedypups.com)",
		[UserInventory get_ads_disabled]?@"Thanks for buying Ad Free!":@"Unlock Ad Free at the store for $0.99!",
		[Common unique_id]
	]];
	
}

-(void)toggle_play_bgm {
	[AudioManager set_play_bgm:![AudioManager get_play_bgm]];
	[AudioManager playbgm_imm:BGM_GROUP_MENU];
	[UserInventory set_bgm_muted:![AudioManager get_play_bgm]];
	
}

-(void)toggle_play_sfx {
	[AudioManager set_play_sfx:![AudioManager get_play_sfx]];
	[AudioManager playsfx:SFX_MENU_UP];
	[UserInventory set_sfx_muted:![AudioManager get_play_sfx]];
}

-(void)clear_data {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
													message:@""
												   delegate:self
										  cancelButtonTitle:@"Yes"
										  otherButtonTitles:@"No",nil];
	[alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		[DataStore reset_all];
		[UserInventory set_bgm_muted:![AudioManager get_play_bgm]];
		[UserInventory set_sfx_muted:![AudioManager get_play_sfx]];
		[Player set_character:TEX_DOG_RUN_1];
		[GEventDispatcher immediate_event:[[GEvent cons_type:GEventType_QUIT] add_i1:0 i2:0]];
		[TrackingUtil track_evt:TrackingEvt_Reset];
	}
}

-(void)debug_unlock_all {
	[FreeRunStartAtManager set_can_start_at:FreeRunStartAt_WORLD1];
	[FreeRunStartAtManager set_can_start_at:FreeRunStartAt_LAB1];
	[FreeRunStartAtManager set_can_start_at:FreeRunStartAt_WORLD2];
	[FreeRunStartAtManager set_can_start_at:FreeRunStartAt_LAB2];
	[FreeRunStartAtManager set_can_start_at:FreeRunStartAt_WORLD3];
	[FreeRunStartAtManager set_can_start_at:FreeRunStartAt_LAB3];



	[UserInventory unlock_character:TEX_DOG_RUN_2];
	[UserInventory unlock_character:TEX_DOG_RUN_3];
	[UserInventory unlock_character:TEX_DOG_RUN_4];
	[UserInventory unlock_character:TEX_DOG_RUN_5];
	[UserInventory unlock_character:TEX_DOG_RUN_6];
	[UserInventory unlock_character:TEX_DOG_RUN_7];
	[ChallengeRecord set_beaten_challenge:19 to:YES];
	 
	[UserInventory add_bones:5000];
	[UserInventory add_coins:100];
}

-(void)replay_intro {
	[GEventDispatcher immediate_event:[[GEvent cons_type:GEventType_QUIT] add_i1:1 i2:0]];
}

-(void)update {
	if (!self.visible) return;
	for (id obj in touches) {
		if ([obj respondsToSelector:@selector(update)]) {
			[obj update];
		}
	}

}

-(void)touch_begin:(CGPoint)pt {
	if (!self.visible) return;
	for (TouchButton *b in touches) [b touch_begin:pt];
}

-(void)touch_end:(CGPoint)pt {
	if (!self.visible) return;
	for (TouchButton *b in touches) [b touch_end:pt];
}

@end
