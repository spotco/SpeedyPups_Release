#import "InventoryTabPane_Extras.h"
#import "Common.h"
#import "Resource.h"
#import "FileCache.h"
#import "InventoryLayerTabScrollList.h"
#import "MenuCommon.h"
#import "AudioManager.h"
#import "ExtrasArtPopup.h"
#import "ExtrasManager.h"

typedef enum ExtrasPaneMode {
	ExtrasPaneMode_NONE,
	ExtrasPaneMode_ART,
	ExtrasPaneMode_MUSIC,
	ExtrasPaneMode_SFX
} ExtrasPaneMode;

@implementation InventoryTabPane_Extras {
	InventoryLayerTabScrollList *list;
	ExtrasPaneMode cur_mode;
	ExtrasPaneMode selected_mode;
	CCLabelTTF *name_disp;
	CCLabelTTF *desc_disp;
	
	TouchButton *categ_sel;
	TouchButton *categ_sel_back;
	
	TouchButton *action_button;
	CCLabelTTF *action_button_label;
	
	NSString *action_select_id;
	
	NSMutableArray *touches;
}

+(InventoryTabPane_Extras*)cons:(CCSprite *)parent {
	return [[InventoryTabPane_Extras node] cons:parent];
}
-(id)cons:(CCSprite*)parent {
	touches = [NSMutableArray array];
	action_select_id = NULL;
	cur_mode = ExtrasPaneMode_NONE;
	selected_mode = ExtrasPaneMode_NONE;
	
	name_disp = [[Common cons_label_pos:[Common pct_of_obj:parent pctx:0.4 pcty:0.88]
								 color:ccc3(205, 51, 51)
							  fontsize:24
								   str:@""] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
	[name_disp setAnchorPoint:ccp(0,1)];
	[self addChild:name_disp];
	
	NSString* maxstr = @"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\naaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\naaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
    CGSize actualSize = [maxstr sizeWithFont:[UIFont fontWithName:@"Carton Six" size:15]
                           constrainedToSize:CGSizeMake(1000, 1000)
							   lineBreakMode:(NSLineBreakMode)UILineBreakModeWordWrap];
	desc_disp = [[CCLabelTTF labelWithString:@""
								 dimensions:actualSize
								  alignment:UITextAlignmentLeft
								   fontName:@"Carton Six"
								   fontSize:13] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
	[desc_disp setPosition:[Common pct_of_obj:parent pctx:0.4 pcty:0.7]];
	[desc_disp setAnchorPoint:ccp(0,1)];
	[desc_disp setColor:ccc3(0, 0, 0)];
	[self addChild:desc_disp];
	
	list = [InventoryLayerTabScrollList cons_parent:parent add_to:self];
	[self update_list];
	
	
	categ_sel =	[AnimatedTouchButton cons_pt:CGPointZero
									  tex:[Resource get_tex:TEX_NMENU_LEVELSELOBJ]
								  texrect:[FileCache get_cgrect_from_plist:TEX_NMENU_LEVELSELOBJ idname:@"challengeselectnextarrow"]
									   cb:[Common cons_callback:self sel:@selector(enter_category_select)]];
	[self addChild:[MenuCommon cons_descaler_for:categ_sel pos:[Common pct_of_obj:parent pctx:0.9 pcty:0.15]]];
	[touches addObject:categ_sel];
	
	categ_sel_back =	[AnimatedTouchButton cons_pt:CGPointZero
											     tex:[Resource get_tex:TEX_NMENU_LEVELSELOBJ]
											 texrect:[FileCache get_cgrect_from_plist:TEX_NMENU_LEVELSELOBJ idname:@"challengeselectnextarrow"]
											      cb:[Common cons_callback:self sel:@selector(back_category_select)]];
	CCSprite *reversed_arrow = [CCSprite spriteWithTexture:[Resource get_tex:TEX_NMENU_LEVELSELOBJ]
													  rect:[FileCache get_cgrect_from_plist:TEX_NMENU_LEVELSELOBJ idname:@"challengeselectnextarrow"]];
	[reversed_arrow setPosition:[Common pct_of_obj:categ_sel_back pctx:0.5 pcty:0.5]];
	[reversed_arrow setScaleX:-1];
	[categ_sel_back addChild:reversed_arrow];
	[self addChild:[MenuCommon cons_descaler_for:categ_sel_back pos:[Common pct_of_obj:parent pctx:0.4 pcty:0.15]]];
	[touches addObject:categ_sel_back];
	
	action_button = [AnimatedTouchButton cons_pt:CGPointZero
											 tex:[Resource get_tex:TEX_NMENU_ITEMS]
										 texrect:[FileCache get_cgrect_from_plist:TEX_NMENU_ITEMS idname:@"nmenu_shoptab"]
											  cb:[Common cons_callback:self sel:@selector(action_button_press)]];
	action_button_label = [[Common cons_label_pos:[Common pct_of_obj:action_button pctx:0.5 pcty:0.5]
										   color:ccc3(0,0,0)
										fontsize:16
											 str:@""] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
	[action_button addChild:action_button_label];
	[self addChild:[MenuCommon cons_descaler_for:action_button pos:[Common pct_of_obj:parent pctx:0.85 pcty:0.15]]];
	[touches addObject:action_button];
	
	[self update_buttons];
	return self;
}


#define ICON_MUSIC @"extrasicon_music"
#define ICON_ART @"extrasicon_art"
#define ICON_SFX @"extrasicon_sfx"

-(void)add_tab:(NSString*)text tid:(NSString*)texid sln:(SEL)selname {
	[list add_tab:[Resource get_tex:TEX_NMENU_ITEMS]
			 rect:[FileCache get_cgrect_from_plist:TEX_NMENU_ITEMS idname:texid]
		main_text:text sub_text:@""
		 callback:[Common cons_callback:self sel:selname]];
}

#define ADD_TAB(text,texid,selname) [self add_tab:text tid:texid sln:@selector(selname)]
#define OWNEXTRA(key) [ExtrasManager own_extra_for_key:key]

-(void)update_list {
	[list clear_tabs];
	if (cur_mode == ExtrasPaneMode_NONE) {
		ADD_TAB(@"Art", ICON_ART, category_select_art);
		ADD_TAB(@"Music", ICON_MUSIC, category_select_music);
		ADD_TAB(@"Sfx", ICON_SFX, category_select_sfx);
		
		[name_disp set_label:@"Extras"];
		[desc_disp set_label:@"Unlock concept art, music and sfx from the game and view them here!"];
		
	} else if (cur_mode == ExtrasPaneMode_ART) {
		if (OWNEXTRA(EXTRAS_ART_GOOBER)) ADD_TAB(@"Goober", ICON_ART, select_art_goober);
		if (OWNEXTRA(EXTRAS_ART_WINDOWCLEANER)) ADD_TAB(@"Window", ICON_ART, select_art_window_cleaner);
		if (OWNEXTRA(EXTRAS_ART_PENGMAKU)) ADD_TAB(@"Pengmaku", ICON_ART, select_art_pengmaku);
		if (OWNEXTRA(EXTRAS_ART_MOEMOERUSH)) ADD_TAB(@"MoeMoe", ICON_ART, select_art_moemoerush);

		if (OWNEXTRA(EXTRAS_ART_OLDLOGO)) ADD_TAB(@"Old Logo", ICON_ART, select_art_oldlogo);
		if (OWNEXTRA(EXTRAS_ART_GANG)) ADD_TAB(@"The Gang", ICON_ART, select_art_gang);
		if (OWNEXTRA(EXTRAS_ART_WORLD4_EARLY)) ADD_TAB(@"World4", ICON_ART, select_art_world4_early);
		if (OWNEXTRA(EXTRAS_ART_OLDDOG )) ADD_TAB(@"Old Dog", ICON_ART, select_art_olddog);
		if (OWNEXTRA(EXTRAS_ART_LABASSETS)) ADD_TAB(@"LabStuff", ICON_ART, select_art_labassets);
		if (OWNEXTRA(EXTRAS_ART_LOGOHEAD)) ADD_TAB(@"LogoHead", ICON_ART, select_art_logohead);
		if (OWNEXTRA(EXTRAS_ART_LABENTRANCE)) ADD_TAB(@"LabEntr", ICON_ART, select_art_labentrance);
		if (OWNEXTRA(EXTRAS_ART_INTRO_FRAME1)) ADD_TAB(@"Intro1", ICON_ART, select_art_intro_frame1);
		if (OWNEXTRA(EXTRAS_ART_DOGS_FINAL)) ADD_TAB(@"DogsFin", ICON_ART, select_art_dogs_final);
		if (OWNEXTRA(EXTRAS_ART_LAB_FINAL)) ADD_TAB(@"LabFin", ICON_ART, select_art_lab_final);
		if (OWNEXTRA(EXTRAS_ART_WORLD3_EARLY)) ADD_TAB(@"World3", ICON_ART, select_art_world3_early);
		if (OWNEXTRA(EXTRAS_ART_SUN)) ADD_TAB(@"Sun", ICON_ART, select_art_sun);
		if (OWNEXTRA(EXTRAS_ART_WORLD5_EARLY)) ADD_TAB(@"World5", ICON_ART, select_art_world5_early);
		if (OWNEXTRA(EXTRAS_ART_GOSTRICH )) ADD_TAB(@"Gostrich", ICON_ART, select_art_gostrich);
		if (OWNEXTRA(EXTRAS_ART_MENU4)) ADD_TAB(@"Menu4", ICON_ART, select_art_menu4);
		if (OWNEXTRA(EXTRAS_ART_MENU3)) ADD_TAB(@"Menu3", ICON_ART, select_art_menu3);
		if (OWNEXTRA(EXTRAS_ART_MENU2)) ADD_TAB(@"Menu2", ICON_ART, select_art_menu2);
		if (OWNEXTRA(EXTRAS_ART_MENU1)) ADD_TAB(@"Menu1", ICON_ART, select_art_menu1);
		if (OWNEXTRA(EXTRAS_ART_TUTORIAL2)) ADD_TAB(@"Tut2", ICON_ART, select_art_tutorial2);
		if (OWNEXTRA(EXTRAS_ART_TUTORIAL1)) ADD_TAB(@"Tut1", ICON_ART, select_art_tutorial1);
		if (OWNEXTRA(EXTRAS_ART_WORLD2_EARLY)) ADD_TAB(@"World2", ICON_ART, select_art_world2_early);
		if (OWNEXTRA(EXTRAS_ART_WORLD1_EARLY)) ADD_TAB(@"World1", ICON_ART, select_art_world1_early);
		if (OWNEXTRA(EXTRAS_ART_DOG_FINAL)) ADD_TAB(@"OGFin", ICON_ART, select_art_dog_final);
		if (OWNEXTRA(EXTRAS_ART_ROBOTS)) ADD_TAB(@"Robots", ICON_ART, select_art_robots);
		if (OWNEXTRA(EXTRAS_ART_BOSS)) ADD_TAB(@"Boss", ICON_ART, select_art_boss);
		if (OWNEXTRA(EXTRAS_ART_ITEMS)) ADD_TAB(@"Items", ICON_ART, select_art_items);
		if (OWNEXTRA(EXTRAS_ART_LAB)) ADD_TAB(@"Lab", ICON_ART, select_art_lab);
		if (OWNEXTRA(EXTRAS_ART_BIRTHDAY)) ADD_TAB(@"Cake", ICON_ART, select_art_birthday);
		
		
	} else if (cur_mode == ExtrasPaneMode_MUSIC) {
		if (OWNEXTRA(BGMUSIC_MENU1)) ADD_TAB(@"Menu", ICON_MUSIC, select_music_menu);
		if (OWNEXTRA(BGMUSIC_INTRO)) ADD_TAB(@"Intro", ICON_MUSIC, select_music_intro);
		if (OWNEXTRA(BGMUSIC_GAMELOOP1)) ADD_TAB(@"World1-1", ICON_MUSIC, select_music_world11);
		if (OWNEXTRA(BGMUSIC_GAMELOOP1_NIGHT)) ADD_TAB(@"World1-2", ICON_MUSIC, select_music_world12);
		if (OWNEXTRA(BGMUSIC_LAB1)) ADD_TAB(@"Lab", ICON_MUSIC, select_music_lab);
		if (OWNEXTRA(BGMUSIC_BOSS1)) ADD_TAB(@"Boss", ICON_MUSIC, select_music_boss);
		if (OWNEXTRA(BGMUSIC_CAPEGAMELOOP)) ADD_TAB(@"Sky World", ICON_MUSIC, select_music_skyworld);
		if (OWNEXTRA(BGMUSIC_JINGLE)) ADD_TAB(@"Jingle", ICON_MUSIC, selecT_music_jingle);
		if (OWNEXTRA(BGMUSIC_GAMELOOP2)) ADD_TAB(@"World2-1", ICON_MUSIC, select_music_world21);
		if (OWNEXTRA(BGMUSIC_GAMELOOP2_NIGHT)) ADD_TAB(@"World2-2", ICON_MUSIC, select_music_world22);
		if (OWNEXTRA(BGMUSIC_GAMELOOP3)) ADD_TAB(@"World3-1", ICON_MUSIC, select_music_world31);
		if (OWNEXTRA(BGMUSIC_GAMELOOP3_NIGHT)) ADD_TAB(@"World3-2", ICON_MUSIC, select_music_world32);
		if (OWNEXTRA(BGMUSIC_INVINCIBLE)) ADD_TAB(@"Invincible", ICON_MUSIC, select_music_invincible);
		
	} else if (cur_mode == ExtrasPaneMode_SFX) {
		if (OWNEXTRA(SFX_FANFARE_WIN)) ADD_TAB(@"Happy", ICON_SFX, select_sfx_happy);
		if (OWNEXTRA(SFX_FANFARE_LOSE)) ADD_TAB(@"Sad", ICON_SFX, select_sfx_lose);
		if (OWNEXTRA(SFX_CHECKPOINT)) ADD_TAB(@"Checkpt", ICON_SFX, select_sfx_checkpt);
		if (OWNEXTRA(SFX_WHIMPER)) ADD_TAB(@"Whimper", ICON_SFX, select_sfx_whimper);
		if (OWNEXTRA(SFX_BARK_HIGH)) ADD_TAB(@"Bark1", ICON_SFX, select_sfx_bark1);
		if (OWNEXTRA(SFX_BARK_MID)) ADD_TAB(@"Bark2", ICON_SFX, select_sfx_bark2);
		if (OWNEXTRA(SFX_BARK_LOW)) ADD_TAB(@"Bark3", ICON_SFX, select_sfx_bark3);
		if (OWNEXTRA(SFX_BOSS_ENTER)) ADD_TAB(@"Boss", ICON_SFX, select_sfx_boss);
		if (OWNEXTRA(SFX_CAT_LAUGH)) ADD_TAB(@"CatLaugh", ICON_SFX, select_sfx_catlaugh);
		if (OWNEXTRA(SFX_CAT_HIT)) ADD_TAB(@"CatHit", ICON_SFX, select_sfx_cathit);
		if (OWNEXTRA(SFX_CHEER)) ADD_TAB(@"Cheer", ICON_SFX, select_sfx_cheer);
	}
	
	if ([list get_num_tabs] == 0) [desc_disp set_label:@"Unlock more extras from the store and wheel of prizes!"];
}

-(void)action_button_press {
	if (action_select_id != NULL) {
		if (cur_mode == ExtrasPaneMode_MUSIC) {
			[AudioManager playbgm_file:action_select_id];
			
		} else if (cur_mode == ExtrasPaneMode_SFX) {
			if (streq(action_select_id, SFX_FANFARE_WIN) || streq(action_select_id, SFX_FANFARE_LOSE)) {
				[AudioManager mute_music_for:10];
			} else {
				[AudioManager mute_music_for:4];
			}
			[AudioManager playsfx:action_select_id];
			
		} else if (cur_mode == ExtrasPaneMode_ART) {
			[MenuCommon popup:[ExtrasArtPopup cons_key:action_select_id]];
			
		}
	}
}

-(void)null_sel{}

-(void)select_art_goober{ [self select_art:EXTRAS_ART_GOOBER]; }
-(void)select_art_moemoerush{ [self select_art:EXTRAS_ART_MOEMOERUSH]; }
-(void)select_art_pengmaku{ [self select_art:EXTRAS_ART_PENGMAKU]; }
-(void)select_art_window_cleaner{ [self select_art:EXTRAS_ART_WINDOWCLEANER]; }

-(void)select_art_oldlogo { [self select_art:EXTRAS_ART_OLDLOGO]; }
-(void)select_art_gang {[self select_art:EXTRAS_ART_GANG];}
-(void)select_art_world4_early { [self select_art:EXTRAS_ART_WORLD4_EARLY]; }
-(void)select_art_olddog {[self select_art:EXTRAS_ART_OLDDOG];}
-(void)select_art_world1_progress {[self select_art:EXTRAS_ART_WORLD1_PROGRESS];}
-(void)select_art_labassets {[self select_art:EXTRAS_ART_LABASSETS];}
-(void)select_art_logohead {[self select_art:EXTRAS_ART_LOGOHEAD];}
-(void)select_art_labentrance {[self select_art:EXTRAS_ART_LABENTRANCE];}
-(void)select_art_intro_frame1 {[self select_art:EXTRAS_ART_INTRO_FRAME1];}
-(void)select_art_dogs_final {[self select_art:EXTRAS_ART_DOGS_FINAL];}
-(void)select_art_lab_final {[self select_art:EXTRAS_ART_LAB_FINAL];}
-(void)select_art_world3_early {[self select_art:EXTRAS_ART_WORLD3_EARLY];}
-(void)select_art_sun {[self select_art:EXTRAS_ART_SUN];}
-(void)select_art_world5_early {[self select_art:EXTRAS_ART_WORLD5_EARLY];}
-(void)select_art_gostrich {[self select_art:EXTRAS_ART_GOSTRICH];}
-(void)select_art_menu4 {[self select_art:EXTRAS_ART_MENU4];}
-(void)select_art_menu3 {[self select_art:EXTRAS_ART_MENU3];}
-(void)select_art_menu2 {[self select_art:EXTRAS_ART_MENU2];}
-(void)select_art_menu1 {[self select_art:EXTRAS_ART_MENU1];}
-(void)select_art_tutorial2 {[self select_art:EXTRAS_ART_TUTORIAL2];}
-(void)select_art_tutorial1 {[self select_art:EXTRAS_ART_TUTORIAL1];}
-(void)select_art_world2_early {[self select_art:EXTRAS_ART_WORLD2_EARLY];}
-(void)select_art_world1_early {[self select_art:EXTRAS_ART_WORLD1_EARLY];}
-(void)select_art_dog_final {[self select_art:EXTRAS_ART_DOG_FINAL];}
-(void)select_art_robots {[self select_art:EXTRAS_ART_ROBOTS];}
-(void)select_art_boss {[self select_art:EXTRAS_ART_BOSS];}
-(void)select_art_items {[self select_art:EXTRAS_ART_ITEMS];}
-(void)select_art_lab {[self select_art:EXTRAS_ART_LAB];}
-(void)select_art_birthday {[self select_art:EXTRAS_ART_BIRTHDAY];}



-(void)select_sfx_happy{ [self select_sfx:SFX_FANFARE_WIN]; }
-(void)select_sfx_lose{ [self select_sfx:SFX_FANFARE_LOSE]; }
-(void)select_sfx_checkpt{ [self select_sfx:SFX_CHECKPOINT]; }
-(void)select_sfx_whimper{ [self select_sfx:SFX_WHIMPER]; }
-(void)select_sfx_bark1{ [self select_sfx:SFX_BARK_LOW]; }
-(void)select_sfx_bark2{ [self select_sfx:SFX_BARK_MID]; }
-(void)select_sfx_bark3{ [self select_sfx:SFX_BARK_HIGH]; }
-(void)select_sfx_boss{ [self select_sfx:SFX_BOSS_ENTER]; }
-(void)select_sfx_catlaugh{ [self select_sfx:SFX_CAT_LAUGH]; }
-(void)select_sfx_cathit{ [self select_sfx:SFX_CAT_HIT]; }
-(void)select_sfx_cheer{ [self select_sfx:SFX_CHEER]; }

-(void)select_music_menu{ [self select_music:BGMUSIC_MENU1]; }
-(void)select_music_intro{ [self select_music:BGMUSIC_INTRO]; }
-(void)select_music_world11{ [self select_music:BGMUSIC_GAMELOOP1]; }
-(void)select_music_world12{ [self select_music:BGMUSIC_GAMELOOP1_NIGHT]; }
-(void)select_music_lab{ [self select_music:BGMUSIC_LAB1]; }
-(void)select_music_boss{ [self select_music:BGMUSIC_BOSS1]; }
-(void)select_music_skyworld{ [self select_music:BGMUSIC_CAPEGAMELOOP]; }
-(void)selecT_music_jingle{ [self select_music:BGMUSIC_JINGLE]; }
-(void)select_music_world21{ [self select_music:BGMUSIC_GAMELOOP2]; }
-(void)select_music_world22{ [self select_music:BGMUSIC_GAMELOOP2_NIGHT]; }
-(void)select_music_world31{ [self select_music:BGMUSIC_GAMELOOP3]; }
-(void)select_music_world32{ [self select_music:BGMUSIC_GAMELOOP3_NIGHT]; }
-(void)select_music_invincible{ [self select_music:BGMUSIC_INVINCIBLE]; }

-(void)select_art:(NSString*)art_id {
	action_select_id = art_id;
	[self update_buttons];
}

-(void)select_music:(NSString*)music_id {
	action_select_id =  music_id;
	[self update_buttons];
}

-(void)select_sfx:(NSString*)sfx_id {
	action_select_id = sfx_id;
	[self update_buttons];
}

-(void)update {
	if (!self.visible) return;
	[list update];
	for (id b in touches) if ([b respondsToSelector:@selector(update)]) [b update];
}

-(void)update_buttons {
	[categ_sel setVisible:cur_mode == ExtrasPaneMode_NONE && (selected_mode == ExtrasPaneMode_ART || selected_mode == ExtrasPaneMode_MUSIC || selected_mode == ExtrasPaneMode_SFX)];
	[categ_sel_back setVisible:(cur_mode == ExtrasPaneMode_ART || cur_mode == ExtrasPaneMode_MUSIC || cur_mode == ExtrasPaneMode_SFX)];
	[action_button setVisible:action_select_id != NULL];
	
	if ([action_button visible]) {
		if (cur_mode == ExtrasPaneMode_ART) {
			[action_button_label set_label:@"View!"];
		} else if (cur_mode == ExtrasPaneMode_MUSIC) {
			[action_button_label set_label:@"Play!"];
		} else if (cur_mode == ExtrasPaneMode_SFX) {
			[action_button_label set_label:@"Play!"];
		}
		if (action_select_id != NULL) {
			[name_disp setString:[ExtrasManager name_for_key:action_select_id]];
			[desc_disp setString:[ExtrasManager desc_for_key:action_select_id]];
		}
	}
}

-(void)back_category_select {
	[AudioManager playsfx:SFX_MENU_DOWN];
	if (cur_mode == ExtrasPaneMode_ART || cur_mode == ExtrasPaneMode_MUSIC || cur_mode == ExtrasPaneMode_SFX) {
		cur_mode = ExtrasPaneMode_NONE;
		selected_mode = ExtrasPaneMode_NONE;
		action_select_id = NULL;
		[self update_list];
	}
	[self update_buttons];
}

-(void)enter_category_select {
	[AudioManager playsfx:SFX_MENU_UP];
	if (selected_mode == ExtrasPaneMode_ART || selected_mode == ExtrasPaneMode_MUSIC || selected_mode == ExtrasPaneMode_SFX) {
		cur_mode = selected_mode;
		selected_mode = ExtrasPaneMode_NONE;
		action_select_id = NULL;
		[self update_list];
	}
	[self update_buttons];
}

-(void)category_select_art {
	selected_mode = ExtrasPaneMode_ART;
	[name_disp set_label:@"Art"];
	[desc_disp set_label:@"View concept art!"];
	[self update_buttons];
}

-(void)category_select_music {
	selected_mode = ExtrasPaneMode_MUSIC;
	[name_disp set_label:@"Music"];
	[desc_disp set_label:@"Listen to game music!"];
	[self update_buttons];
}

-(void)category_select_sfx {
	selected_mode = ExtrasPaneMode_SFX;
	[name_disp set_label:@"SFX"];
	[desc_disp set_label:@"Hear game sound effects!"];
	[self update_buttons];
}

-(void)touch_begin:(CGPoint)pt {
	if (!self.visible) return;
	[list touch_begin:pt];
	for (TouchButton *b in touches) [b touch_begin:pt];
}

-(void)touch_move:(CGPoint)pt {
	if (!self.visible) return;
	[list touch_move:pt];
	for (TouchButton *b in touches) [b touch_move:pt];
}

-(void)touch_end:(CGPoint)pt {
	if (!self.visible) return;
	[list touch_end:pt];
	for (TouchButton *b in touches) [b touch_end:pt];
}

-(void)set_pane_open:(BOOL)t {
	[self setVisible:t];
}

-(void)dealloc {
	[list clear_tabs];
}

@end
