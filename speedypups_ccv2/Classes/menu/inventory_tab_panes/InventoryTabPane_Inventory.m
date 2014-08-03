#import "InventoryTabPane_Inventory.h"
#import "Common.h" 
#import "Resource.h"
#import "FileCache.h"
#import "ShopListTouchButton.h"
#import "ShopRecord.h"
#import "InventoryLayerTabScrollList.h"
#import "MenuCommon.h"
#import "UserInventory.h"
#import "AudioManager.h"

@implementation InventoryTabPane_Inventory

+(InventoryTabPane_Inventory*)cons:(CCSprite *)parent {
	return [[InventoryTabPane_Inventory node] cons:parent];
}

-(id)cons:(CCSprite*)parent {
	
	list = [InventoryLayerTabScrollList cons_parent:parent add_to:self];
	touches = [NSMutableArray array];
	
	added_items = [NSMutableDictionary dictionary];
	[self update_available_items];
	
	name_disp = [[Common cons_label_pos:[Common pct_of_obj:parent pctx:0.4 pcty:0.88]
								 color:ccc3(205, 51, 51)
							  fontsize:24
								   str:@"Inventory"] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
	[name_disp setAnchorPoint:ccp(0,1)];
	[self addChild:name_disp];
	
	NSString* maxstr = @"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\naaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\naaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\naaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
    CGSize actualSize = [maxstr sizeWithFont:[UIFont fontWithName:@"Carton Six" size:15]
                           constrainedToSize:CGSizeMake(1000, 1000)
							   lineBreakMode:(NSLineBreakMode)UILineBreakModeWordWrap];
	desc_disp = [[CCLabelTTF labelWithString:@"You'll find items you collect here.\nCheck out the store to buy stuff!"
								 dimensions:actualSize
								  alignment:UITextAlignmentLeft
								   fontName:@"Carton Six"
								   fontSize:13] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
	
	[desc_disp setPosition:[Common pct_of_obj:parent pctx:0.4 pcty:0.7]];
	[desc_disp setAnchorPoint:ccp(0,1)];
	[desc_disp setColor:ccc3(0, 0, 0)];
	[self addChild:desc_disp];
	
	
	equip_button = [AnimatedTouchButton cons_pt:CGPointZero
													  tex:[Resource get_tex:TEX_NMENU_ITEMS]
												  texrect:[FileCache get_cgrect_from_plist:TEX_NMENU_ITEMS idname:@"nmenu_shoptab"]
													   cb:[Common cons_callback:self sel:@selector(equip_button_press)]];
	
	[equip_button addChild:[[Common cons_label_pos:[Common pct_of_obj:equip_button pctx:0.5 pcty:0.5]
										 color:ccc3(0,0,0)
									  fontsize:18
										   str:@"Equip"] set_scale:1/CC_CONTENT_SCALE_FACTOR()]];
	[self addChild:[MenuCommon cons_descaler_for:equip_button pos:[Common pct_of_obj:parent pctx:0.875 pcty:0.125]]];
	[touches addObject:equip_button];
	[equip_button setVisible:NO];
	
	equipped_label = [[Common cons_label_pos:[Common pct_of_obj:parent pctx:0.875 pcty:0.125]
									  color:ccc3(205, 51, 51)
								   fontsize:18
										str:@"Equipped"] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
	[self addChild:equipped_label];
	[equipped_label setVisible:NO];
	
	selected_item = Item_NOITEM;
	
	[self cons_wheel_button:parent];
	
	return self;
}

#define added_items_contains(x) ([added_items objectForKey:x] != NULL)
#define added_items_add(x) [added_items setObject:@1 forKey:x]
-(void)update_available_items {
	
	NSString *bones = @"Bones";
	if (!added_items_contains(bones)) {
		bones_button = [list add_tab:[Resource get_tex:TEX_ITEM_SS]
				 rect:[FileCache get_cgrect_from_plist:TEX_ITEM_SS idname:@"goldenbone"]
			main_text:bones
			 sub_text:@""
			 callback:[Common cons_callback:self sel:@selector(select_bones)]];
		
		added_items_add(bones);
	}
	
	NSString *coins = @"Coins";
	if (!added_items_contains(coins)) {
		coins_button = [list add_tab:[Resource get_tex:TEX_ITEM_SS]
				 rect:[FileCache get_cgrect_from_plist:TEX_ITEM_SS idname:@"star_coin"]
			main_text:coins
			 sub_text:@""
			 callback:[Common cons_callback:self sel:@selector(select_coins)]];
		added_items_add(coins);
	}
	
	//TODO -- the conditions should be changed
	if (!added_items_contains([GameItemCommon name_from:Item_Magnet]) && [UserInventory get_item_owned:Item_Magnet]) {
		[list add_tab:[GameItemCommon texrect_from:Item_Magnet].tex
				 rect:[GameItemCommon texrect_from:Item_Magnet].rect
			main_text:[GameItemCommon name_from:Item_Magnet]
			 sub_text:@""
			 callback:[Common cons_callback:self sel:@selector(select_magnet)]];
		
		added_items_add([GameItemCommon name_from:Item_Magnet]);
	}
	
	if (!added_items_contains([GameItemCommon name_from:Item_Rocket]) && [UserInventory get_item_owned:Item_Rocket]) {
		[list add_tab:[GameItemCommon texrect_from:Item_Rocket].tex
				 rect:[GameItemCommon texrect_from:Item_Rocket].rect
			main_text:[GameItemCommon name_from:Item_Rocket]
			 sub_text:@""
			 callback:[Common cons_callback:self sel:@selector(select_rocket)]];
		
		added_items_add([GameItemCommon name_from:Item_Rocket]);
	}
	
	if (!added_items_contains([GameItemCommon name_from:Item_Clock]) && [UserInventory get_item_owned:Item_Clock]) {
		[list add_tab:[GameItemCommon texrect_from:Item_Clock].tex
				 rect:[GameItemCommon texrect_from:Item_Clock].rect
			main_text:[GameItemCommon name_from:Item_Clock]
			 sub_text:@""
			 callback:[Common cons_callback:self sel:@selector(select_clock)]];
		
		added_items_add([GameItemCommon name_from:Item_Clock]);
	}
	
	if (!added_items_contains([GameItemCommon name_from:Item_Shield]) && [UserInventory get_item_owned:Item_Shield]) {
		[list add_tab:[GameItemCommon texrect_from:Item_Shield].tex
				 rect:[GameItemCommon texrect_from:Item_Shield].rect
			main_text:[GameItemCommon name_from:Item_Shield]
			 sub_text:@""
			 callback:[Common cons_callback:self sel:@selector(select_shield)]];
		
		added_items_add([GameItemCommon name_from:Item_Shield]);
	}
	
	[self update_labels_and_buttons];
}

-(void)equip_button_press {
	if (selected_item != Item_NOITEM) {
		[UserInventory set_equipped_gameitem:selected_item];
		[AudioManager playsfx:SFX_MENU_UP];
	}
	[self update_labels_and_buttons];
}

-(void)select_bones {
	selected_item = Item_NOITEM;
	[self update_labels_and_buttons];
	[name_disp setString:@"Bones"];
	[desc_disp setString:@"You'll find these in game everywhere. Spend 'em on the Wheel of Prizes for a chance at something great!"];
	[wheel_ad_button setVisible:YES];
}

-(void)select_coins {
	selected_item = Item_NOITEM;
	[self update_labels_and_buttons];
	[name_disp setString:@"Coins"];
	[desc_disp setString:@"Use these to continue after a game over, or to buy goodies from the store. Find 'em in game or win 'em from the Wheel of Prizes!"];
	[wheel_ad_button setVisible:YES];
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
		[wheel_ad_button setVisible:NO];
		if (selected_item == [UserInventory get_equipped_gameitem]) {
			[equip_button setVisible:NO];
			[equipped_label setVisible:YES];
		} else {
			[equip_button setVisible:YES];
			[equipped_label setVisible:NO];
		}
		[name_disp setString:[GameItemCommon name_from:selected_item]];
		[desc_disp setString:[NSString stringWithFormat:@"Equip to use at start. Power: %@",[GameItemCommon description_from:selected_item]]];
		
	} else {
		[equip_button setVisible:NO];
		[equipped_label setVisible:NO];
	}
	
	[bones_button set_sub_text:[NSString stringWithFormat:@"%d",[UserInventory get_current_bones]]];
	[coins_button set_sub_text:[NSString stringWithFormat:@"%d",[UserInventory get_current_coins]]];
	
}

-(void)setVisible:(BOOL)visible {
	if (visible) [self update_labels_and_buttons];
	[super setVisible:visible];
}

-(void)update {
	if (!self.visible) return;
	[list update];
	for (id obj in touches) {
		if ([obj respondsToSelector:@selector(update)]) {
			[obj update];
		}
	}
}

-(void)touch_begin:(CGPoint)pt {
	if (!self.visible) return;
	[list touch_begin:pt];
	for (TouchButton *b in touches) [b touch_begin:pt];
}

-(void)touch_move:(CGPoint)pt {
	if (!self.visible) return;
	[list touch_move:pt];
}

-(void)touch_end:(CGPoint)pt {
	if (!self.visible) return;
	[list touch_end:pt];
	for (TouchButton *b in touches) [b touch_end:pt];
}

-(void)set_pane_open:(BOOL)t {
	[self setVisible:t];
}

-(void)cons_wheel_button:(CCSprite*)parent {
	CCSprite *normal = [CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
											  rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS
																			 idname:@"spinbutton_0"]];
	[normal addChild:[[MenuCommon wheel_of_prizes_button_sprite] anchor_pt:ccp(0,0)]];
	CCSprite *selected = [CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
												rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS
																			   idname:@"spinbutton_0"]];
	[selected addChild:[[MenuCommon wheel_of_prizes_button_sprite] anchor_pt:ccp(0,0)]];
	[Common set_zoom_pos_align:normal zoomed:selected scale:1.2];
	
	wheel_ad_button = [CCMenuItemSprite itemFromNormalSprite:normal
											  selectedSprite:selected
													  target:self selector:@selector(open_wheel)];
	[wheel_ad_button setScale:0.6];
	[wheel_ad_button setAnchorPoint:ccp(0.5,0.5)];
	[wheel_ad_button setPosition:[Common pct_of_obj:parent pctx:0.825 pcty:0.2]];
	CCMenu *menu = [CCMenu menuWithItems:wheel_ad_button, nil];
	[menu setPosition:CGPointZero];
	[self addChild:menu];
	[wheel_ad_button setVisible:NO];
}

-(void)open_wheel {
	[GEventDispatcher push_event:[[GEvent cons_type:GEventType_MENU_INVENTORY] add_i1:InventoryLayerTab_Index_Prizes i2:0]];
}

-(void)dealloc {
	coins_button = NULL;
	bones_button = NULL;
	[list clear_tabs];
}

@end
