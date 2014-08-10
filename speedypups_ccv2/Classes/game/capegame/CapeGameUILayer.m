#import "CapeGameUILayer.h"
#import "IngameUI.h"
#import "UICommon.h"
#import "Common.h"
#import "FileCache.h"
#import "Resource.h"
#import "MenuCommon.h"
#import "GameMain.h"
#import "CapeGameEngineLayer.h"
#import "UILayer.h"
#import "BoneCollectUIAnimation.h"
#import "ChallengeInfoTitleCardAnimation.h"
#import "GameEngineLayer.h"
#import "ScoreManager.h"
#import "ScoreComboAnimation.h"
#import "BossRushAutoLevel.h"

@implementation CapeGameUILayer {
	float last_mult;
}

+(CapeGameUILayer*)cons_g:(CapeGameEngineLayer*)g {
	CapeGameUILayer *l = [[CapeGameUILayer node] cons:g];
	return l;
}

-(id)cons:(CapeGameEngineLayer*)g {
	cape_game = g;
	last_mult = [[g get_main_game].score get_multiplier];
	ingame_ui = [CCNode node];
	exit_to_gameover_menu = NO;
	
	CCSprite *pauseicon = [CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS] rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"pauseicon"]];
	CCSprite *pauseiconzoom = [CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS] rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"pauseicon"]];
	
    [UICommon set_zoom_pos_align:pauseicon zoomed:pauseiconzoom scale:1.4];
    
    CCMenuItemImage *ingamepause = [MRectCCMenuItemImage itemFromNormalSprite:pauseicon
															   selectedSprite:pauseiconzoom
																	   target:self
																	 selector:@selector(pause)];
	[ingamepause setScale:CC_CONTENT_SCALE_FACTOR()];
    [ingamepause setPosition:ccp(
								 [Common SCREEN].width-([pauseicon boundingBox].size.width)*CC_CONTENT_SCALE_FACTOR()+10,
								 [Common SCREEN].height-([pauseicon boundingBox].size.height)*CC_CONTENT_SCALE_FACTOR()+10
								 )];
	
    CCMenu *ingame_ui_m = [CCMenu menuWithItems:ingamepause,nil];
    
    ingame_ui_m.anchorPoint = ccp(0,0);
    ingame_ui_m.position = ccp(0,0);
    [ingame_ui addChild:ingame_ui_m];
	
	itemlenbarroot = [CSF_CCSprite node];
	if (cape_game.is_boss_capegame) [self itembar_set_visible:NO];
	CCSprite *itemlenbarback = [CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
													  rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS
																					 idname:@"item_timebaremptytex"]];
	[itemlenbarroot addChild:itemlenbarback];
	itemlenbarfill = [CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
											rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS
																		   idname:@"item_timebarfulltex"]];
	[itemlenbarroot addChild:itemlenbarfill];
	
	[itemlenbarback setAnchorPoint:ccp(0,0.5)];
	[itemlenbarfill setAnchorPoint:ccp(0,0.5)];
	
	[itemlenbarback setPosition:ccp(-68/CC_CONTENT_SCALE_FACTOR(),0)];
	[itemlenbarfill setPosition:ccp(-68/CC_CONTENT_SCALE_FACTOR(),0)];
	
	[itemlenbarroot addChild:[CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
													rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS
																				   idname:@"item_timebar"]]];
	[itemlenbarroot setPosition:[Common screen_pctwid:0.82 pcthei:0.09]];
	
    [ingame_ui addChild:itemlenbarroot];
	[itemlenbarfill setScaleX:1];
	for (CCSprite *i in [itemlenbarroot children]) {
		[i setOpacity:175];
	}
	itemlenbaricon =
	[CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_ITEM_SS]
							   rect:[FileCache get_cgrect_from_plist:TEX_ITEM_SS idname:[g is_boss_capegame]?@"item_rocket":@"item_dogcape"]];
	[itemlenbaricon setPosition:ccp(52.5/CC_CONTENT_SCALE_FACTOR(),0)];
	[itemlenbaricon setScale:0.8];
	[itemlenbaricon setOpacity:200];
	[itemlenbarroot addChild:itemlenbaricon];
	
	//challenge disp
	challengedescbg = [[CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
												  rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS
																				 idname:@"challengedescbg"]]
					   pos:[Common screen_pctwid:0.01 pcthei:0.98]];
	[challengedescbg setAnchorPoint:ccp(0,1)];
	[challengedescbg csf_setScaleX:0.8];
	[challengedescbg csf_setScaleY:0.75];
	[challengedescbg setOpacity:80];
	[self addChild:challengedescbg];
	
	challengedesc = [Common cons_bmlabel_pos:ccp(0,0) color:ccc3(0, 0, 0) fontsize:25 str:@""];
	[challengedesc setPosition:[Common pct_of_obj:challengedescbg pctx:0.325 pcty:0.5]];
	[challengedesc setAnchorPoint:ccp(0,0.5)];
	[challengedescbg addChild:challengedesc];
	
	TexRect *challengetr = [ChallengeRecord get_for:ChallengeType_COLLECT_BONES];
	challengedescincon = [[CCSprite spriteWithTexture:challengetr.tex rect:challengetr.rect]
						  pos:[Common pct_of_obj:challengedescbg pctx:0.125 pcty:0.5]];
	[challengedescincon setAnchorPoint:ccp(0.5,0.5)];
	[challengedescincon setScale:1.25];
	
	[challengedescbg addChild:challengedescincon];
	[challengedescbg setVisible:NO];
 	
	[self addChild:ingame_ui];
	
	uianim_holder = [CCNode node];
	[ingame_ui addChild:uianim_holder];
	uianims = [NSMutableArray array];
	
	
	//score disp
	scoredispbg = [[CSF_CCSprite node] pos:[Common screen_pctwid:0.01 pcthei:0.98]];
	
	CCSprite *score_disp_back = [CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
													   rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS
																					  idname:@"challengedescbg"]];
	[score_disp_back setAnchorPoint:ccp(0,1)];
	[score_disp_back setScaleX:0.8];
	[score_disp_back setScaleY:0.75];
	[scoredispbg addChild:score_disp_back];
	[score_disp_back setOpacity:80];
	
	scoredisp = [[Common cons_bmlabel_pos:[Common pct_of_obj:score_disp_back pctx:0.075 pcty:0.95-1]
									color:ccc3(200,30,30)
								 fontsize:24
									  str:@""] anchor_pt:ccp(0,1)];
	[scoredispbg addChild:scoredisp];
	
	//combo disp
	CCSprite *combo_disp_back = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
														   rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS
																						  idname:@"challengedescbg"]];
	[combo_disp_back setPosition:[Common pct_of_obj:score_disp_back pctx:1.05*0.8 pcty:0]];
	[combo_disp_back setScaleX:0.3];
	[combo_disp_back setScaleY:0.75];
	[combo_disp_back setAnchorPoint:ccp(0,1)];
	[scoredispbg addChild:combo_disp_back];
	[combo_disp_back setOpacity:80];
	
	[scoredispbg addChild:[[Common cons_label_pos:[Common pct_of_obj:score_disp_back pctx:1.05*0.8+0.09 pcty:0.7-1-0.06]
											color:ccc3(200,30,30)
										 fontsize:10
											  str:@"x"] set_scale:1/CC_CONTENT_SCALE_FACTOR()]];
	
	multdisp = [[Common cons_bmlabel_pos:[Common pct_of_obj:score_disp_back pctx:1.05*0.8+0.15 pcty:0.95-1]
								   color:ccc3(200,30,30)
								fontsize:24
									 str:@""] anchor_pt:ccp(0,1)];
	[scoredispbg addChild:multdisp];
	[self addChild:scoredispbg];
	
	
	CGPoint disp_icon_pos = ccp(
								scoredispbg.position.x,
								scoredispbg.position.y-(score_disp_back.boundingBox.size.height)*CC_CONTENT_SCALE_FACTOR() - 5
								);
	bones_disp = [self cons_icon_section_pos:disp_icon_pos icon:@"ingame_ui_bone_icon"];
	disp_icon_pos.y -= 24;
	lives_disp = [self cons_icon_section_pos:disp_icon_pos icon:@"ingame_ui_lives_icon"];
	disp_icon_pos.y -= 24;
	time_disp = [self cons_icon_section_pos:disp_icon_pos icon:@"ingame_ui_time_icon"];
	
	if ([[g get_main_game] get_challenge]) {
		ChallengeType type = [[g get_main_game] get_challenge].type;
		[scoredispbg setVisible:NO];
		[challengedescbg setVisible:YES];
		TexRect *challengetr = [ChallengeRecord get_for:type];
		challengedescincon.texture = challengetr.tex;
		challengedescincon.textureRect = challengetr.rect;
		challengedesc.string = @"";
	}
	
	current_disp_score = [cape_game.get_main_game.score get_score];
	
	[self cons_pause_ui];
	[self addChild:pause_ui];
	[pause_ui setVisible:NO];
	
	return self;
}

-(CCLabelBMFont*)cons_icon_section_pos:(CGPoint)section_pos icon:(NSString*)icon {
	CCSprite *bone_disp_section = [[CSF_CCSprite node] pos:section_pos];
	CCSprite *bone_disp_bg = [[CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS] rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"challengedescbg"]]
							  anchor_pt:ccp(0,1)];
	[bone_disp_bg setScaleX:0.5];
	[bone_disp_bg setScaleY:0.5];
	[bone_disp_bg setOpacity:80];
	[bone_disp_section addChild:bone_disp_bg];
	[self addChild:bone_disp_section];
	
	CCSprite *bone_disp_icon = [CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
													  rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:icon]];
	[bone_disp_icon setPosition:[Common pct_of_obj:bone_disp_bg pctx:0.15*0.5 pcty:-0.5*0.5]];
	[bone_disp_section addChild:bone_disp_icon];
	
	CCLabelBMFont *bones_text_disp = [[Common cons_bmlabel_pos:[Common pct_of_obj:bone_disp_bg pctx:0.4*0.5 pcty:-0.5*0.5]
														 color:ccc3(200,30,30)
													  fontsize:13
														   str:@""]
									  anchor_pt:ccp(0,0.5)];
	[bone_disp_section addChild:bones_text_disp];
	return bones_text_disp;
}

-(void)itembar_set_visible:(BOOL)b {
	[itemlenbarroot setVisible:b];
}

-(void)cons_pause_ui {
	ccColor4B c = {50,50,50,220};
    CGSize s = [[UIScreen mainScreen] bounds].size;
    pause_ui = [CCLayerColor layerWithColor:c width:s.height height:s.width];
    pause_ui.anchorPoint = ccp(0,0);
    [pause_ui setPosition:ccp(0,0)];
	
	curtains = [MenuCurtains cons];
	[pause_ui addChild:curtains];
    
    [pause_ui addChild:[Common cons_label_pos:[Common screen_pctwid:0.5 pcthei:0.8]
                                        color:ccc3(255, 255, 255)
                                     fontsize:45
                                          str:@"paused"]];
	
	CCSprite *disp_root = [CCSprite node];
	[disp_root setPosition:[Common screen_pctwid:0.575 pcthei:0.65]];
	[disp_root setScale:0.85];
	[pause_ui addChild:disp_root];
    
    CCSprite *bonesbg = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS] rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"pauseinfobones"]];
    [disp_root addChild:bonesbg];
    
    CCSprite *livesbg = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS] rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"pauseinfolives"]];
    [livesbg setPosition:ccp(livesbg.position.x, livesbg.position.y - [livesbg boundingBox].size.height - 5)];
    [disp_root addChild:livesbg];
	
	CCSprite *timebg = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS] rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"pauseinfoblank"]];
    [timebg setPosition:ccp(livesbg.position.x,livesbg.position.y - [livesbg boundingBox].size.height - 5)];
	[disp_root addChild:timebg];
	
	CSF_CCSprite *pointsbg = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS] rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"pauseinfoblank"]];
	[pointsbg setPosition:ccp(timebg.position.x,timebg.position.y - [livesbg boundingBox].size.height - 10)];
	[pointsbg csf_setScale:1.25];
	[disp_root addChild:pointsbg];
	
	for (CCSprite *c in @[timebg,bonesbg,livesbg,pointsbg]) {
		[c setOpacity:200];
	}
    
    pause_time_disp = [[Common cons_label_pos:[Common pct_of_obj:timebg pctx:0.5 pcty:0.5]
										color:ccc3(255, 255, 255)
									 fontsize:20
										  str:@"Time: 0:00"] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
    [timebg addChild:pause_time_disp];
    
    pause_bones_disp= [[Common cons_label_pos:[Common pct_of_obj:bonesbg pctx:0.5 pcty:0.5]
										color:ccc3(255, 255, 255)
									 fontsize:30
										  str:@"0"] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
    [bonesbg addChild:pause_bones_disp];
    
    pause_lives_disp= [[Common cons_label_pos:[Common pct_of_obj:livesbg pctx:0.5 pcty:0.5]
										color:ccc3(255, 255, 255)
									 fontsize:30
										  str:@"0"] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
    [livesbg addChild:pause_lives_disp];
	
	pause_points_disp = [[Common cons_label_pos:[Common pct_of_obj:pointsbg pctx:0.5 pcty:0.5]
										  color:ccc3(255,255,255)
									   fontsize:20
											str:@""] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
	[pointsbg addChild:pause_points_disp];
	
	pause_new_high_score_disp = [[[Common cons_label_pos:[Common pct_of_obj:pointsbg pctx:1 pcty:1]
												   color:ccc3(255,200,20)
												fontsize:10
													 str:@"New Highscore!"] anchor_pt:ccp(1,1)] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
	[pointsbg addChild:pause_new_high_score_disp];
    
    CCMenuItem *retrybutton = [MenuCommon item_from:TEX_UI_INGAMEUI_SS rect:@"retrybutton" tar:self sel:@selector(retry)
                                                pos:[Common screen_pctwid:0.3 pcthei:0.32]];
    
    CCMenuItem *playbutton = [MenuCommon item_from:TEX_UI_INGAMEUI_SS rect:@"playbutton" tar:self sel:@selector(unpause)
                                               pos:[Common screen_pctwid:0.94 pcthei:0.9]];
    
    CCMenuItem *backbutton = [MenuCommon item_from:TEX_UI_INGAMEUI_SS rect:@"prevbutton" tar:self sel:@selector(exit_to_menu)
                                               pos:[Common screen_pctwid:0.3 pcthei:0.6]];
    
    CCMenu *pausebuttons = [CCMenu menuWithItems:retrybutton,playbutton,backbutton, nil];
    [pausebuttons setPosition:ccp(0,0)];
    [pause_ui addChild:pausebuttons];
    
	[UICommon button:playbutton add_desctext:@"unpause" color:ccc3(255,255,255) fntsz:12];
	[UICommon button:retrybutton add_desctext:@"retry" color:ccc3(255,255,255) fntsz:12];
	[UICommon button:backbutton add_desctext:@"quit" color:ccc3(255,255,255) fntsz:12];
	
	update_timer = [NSTimer scheduledTimerWithTimeInterval: 1/30.0
													target: self
												  selector:@selector(update_pause_menu)
												  userInfo: nil repeats:YES];
	
}

-(void)update {
    NSMutableArray *toremove = [NSMutableArray array];
    for (UIIngameAnimation *i in uianims) {
        [i update];
        if (i.ct <= 0) {
            [uianim_holder removeChild:i cleanup:YES];
            [toremove addObject:i];
			[i repool];
        }
    }
    [uianims removeObjectsInArray:toremove];
    [toremove removeAllObjects];
	
	[self update_scoredisp:[cape_game get_main_game]];
	
	
	if (floor(last_mult) < floor([[cape_game get_main_game].score get_multiplier])) {
		[self start_combo_anim:cape_game.get_main_game.score.get_multiplier];
	}
	last_mult = [[cape_game get_main_game].score get_multiplier];
	
	if (challengedescbg.visible) {
		NSString *tar_str = @"top lel";
		if ([[cape_game get_main_game] get_challenge].type == ChallengeType_FIND_SECRET) {
			if ([[cape_game get_main_game] get_num_secrets] >= [[cape_game get_main_game] get_challenge].ct) {
				[challengedesc setColor:ccc3(0,255,0)];
			} else {
				[challengedesc setColor:ccc3(200,30,30)];
			}
			tar_str = strf("%i/%i",[[cape_game get_main_game] get_num_secrets],[[cape_game get_main_game] get_challenge].ct);
		} else if ([[cape_game get_main_game] get_challenge].type == ChallengeType_BOSSRUSH) {
			BossRushAutoLevel *tar = NULL;
			for (GameObject *o in [cape_game get_main_game].game_objects) {
				if (o.class == [BossRushAutoLevel class]) {
					tar = (BossRushAutoLevel*)o;
					break;
				}
			}
			[challengedesc setColor:ccc3(200,30,30)];
			if (tar) {
				if ([tar get_display_count] >= 4) {
					[challengedesc setColor:ccc3(0,255,0)];
				}
				tar_str = [NSString stringWithFormat:@"%d/4",[tar get_display_count]];
			}
		}
		[challengedesc set_label:tar_str];
	}
	
}

-(void)start_combo_anim:(float)combo {
	ScoreComboAnimation *c = [ScoreComboAnimation cons_combo:combo];
	[uianim_holder addChild:c];
	[uianims addObject:c];
}


-(void)update_scoredisp:(GameEngineLayer*)g {
	if (current_disp_score != [g.score get_score]) {
		if (ABS([g.score get_score] - current_disp_score) > 1) {
			current_disp_score = current_disp_score + ([g.score get_score] - current_disp_score)/4;
			
		} else {
			current_disp_score = [g.score get_score];
		}
		
	}
	int imult = [g.score get_multiplier];
	[scoredisp set_label:strf("%d",(int)current_disp_score)];
	[multdisp set_label:strf("%d",imult)];
}

-(void)update_pause_menu {
	[curtains update];
	if (exit_to_gameover_menu) {
		for (CCNode *i in pause_ui.children) if ([i class] != [MenuCurtains class]) [i setVisible:NO];
		if ([Common fuzzyeq_a:curtains.bg_curtain.position.y b:curtains.bg_curtain_tpos.y delta:1]) {
			cape_game.get_main_game.current_mode = GameEngineLayerMode_GAMEEND;
			[update_timer invalidate];
			[[CCDirector sharedDirector] popScene];
			[cape_game.get_main_game.get_ui_layer to_gameover_menu];
			return;
		}
	}
}

-(CCLabelBMFont*)bones_disp { return bones_disp; }
-(CCLabelBMFont*)lives_disp { return lives_disp; }
-(CCLabelBMFont*)time_disp { return time_disp; }

-(void)update_pct:(float)pct {
	[itemlenbarfill setScaleX:pct];
}

-(void)do_bone_collect_anim:(CGPoint)start {
    BoneCollectUIAnimation* b = [BoneCollectUIAnimation cons_start:start end:[Common screen_pctwid:0 pcthei:1]];
    [uianim_holder addChild:b];
    [uianims addObject:b];
}

-(void)do_treat_collect_anim:(CGPoint)start {
    TreatCollectUIAnimation* c = [TreatCollectUIAnimation cons_start:start end:[Common screen_pctwid:0 pcthei:1]];
    [uianim_holder addChild:c];
    [uianims addObject:c];
}

-(void)do_tutorial_anim {
	UIIngameAnimation *ua = [MessageTitleCardAnimation cons_msg:@"Touch to fly,\nand watch out for spikes!"];
	[uianim_holder addChild:ua];
	[uianims addObject:ua];
}

-(void)pause {
	[AudioManager playsfx:SFX_MENU_UP];
	[curtains set_curtain_animstart_positions];
	[ingame_ui setVisible:NO];
	[pause_ui setVisible:YES];
	
	[pause_bones_disp setString:[bones_disp string]];
	[pause_lives_disp setString:[lives_disp string]];
	[pause_time_disp setString:[time_disp string]];
	[pause_points_disp setString:strf("Score \u00B7 %d",[cape_game.get_main_game.score get_score])];
	[pause_new_high_score_disp setVisible:[ScoreManager get_world_highscore:cape_game.get_main_game.world_mode.cur_world] < [cape_game.get_main_game.score get_score]];
	
	[cape_game pause:YES];
}

-(void)unpause {
	[AudioManager playsfx:SFX_MENU_DOWN];
	[ingame_ui setVisible:YES];
	[pause_ui setVisible:NO];
	[cape_game pause:NO];
}

-(void)retry {
	[AudioManager playsfx:SFX_MENU_DOWN];
	[update_timer invalidate];
	[[CCDirector sharedDirector] popScene];
	
	GameModeCallback *cbv = [[[cape_game get_main_game] get_ui_layer] get_retry_callback];
	if (cbv == NULL) {
		NSLog(@"cbv is null");
		[GEventDispatcher push_event:[GEvent cons_type:GEventType_QUIT]];
		
	} else {
		[GEventDispatcher push_event:[[GEvent cons_type:GEventType_RETRY_WITH_CALLBACK] add_key:@"callback" value:cbv]];
	}
	
}

-(void)exit_to_menu {
	[AudioManager playsfx:SFX_MENU_DOWN];
	[[CCDirector sharedDirector] resume];
	curtains.bg_curtain_tpos = ccp([Common SCREEN].width/2.0,0);
	exit_to_gameover_menu = YES;
}

-(void)exit {
	[update_timer invalidate];
	cape_game = NULL;
}

-(void)dealloc {
	for (UIIngameAnimation *i in uianims) {
		[uianim_holder removeChild:i cleanup:YES];
		[i repool];
	}
	[uianims removeAllObjects];
	[self removeAllChildrenWithCleanup:YES];
}

@end
