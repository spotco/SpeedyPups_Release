#import "InventoryTabPane_Upgrades.h"
#import "Common.h"
#import "Resource.h"
#import "FileCache.h"
#import "InventoryLayerTabScrollList.h"
#import "GameItemCommon.h"
#import "UserInventory.h"
#import "MenuCommon.h"
#import "AudioManager.h"

@implementation InventoryTabPane_Upgrades {
	NSMutableArray *touches;
}

+(InventoryTabPane_Upgrades*)cons:(CCSprite *)parent {
	return [[InventoryTabPane_Upgrades node] cons:parent];
}
-(id)cons:(CCSprite*)parent {
	list = [InventoryLayerTabScrollList cons_parent:parent add_to:self];
	
	name_disp = [[Common cons_label_pos:[Common pct_of_obj:parent pctx:0.4 pcty:0.88]
								 color:ccc3(205, 51, 51)
							  fontsize:24
								   str:@"Upgrades"] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
	[name_disp setAnchorPoint:ccp(0,1)];
	[self addChild:name_disp];
	
	NSString* maxstr = @"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\naaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\naaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
    CGSize actualSize = [maxstr sizeWithFont:[UIFont fontWithName:@"Carton Six" size:15]
                           constrainedToSize:CGSizeMake(1000, 1000)
							   lineBreakMode:(NSLineBreakMode)UILineBreakModeWordWrap];
	desc_disp = [[CCLabelTTF labelWithString:@"Keep track of your upgrades to powerups here!"
								 dimensions:actualSize
								  alignment:UITextAlignmentLeft
								   fontName:@"Carton Six"
								   fontSize:13] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
	
	[desc_disp setPosition:[Common pct_of_obj:parent pctx:0.4 pcty:0.7]];
	[desc_disp setAnchorPoint:ccp(0,1)];
	[desc_disp setColor:ccc3(0, 0, 0)];
	[self addChild:desc_disp];
	
	touches = [NSMutableArray array];
	TouchButton *upgrade_disp_button = [AnimatedTouchButton cons_pt:CGPointZero
																tex:[Resource get_tex:TEX_UI_INGAMEUI_SS]
															texrect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"menu_upgrade_bg"]
																 cb:[Common cons_callback:self sel:@selector(goto_store)]];
	[touches addObject:upgrade_disp_button];
	[self addChild:[MenuCommon cons_descaler_for:upgrade_disp_button pos:[Common pct_of_obj:parent pctx:0.65 pcty:0.35]]];
	upgrade_disp_bg = upgrade_disp_button;
	 
	upgrade_stars = [NSMutableArray array];
	for (int i = 0; i < 3; i++) {
		CCSprite *star = [CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
												rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"menu_upgrade_locked"]];
		[star setPosition:[Common pct_of_obj:upgrade_disp_bg pctx:0.3  + 0.2 * i pcty:0.375]];
		[upgrade_stars addObject:star];
		[upgrade_disp_bg addChild:star];
	}
	[upgrade_disp_bg setVisible:NO];
	
	selected_item = Item_NOITEM;
	
	[list add_tab:[GameItemCommon texrect_from:Item_Magnet].tex
			 rect:[GameItemCommon texrect_from:Item_Magnet].rect
		main_text:[GameItemCommon name_from:Item_Magnet]
		 sub_text:@""
		 callback:[Common cons_callback:self sel:@selector(select_magnet)]];
	
	[list add_tab:[GameItemCommon texrect_from:Item_Rocket].tex
			 rect:[GameItemCommon texrect_from:Item_Rocket].rect
		main_text:[GameItemCommon name_from:Item_Rocket]
		 sub_text:@""
		 callback:[Common cons_callback:self sel:@selector(select_rocket)]];
	
	[list add_tab:[GameItemCommon texrect_from:Item_Clock].tex
			 rect:[GameItemCommon texrect_from:Item_Clock].rect
		main_text:[GameItemCommon name_from:Item_Clock]
		 sub_text:@""
		 callback:[Common cons_callback:self sel:@selector(select_clock)]];
	
	[list add_tab:[GameItemCommon texrect_from:Item_Shield].tex
			 rect:[GameItemCommon texrect_from:Item_Shield].rect
		main_text:[GameItemCommon name_from:Item_Shield]
		 sub_text:@""
		 callback:[Common cons_callback:self sel:@selector(select_shield)]];
	
	return self;
}

-(void)goto_store {
	[MenuCommon goto_shop];
}

-(void)select_magnet {
	selected_item = Item_Magnet;
	[self update_labels_and_buttons];
}

-(void)select_rocket {
	selected_item = Item_Rocket;
	[self update_labels_and_buttons];
}

-(void)select_clock {
	selected_item = Item_Clock;
	[self update_labels_and_buttons];
}

-(void)select_shield {
	selected_item = Item_Shield;
	[self update_labels_and_buttons];
}

-(void)update_labels_and_buttons {
	if (selected_item != Item_NOITEM) {
		[name_disp setString:[GameItemCommon name_from:selected_item]];
		[desc_disp setString:@"Upgrade to work better!"];
		[upgrade_disp_bg setVisible:YES];
		int level = [UserInventory get_upgrade_level:selected_item];
		for (int i = 0; i < upgrade_stars.count; i++) {
			CCSprite *star = upgrade_stars[i];
			if (level > i) {
				[star setTextureRect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"menu_upgrade_unlocked"]];
			} else {
				[star setTextureRect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"menu_upgrade_locked"]];
			}
		}
	
	} else {
		[upgrade_disp_bg setVisible:NO];
	}
}

-(void)update {
	if (!self.visible) return;
	[list update];
	for (id b in touches) if ([b respondsToSelector:@selector(update)]) [b update];
}

-(void)touch_begin:(CGPoint)pt {
	if (!self.visible) return;
	[list touch_begin:pt];
	for (TouchButton *b in touches) if (b.visible) [b touch_begin:pt];
}

-(void)touch_move:(CGPoint)pt {
	if (!self.visible) return;
	[list touch_move:pt];
}

-(void)touch_end:(CGPoint)pt {
	if (!self.visible) return;
	[list touch_end:pt];
	for (TouchButton *b in touches) if (b.visible) [b touch_end:pt];
}

-(void)set_pane_open:(BOOL)t {
	[self setVisible:t];
}

-(void)dealloc {
	[list clear_tabs];
}

@end
