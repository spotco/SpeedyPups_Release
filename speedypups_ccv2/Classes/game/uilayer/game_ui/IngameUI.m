#import "IngameUI.h"
#import "Common.h"
#import "Resource.h"
#import "MenuCommon.h"
#import "UserInventory.h"
#import "GameEngineLayer.h"
#import "UICommon.h"
#import "UILayer.h"
#import "LauncherRocket.h"
#import "UIEnemyAlert.h"
#import "UIWaterAlert.h"
#import "ScoreManager.h"
#import "BossRushAutoLevel.h"

@implementation MRectCCMenuItemImage
-(CGRect)rect {
	CGRect rect = [super rect];
	rect.size.width += 20;
	rect.size.height += 20;
	return rect;
}
@end

@implementation IngameUI

@synthesize lives_disp,bones_disp,time_disp;

+(IngameUI*)cons {
    return [IngameUI node];
}

#define ITEM_LENBAR_HIDE_DURATION 10.0f
#define ITEM_LENBAR_DEFAULT_POSITION [Common screen_pctwid:0.82 pcthei:0.09]
#define ITEM_LENBAR_HIDDEN_POSITION [Common screen_pctwid:0.82 pcthei:-0.2]

-(id)init {
    self = [super init];
	
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
	
	enemy_alert_ui = [UIEnemyAlert cons];
	[enemy_alert_ui setVisible:NO];
	[self addChild:enemy_alert_ui];
	
	water_alert_ui = [UIWaterAlert cons];
	[self addChild:water_alert_ui];
	
    ingame_ui_item_slot = [MainSlotItemPane cons_pt:[Common screen_pctwid:0.93 pcthei:0.09] cb:[Common cons_callback:self sel:@selector(itemslot_use)] slot:0];
    [ingame_ui_item_slot setScale:0.75 * CC_CONTENT_SCALE_FACTOR()];
    [ingame_ui_item_slot setOpacity:120];
    
    CCMenu *ingame_ui = [CCMenu menuWithItems:
                 ingamepause,
                 ingame_ui_item_slot,
                 nil];
    
    ingame_ui.anchorPoint = ccp(0,0);
    ingame_ui.position = ccp(0,0);
    [self addChild:ingame_ui];
	
	itemlenbarroot = [CSF_CCSprite node];
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
	[itemlenbarroot setPosition:ITEM_LENBAR_HIDDEN_POSITION];
	
	itemlenbar_target_pos = ITEM_LENBAR_HIDDEN_POSITION;
	
    [self addChild:itemlenbarroot];
	[itemlenbarfill setScaleX:0.5];
	for (CCSprite *i in [itemlenbarroot children]) {
		[i setOpacity:175];
	}
	itemlenbaricon = [CCSprite node];
	[itemlenbaricon setPosition:ccp(52.5/CC_CONTENT_SCALE_FACTOR(),0)];
	[itemlenbaricon setScale:0.8];
	[itemlenbaricon setOpacity:200];
	[itemlenbarroot addChild:itemlenbaricon];
	
	readynotif = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
												  rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS
																				 idname:@"item_ready"]];
	[readynotif setPosition:[Common screen_pctwid:0.855 pcthei:0.18]];
	[readynotif setOpacity:220];
	[self addChild:readynotif];
	[readynotif setVisible:NO];
	
#define tag_readynotif_label 234
	CCLabelTTF *readynotif_label = [[Common cons_label_pos:CGPointZero color:ccc3(0,0,0) fontsize:15 str:@"Tap!"] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
	[readynotif_label setPosition:[Common pct_of_obj:readynotif pctx:0.5 pcty:0.61]];
	[readynotif_label setOpacity:150];
	[readynotif addChild:readynotif_label z:0 tag:tag_readynotif_label];
	
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
	item_slot_notify_anim_sc = 1;
	
	
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
	 
    return self;
}

-(CCLabelBMFont*)cons_icon_section_pos:(CGPoint)section_pos icon:(NSString*)icon {
	CCSprite *bone_disp_section = [[CSF_CCSprite node] pos:section_pos];
	CCSprite *bone_disp_bg = [[CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
													 rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS
																					idname:@"challengedescbg"]]
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

-(void)pause {
    UILayer *p = (UILayer*)[self parent];
    [p pause];
	[AudioManager playsfx:SFX_MENU_UP];
	[Resource unload_textures];
}

-(void)itemslot_use {
    UILayer *p = (UILayer*)[self parent];
    [p itemslot_use];
}

-(void)enable_challengedesc_type:(ChallengeType)type {
	[scoredispbg setVisible:NO];
	[challengedescbg setVisible:YES];
	TexRect *challengetr = [ChallengeRecord get_for:type];
	challengedescincon.texture = challengetr.tex;
	challengedescincon.textureRect = challengetr.rect;
	challengedesc.string = @"";
}

-(void)set_challengedesc_string:(NSString*)str {
	[challengedesc setString:str];
}

static GameItem last_item = Item_NOITEM;
static int ct  = 0;
-(void)update:(GameEngineLayer*)g {
	ct ++;
	item_slot_notify_anim_sc = item_slot_notify_anim_sc - (item_slot_notify_anim_sc-1)/3;
	[ingame_ui_item_slot setScale:item_slot_notify_anim_sc * CC_CONTENT_SCALE_FACTOR()];

	[enemy_alert_ui update:g];
	[water_alert_ui update:g];
    
	[bones_disp set_label:strf("%i",[g get_num_bones])];
	[lives_disp set_label:strf("\u00B7 %s",[g get_lives] == GAMEENGINE_INF_LIVES ? "\u221E":strf("%i",[g get_lives]).UTF8String)];
    [time_disp set_label:[UICommon parse_gameengine_time:[g get_time]]];
	
	[itemlenbarroot setPosition:ccp(
		itemlenbarroot.position.x + (itemlenbar_target_pos.x - itemlenbarroot.position.x)/4.0,
		itemlenbarroot.position.y + (itemlenbar_target_pos.y - itemlenbarroot.position.y)/4.0
	 )];
		
	if (item_duration_pct > 0) {
		[itemlenbarroot setVisible:YES];
		[ingame_ui_item_slot setVisible:NO];
		[itemlenbarfill setScaleX:item_duration_pct];
		itemlenbar_target_pos = ITEM_LENBAR_DEFAULT_POSITION;
		
		if (g.player.is_clockeffect && ![GameControlImplementation get_clockbutton_hold]) {
			[(CCLabelBMFont*)[readynotif getChildByTag:tag_readynotif_label] set_label:@"Slow!"];
			[readynotif setVisible:YES];
			[itemlenbaricon setScale:1];
			
		} else {
			if (g.player.is_clockeffect && [GameControlImplementation get_clockbutton_hold]) {
				[itemlenbaricon setScale:1.3];
			} else {
				[itemlenbaricon setScale:1];
			}
			if (g.player.is_clockeffect) {
				[(CCLabelBMFont*)[readynotif getChildByTag:tag_readynotif_label] set_label:@"Fast!"];
				[readynotif setVisible:YES];
			} else {
				[readynotif setVisible:NO];
			}
			
		}
		
		
	} else {
		//[itemlenbarroot setVisible:NO];
		itemlenbar_target_pos = ITEM_LENBAR_HIDDEN_POSITION;
		
		[ingame_ui_item_slot set_locked:NO];
		if ([UserInventory get_current_gameitem] != Item_NOITEM) {
			[readynotif setVisible:YES];
			[ingame_ui_item_slot setVisible:YES];
			if (last_item != [UserInventory get_current_gameitem]) [self update_item_slot];
			
			[readynotif setVisible:(ct/25)%2==0];
			[(CCLabelTTF*)[readynotif getChildByTag:tag_readynotif_label] set_label:@"Tap!"];
			
		} else {
			[ingame_ui_item_slot set_locked:YES];
			[readynotif setVisible:NO];
			[ingame_ui_item_slot setVisible:NO];
		}
	}
	last_item = [UserInventory get_current_gameitem];
	
	if (challengedescbg.visible) {
		ChallengeInfo *cinfo = [g get_challenge];
		NSString *tar_str = @"top lel";
		if (cinfo.type == ChallengeType_COLLECT_BONES) {
			if ([g get_num_bones] >= cinfo.ct) {
				[challengedesc setColor:ccc3(0,255,0)];
			} else {
				[challengedesc setColor:ccc3(200,30,30)];
			}
			tar_str = strf("%i/%i",[g get_num_bones],cinfo.ct);
			
		} else if (cinfo.type == ChallengeType_FIND_SECRET) {
			if ([g get_num_secrets] >= cinfo.ct) {
				[challengedesc setColor:ccc3(0,255,0)];
			} else {
				[challengedesc setColor:ccc3(200,30,30)];
			}
			tar_str = strf("%i/%i",[g get_num_secrets],cinfo.ct);
			
		} else if (cinfo.type == ChallengeType_TIMED) {
			int tm = cinfo.ct - [g get_time];
			
			NSString *cur_time = [UICommon parse_gameengine_time:tm];
			if (![cur_time isEqualToString:last_time] && ([cur_time isEqualToString:@"0:02"] || [cur_time isEqualToString:@"0:01"] ||[cur_time isEqualToString:@"0:00"])) {
				[AudioManager playsfx:SFX_READY];
			}
			
			if (tm <= 0) {
				if ([cur_time isEqualToString:@"0:00"]) {
					ccColor3B last_color = challengedesc.color;
					if (last_color.g != 186) {
						[AudioManager playsfx:SFX_GO];
					}
					[challengedesc setColor:ccc3(255,186,0)];
					tar_str = cur_time;
				} else {
					[challengedesc setColor:ccc3(255,0,0)];
					tar_str = @"failed";
				}
			} else {
				tar_str = cur_time;
				[challengedesc setColor:ccc3(200,30,30)];
			}
			
			last_time = cur_time;
			
		} else if (cinfo.type == ChallengeType_BOSSRUSH) {
			BossRushAutoLevel *tar = NULL;
			for (GameObject *o in g.game_objects) {
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
		
	} else {
		[self update_scoredisp:g];
	}
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

-(void)set_enemy_alert_ui_ct:(int)i {
    [enemy_alert_ui set_ct:i];
}

-(void)set_item_duration_pct:(float)f item:(GameItem)item {
    item_duration_pct = f;
	
	TexRect *curitem = [GameItemCommon texrect_from:item];
	itemlenbaricon.texture = curitem.tex;
	itemlenbaricon.textureRect = curitem.rect;
	
	if (f == 0) {
		itemlenbar_target_pos = ITEM_LENBAR_HIDDEN_POSITION;
	}
}

-(void)update_item_slot {
    [ingame_ui_item_slot set_item:[UserInventory get_current_gameitem]];
}

-(void)animslot_notification {
	item_slot_notify_anim_sc = 2;
}

@end
