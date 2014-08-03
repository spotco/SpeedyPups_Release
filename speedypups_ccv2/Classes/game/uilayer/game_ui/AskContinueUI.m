#import "AskContinueUI.h"
#import "PauseUI.h"
#import "Common.h"
#import "Resource.h"
#import "MenuCommon.h"
#import "UserInventory.h"
#import "GameEngineLayer.h"
#import "UICommon.h"
#import "UILayer.h"
#import "BoneCollectUIAnimation.h"
#import "SpeedyPupsIAP.h"
#import "GEventDispatcher.h" 

@implementation AskContinueUI

+(AskContinueUI*)cons {
    return [AskContinueUI node];
}

-(id)init {
    self = [super init];
    ccColor4B c = {50,50,50,220};
    CGSize s = [[UIScreen mainScreen] bounds].size;
    ask_continue_ui = [CCLayerColor layerWithColor:c width:s.height height:s.width];
	
	playericon = [[CSF_CCSprite spriteWithTexture:[Resource get_tex:[Player get_character]]
										 rect:[FileCache get_cgrect_from_plist:[Player get_character] idname:@"hit_3"]]
				  pos:[Common screen_pctwid:0.5 pcthei:0.4]];
    [ask_continue_ui addChild:playericon];
	
	curtains = [MenuCurtains cons];
	[ask_continue_ui addChild:curtains];
    
    [ask_continue_ui addChild:[[CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
                                                      rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"spotlight"]]
                               pos:[Common screen_pctwid:0.5 pcthei:0.6]]];
	
    continue_logo = [[CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
											rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"continue"]]
					 pos:[Common screen_pctwid:0.5 pcthei:0.8]];
    [ask_continue_ui addChild:continue_logo];
    
    CCMenuItem *yes = [MenuCommon item_from:TEX_UI_INGAMEUI_SS
                                       rect:@"yesbutton"
                                        tar:self sel:@selector(continue_yes)
                                        pos:[Common screen_pctwid:0.3 pcthei:0.4]];
    
    CCMenuItem *no = [MenuCommon item_from:TEX_UI_INGAMEUI_SS
                                      rect:@"nobutton"
                                       tar:self sel:@selector(continue_no)
                                       pos:[Common screen_pctwid:0.7 pcthei:0.4]];
    
    yesnomenu = [CCMenu menuWithItems:yes,no, nil];
    [yesnomenu setPosition:CGPointZero];
    [ask_continue_ui addChild:yesnomenu];
    
    countdown_disp = [Common cons_label_pos:[Common screen_pctwid:0.5 pcthei:0.575]
                                      color:ccc3(200, 30, 30) fontsize:50 str:@""];
    [ask_continue_ui addChild:countdown_disp];
	
	//continue price pane, below yes button
	continue_price_pane = [[CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
														   rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"continue_price_bg"]]
									 pos:[Common screen_pctwid:0.3 pcthei:0.25]];
	[continue_price_pane addChild:[[[CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
														 rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"menu_prize_fewcoin"]
								   ] pos:[Common pct_of_obj:continue_price_pane pctx:0.35 pcty:0.25]]
								   scale:0.5]];
	[continue_price_pane addChild:[[Common cons_label_pos:[Common pct_of_obj:continue_price_pane pctx:0.5 pcty:0.625]
												   color:ccc3(0,0,0)
												fontsize:10
													 str:@"price"] set_scale:1/CC_CONTENT_SCALE_FACTOR()]];
	[continue_price_pane addChild:[[Common cons_label_pos:[Common pct_of_obj:continue_price_pane pctx:0.525 pcty:0.275]
												   color:ccc3(200,30,30)
												fontsize:8
													 str:@"x"] set_scale:1/CC_CONTENT_SCALE_FACTOR()]];
	continue_price = [[[Common cons_label_pos:[Common pct_of_obj:continue_price_pane pctx:0.6 pcty:0.275]
									  color:ccc3(200,30,30)
								   fontsize:18
										str:@""] anchor_pt:ccp(0,0.5)] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
	[continue_price_pane addChild:continue_price];
	[ask_continue_ui addChild:continue_price_pane];
	
	//total bones pane, bottom right
	CCSprite *total_bones_pane = [[CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
														 rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"continue_total_bg"]]
								  pos:[Common screen_pctwid:0.89 pcthei:0.075]];
	[total_bones_pane addChild:[[[CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
													   rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"menu_prize_fewcoin"]
								  ] pos:[Common pct_of_obj:total_bones_pane pctx:0.15 pcty:0.3]]
								scale:0.5]];
	[total_bones_pane addChild:[[Common cons_label_pos:[Common pct_of_obj:total_bones_pane pctx:0.325 pcty:0.75]
												color:ccc3(0,0,0)
											 fontsize:10
												  str:@"Total Coins"] set_scale:1/CC_CONTENT_SCALE_FACTOR()]];
	total_disp = [[[Common cons_label_pos:[Common pct_of_obj:total_bones_pane pctx:0.3 pcty:0.325]
								  color:ccc3(200,30,30)
							   fontsize:20
									str:@""] anchor_pt:ccp(0,0.5)] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
	[total_bones_pane addChild:total_disp];
	[ask_continue_ui addChild:total_bones_pane];
	 
    [self addChild:ask_continue_ui];
	bone_anims = [NSMutableArray array];
	
    return self;
}

-(void)start_countdown:(int)cost {
	
	[AudioManager sto_prev_group];
	[AudioManager bgm_stop];
	[AudioManager playsfx:SFX_FANFARE_LOSE after_do:[Common cons_callback:(NSObject*)[AudioManager class] sel:@selector(play_jingle)]];
	
	
	[curtains set_curtain_animstart_positions];
    countdown_ct = 10;
	mod_ct = 1;
	countdown_disp_scale = 3;
	actual_cost = cost;
    continue_cost = cost;
	
	[countdown_disp setVisible:YES];
	[yesnomenu setVisible:YES];
	[playericon setPosition:[Common screen_pctwid:0.5 pcthei:0.4]];
	[playericon setTextureRect:[FileCache get_cgrect_from_plist:[Player get_character] idname:@"hit_3"]];
	
	curmode = AskContinueUI_COUNTDOWN;
	
    [self schedule:@selector(update:) interval:1/30.0];
    [countdown_disp setString:[NSString stringWithFormat:@"%d",countdown_ct]];
    [continue_price setString:[NSString stringWithFormat:@"%d",cost]];
    [total_disp setString:[NSString stringWithFormat:@"%d",[UserInventory get_current_coins]]];
}


-(void)update:(ccTime)delta {
	[Common set_dt:delta];
	mod_ct++;
	
	[curtains update];
	
	if (curmode == AskContinueUI_COUNTDOWN) {
		[self update_countdown];
		[continue_price_pane setVisible:YES];
		
	} else if (curmode == AskContinueUI_YES_TRANSFER_MONEY) {
		[self update_transfer_bones];
		[continue_price_pane setVisible:NO];
		
	} else if (curmode == AskContinueUI_YES_RUNOUT) {
		[self update_runout];
		[continue_price_pane setVisible:NO];
	
	} else if (curmode == AskContinueUI_TRANSITION_TO_GAMEOVER) {
		[continue_price_pane setVisible:NO];
		if ([Common fuzzyeq_a:curtains.bg_curtain.position.y b:curtains.bg_curtain_tpos.y delta:1]) {
			[self to_gameover_screen];
		}
		
	}
}

-(void)stop_countdown {
    [self unschedule:@selector(update:)];
}

-(void)continue_no {
	curmode = AskContinueUI_TRANSITION_TO_GAMEOVER;
	curtains.bg_curtain_tpos = ccp([Common SCREEN].width/2.0,0);
	for (CCNode *i in ask_continue_ui.children) {
		if (i != curtains) {
			[i setVisible:NO];
		}
	}
	
}

#define ALERT_TITLE_NOT_ENOUGH @"Not enough coins for a continue!"
#define ALERT_TITLE_ERROR_CONNECT @"Could not connect to the App Store!"
-(void)continue_yes {
    if ([UserInventory get_current_coins] >= continue_cost) {
		[AudioManager todos_remove_all];
		[countdown_disp setVisible:NO];
		[UserInventory add_coins:-continue_cost];
		countdown_ct = 1; //works as transfer rate now
		[yesnomenu setVisible:NO];
		
		actual_next_continue_price = continue_cost;
		
		[continue_price_pane setTextureRect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"continue_price_bg_nopoke"]];
		curmode = AskContinueUI_YES_TRANSFER_MONEY;
		
    } else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE_NOT_ENOUGH
														message:@""
													   delegate:self
											  cancelButtonTitle:@"10 Coins for 0.99¢"
											  otherButtonTitles:@"No thanks...",NULL];
		[alert show];
		curmode = AskContinueUI_COUNTDOWN_PAUSED;
		
	}
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (streq(alertView.title, ALERT_TITLE_NOT_ENOUGH)) {
		if (buttonIndex == 0) {
			[[IAPHelper sharedInstance] buyProduct:[SpeedyPupsIAP product_for_key:SPEEDYPUPS_10_COINS]];
			curmode = AskContinueUI_IAP;
		} else {
			curmode = AskContinueUI_COUNTDOWN;
		}
	} else if (streq(alertView.title, ALERT_TITLE_ERROR_CONNECT)) {
		curmode = AskContinueUI_COUNTDOWN;
	}
}

-(void)dispatch_event:(GEvent*)evt {
	if (evt.type == GEventType_IAP_SUCCESS) {
		curmode = AskContinueUI_COUNTDOWN;
		countdown_ct = 10;
		[total_disp setString:[NSString stringWithFormat:@"%d",[UserInventory get_current_coins]]];
		
	} else if (evt.type == GEventType_IAP_FAIL) {
		if (evt.i1 == 1) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE_ERROR_CONNECT
																		message:@""
																	   delegate:self
															  cancelButtonTitle:@"Ok"
															  otherButtonTitles:NULL];
			[alert show];
		} else {
			curmode = AskContinueUI_COUNTDOWN;
		}
	}
}

-(void)update_countdown {
	countdown_disp_scale = countdown_disp_scale - (countdown_disp_scale-1)/3;
	[countdown_disp setScale:countdown_disp_scale];
	
	[continue_price_pane csf_setScale:sinf(continue_price_pane_pulse_t)*0.25 + 1];
	continue_price_pane_pulse_t += 0.075;
	
	if (mod_ct%30==0) {
		countdown_ct--;
		[countdown_disp setString:[NSString stringWithFormat:@"%d",countdown_ct]];
		countdown_disp_scale = 3;
		
		if (countdown_ct == 3 || countdown_ct == 2 || countdown_ct == 1) [AudioManager playsfx:SFX_READY];
		
		if (countdown_ct <= 0) {
			[self continue_no];
			return;
		}
	}
}

-(void)dealloc {
	for (UIIngameAnimation *i in bone_anims) {
		[self removeChild:i cleanup:YES];
		[i repool];
	}
	[bone_anims removeAllObjects];
}

-(void)update_transfer_bones {
	NSMutableArray *toremove = [NSMutableArray array];
	for (UIIngameAnimation *i in bone_anims) {
		[i update];
		if (i.ct <= 0) {
			[self removeChild:i cleanup:YES];
			[toremove addObject:i];
			[i repool];
		}
	}
	[bone_anims removeObjectsInArray:toremove];
	[toremove removeAllObjects];
	
	if (bone_anims.count != 0) {
		if (mod_ct % 3 == 0) {
			player_anim_ct++;
			if (player_anim_ct%2==0) {
				[playericon setTextureRect:[FileCache get_cgrect_from_plist:[Player get_character] idname:@"hit_3"]];
			} else {
				[playericon setTextureRect:[FileCache get_cgrect_from_plist:[Player get_character] idname:@"hit_2"]];
			}
		}
	}
	
	if (continue_cost > 0) {
		if (mod_ct%10 == 0 || continue_cost == actual_cost) {
			if (continue_cost == actual_cost) {
				mod_ct = 1;
			}
			continue_cost--;
			BoneCollectUIAnimation *neuanim = [BoneCollectUIAnimation cons_start:[Common screen_pctwid:0.89 pcthei:0.075]
																			 end:CGPointAdd(playericon.position,ccp(-30,15))];
			[neuanim setTextureRect:[FileCache get_cgrect_from_plist:TEX_ITEM_SS idname:@"heart"]];
			
			[bone_anims addObject:neuanim];
			[self addChild:neuanim];
			[AudioManager playsfx:SFX_BONE];
		}
		int neutotal = ([UserInventory get_current_coins] + actual_cost) - (actual_cost - continue_cost);
		[total_disp setString:[NSString stringWithFormat:@"%d",neutotal]];
		
		
	} else if (bone_anims.count != 0) {
		[continue_price setString:[NSString stringWithFormat:@"%d",actual_next_continue_price]];
		[total_disp setString:[NSString stringWithFormat:@"%d",[UserInventory get_current_coins]]];
		
	} else {
		[playericon setTextureRect:[FileCache get_cgrect_from_plist:[Player get_character] idname:@"hit_3"]];
		[continue_price setString:[NSString stringWithFormat:@"%d",actual_next_continue_price]];
		[total_disp setString:[NSString stringWithFormat:@"%d",[UserInventory get_current_coins]]];
		continue_cost = 10; //used as pause ct now
		[playericon setTextureRect:[FileCache get_cgrect_from_plist:[Player get_character] idname:@"run_0"]];
		[Player character_bark];
		curmode = AskContinueUI_YES_RUNOUT;
		
		[AudioManager bgm_stop];
		[AudioManager playsfx:SFX_FANFARE_WIN after_do:[Common cons_callback:(NSObject*)[AudioManager class] sel:@selector(play_prev_group)]];
		
		
	}
}

-(void)update_runout {
	if (continue_cost > 0) {
		continue_cost--;
		
	} else if (playericon.position.x < [Common SCREEN].width) {
		playericon.position = CGPointAdd(playericon.position, ccp(10,0));
		if (mod_ct % 2 == 0) {
			player_anim_ct = (player_anim_ct + 1) % 4;
			[playericon setTextureRect:[FileCache get_cgrect_from_plist:[Player get_character]
																 idname:[NSString stringWithFormat:@"run_%d",player_anim_ct]]];
		}
		
	} else {
		[(UILayer*)[self parent] continue_game];
		[self stop_countdown];
		
	}
}

-(void)to_gameover_screen {
	[self stop_countdown];
    [(UILayer*)[self parent] to_gameover_menu];
}

@end
