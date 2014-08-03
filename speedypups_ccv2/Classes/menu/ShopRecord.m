#import "ShopRecord.h"
#import "Resource.h"
#import "FileCache.h"
#import "GameItemCommon.h"
#import "UserInventory.h"
#import "Player.h"
#import "FreeRunStartAtManager.h"
#import "ExtrasManager.h"
#import "MenuCommon.h" 
#import "ExtrasUnlockPopup.h"
#import "DailyLoginPopup.h"
#import "TrackingUtil.h"
#import "SpeedyPupsIAP.h"

@implementation ItemInfo
@synthesize tex;
@synthesize rect;
@synthesize price;
@synthesize name,desc;
+(ItemInfo*)cons_tex:(NSString*)texn
			  rectid:(NSString*)rectid
				name:(NSString*)name
				desc:(NSString*)desc
			   price:(int)price
				 val:(NSString*)val {
	
	ItemInfo *i = [[ItemInfo alloc] init];
	i.tex = [Resource get_tex:texn];
	i.rect = [FileCache get_cgrect_from_plist:texn idname:rectid];
	i.name = name;
	i.desc = desc;
	i.price = price;
	i.val = val;
	i.short_name = name;
	return i;
}

+(ItemInfo*)cons_tex:(CCTexture2D*)texn
				rect:(CGRect)rectid
				name:(NSString*)name
				desc:(NSString*)desc
			   price:(int)price
				 val:(NSString*)val {
	ItemInfo *i = [[ItemInfo alloc] init];
	i.tex = texn;
	i.rect = rectid;
	i.name = name;
	i.desc = desc;
	i.price = price;
	i.val = val;
	i.short_name = name;
	return i;
}
@end

@implementation IAPItemInfo
@synthesize iap_price;
@synthesize iap_identifier;

+(IAPItemInfo*)cons_tex:(NSString*)texn
				 rectid:(NSString*)rectid
				   name:(NSString*)name
				   desc:(NSString*)desc
				  price:(int)price
					val:(NSString*)val {
	
	IAPItemInfo *rtv = [[IAPItemInfo alloc] init];
	rtv.tex = [Resource get_tex:texn];
	rtv.rect = [FileCache get_cgrect_from_plist:texn idname:rectid];
	rtv.name = name;
	rtv.val = val;
	rtv.desc = desc;
	rtv.price = price;
	rtv.short_name = name;
	return rtv;
}

@end

@implementation ShopRecord

+(NSArray*)get_items_for_tab:(ShopTab)t {
	NSMutableArray *a = [NSMutableArray array];
	if (t == ShopTab_UPGRADE) [self fill_items_tab:a];
	if (t == ShopTab_CHARACTERS) [self fill_characters_tab:a];
	if (t == ShopTab_UNLOCK) [self fill_unlock_tab:a];
	if (t == ShopTab_REALMONEY) [self fill_realmoney_tab:a];
	return a;
}

+(void)fill_items_tab:(NSMutableArray*)a {
	[self add_item:Item_Rocket into:a];
	[self add_item:Item_Shield into:a];
	[self add_item:Item_Magnet into:a];
	[self add_item:Item_Clock into:a];
	
	[self add_upgrade:Item_Rocket into:a];
	[self add_upgrade:Item_Shield into:a];
	[self add_upgrade:Item_Magnet into:a];
	[self add_upgrade:Item_Clock into:a];
}

+(void)add_upgrade:(GameItem)item into:(NSMutableArray*)a {
	if (![UserInventory can_upgrade:item]) return;
	NSString* shop_val = item == Item_Clock ? SHOP_UPGRADE_CLOCK :
	(item == Item_Magnet ? SHOP_UPGRADE_MAGNET :
	 (item == Item_Rocket ? SHOP_UPGRADE_ROCKET :
	  (item == Item_Shield ? SHOP_UPGRADE_ARMOR : @"top lel")));
	int price = 1;
	int ugv = [UserInventory get_upgrade_level:item];
	if (item == Item_Clock) {
		int vals[] = {5,10,20};
		price = vals[ugv];
	} else if (item == Item_Magnet) {
		int vals[] = {5,10,20};
		price = vals[ugv];
	} else if (item == Item_Rocket) {
		int vals[] = {5,10,20};
		price = vals[ugv];
	} else if (item == Item_Shield) {
		int vals[] = {5,10,20};
		price = vals[ugv];
	}
	NSString *item_name = [NSString stringWithFormat:@"Upgrade %@",[GameItemCommon name_from:item]];
	NSString *use_desc = @"Upgrade to work better.";
	
	ItemInfo *i = [ItemInfo cons_tex:TEX_ITEM_SS
							  rectid:[ShopRecord gameitem_to_texid:item upgrade:YES]
								name:item_name
								desc:[NSString stringWithFormat:@"%@\nUse: %@",use_desc,[GameItemCommon description_from:item]]
							   price:price
								 val:shop_val];
	i.short_name = @"Upgrade";
	[a addObject:i];
}

+(void)add_item:(GameItem)item into:(NSMutableArray*)a {
	if ([UserInventory get_item_owned:item]) return;
	
	NSString* shop_val = item == Item_Clock ? SHOP_ITEM_CLOCK :
	(item == Item_Magnet ? SHOP_ITEM_MAGNET :
	 (item == Item_Rocket ? SHOP_ITEM_ROCKET :
	  (item == Item_Shield ? SHOP_ITEM_ARMOR : @"top lel")));
	int price = item == Item_Clock ? 10 :
	(item == Item_Magnet ? 10 :
	 (item == Item_Rocket ? 10 :
	  (item == Item_Shield ? 10 : 1)));
	
	NSString *item_name = [GameItemCommon name_from:item];
	NSString *use_desc = @"Unlock to equip in inventory.";
	
	ItemInfo *i = [ItemInfo cons_tex:TEX_ITEM_SS
							  rectid:[ShopRecord gameitem_to_texid:item upgrade:NO]
								name:item_name
								desc:[NSString stringWithFormat:@"%@\nUse: %@",use_desc,[GameItemCommon description_from:item]]
							   price:price
								 val:shop_val];
	i.short_name = item_name;
	[a addObject:i];
}

+(void)fill_characters_tab:(NSMutableArray*)a {
	NSString *dogs[] = {	TEX_DOG_RUN_2,	TEX_DOG_RUN_3,	TEX_DOG_RUN_4,	TEX_DOG_RUN_5,	TEX_DOG_RUN_6,	TEX_DOG_RUN_7};
	NSString *actions[] = {	SHOP_DOG_DOG2,	SHOP_DOG_DOG3,	SHOP_DOG_DOG4,	SHOP_DOG_DOG5,	SHOP_DOG_DOG6,	SHOP_DOG_DOG7};
	float prices[] = {		10,				15,				25,				35,				45,				60};
	for(int i = 0; i < sizeof(dogs)/sizeof(NSString*); i++) {
		NSString *dog = dogs[i];
		if (![UserInventory get_character_unlocked:dog]) {
			[a addObject:[ItemInfo cons_tex:TEX_ITEM_SS
									 rectid:[NSString stringWithFormat:@"dog_%d",i+2]
									   name:[Player get_name:dog]
									   desc:[NSString stringWithFormat:@"Unlock %@.\nAbility: %@",
												[Player get_full_name:dog],
												[Player get_power_desc:dog]]
									  price:prices[i]
										val:actions[i]]];
		}
	}
}

+(void)fill_unlock_tab:(NSMutableArray*)a {
	if (![FreeRunStartAtManager get_can_start_at:FreeRunStartAt_WORLD2]) {
		TexRect *freerunstarticon = [FreeRunStartAtManager get_icon_for_loc:FreeRunStartAt_WORLD2];
		[a addObject:[ItemInfo cons_tex:freerunstarticon.tex
								   rect:freerunstarticon.rect
								   name:@"World 2"
								   desc:@"Unlock world 2."
								  price:15
									val:SHOP_UNLOCK_WORLD2]];
	}
	if ([FreeRunStartAtManager get_can_start_at:FreeRunStartAt_WORLD2] && ![FreeRunStartAtManager get_can_start_at:FreeRunStartAt_WORLD3]) {
		TexRect *freerunstarticon = [FreeRunStartAtManager get_icon_for_loc:FreeRunStartAt_WORLD3];
		[a addObject:[ItemInfo cons_tex:freerunstarticon.tex
								   rect:freerunstarticon.rect
								   name:@"World 3"
								   desc:@"Unlock world 3."
								  price:25
									val:SHOP_UNLOCK_WORLD3]];
	}
	NSString *random_extra = [ExtrasManager random_unowned_extra];
	if (random_extra != NULL) {
		[a addObject:[ItemInfo cons_tex:[Resource get_tex:TEX_NMENU_ITEMS]
								   rect:[FileCache get_cgrect_from_plist:TEX_NMENU_ITEMS idname:@"extrasicon_art"]
								   name:@"Extra"
								   desc:@"Unlock a random extra."
								  price:2
									val:random_extra]];
	}
}

+(void)fill_realmoney_tab:(NSMutableArray*)a {
	for (IAPObject *o in [SpeedyPupsIAP get_all_loaded_iaps]) {
		NSString *rectid = @"coin";
		if (streq(o.identifier, SPEEDYPUPS_AD_FREE)) {
			rectid = @"money_icon";
		}
		
		if ([UserInventory get_ads_disabled]) {
			if (streq(o.identifier, SPEEDYPUPS_AD_FREE)) continue;
		} else {
			if (!streq(o.identifier, SPEEDYPUPS_AD_FREE)) continue;
		}
		
		IAPItemInfo *i = [IAPItemInfo cons_tex:TEX_NMENU_ITEMS
										rectid:rectid
										  name:o.name
										  desc:o.desc
										 price:0
										   val:o.identifier];
		
		i.iap_price = o.price;
		i.iap_identifier = o.identifier;
		
		if ([o.name rangeOfString:@" "].length > 0) {
			i.short_name = [o.name componentsSeparatedByString:@" "][1];
		}
		[a insertObject:i atIndex:0];
	}
}

+(NSString*)gameitem_to_texid:(GameItem)i upgrade:(BOOL)upgrade {
	if (!upgrade) {
		if (i == Item_Heart) return @"item_heart";
		else if (i == Item_Magnet) return @"item_magnet";
		else if (i == Item_Rocket) return @"item_rocket";
		else if (i == Item_Shield) return @"item_shield";
		else if (i == Item_Clock) return @"item_clock";
		else return @"";

	} else {
		if (i == Item_Heart) return @"upgrade_heart";
		else if (i == Item_Magnet) return @"upgrade_magnet";
		else if (i == Item_Rocket) return @"upgrade_rocket";
		else if (i == Item_Shield) return @"upgrade_shield";
		else if (i == Item_Clock) return @"upgrade_clock";
		else return @"";

	}
}

+(BOOL)buy_shop_item:(NSString *)val price:(int)price {
	if (price > [UserInventory get_current_coins]) return NO;
	[TrackingUtil track_evt:TrackingEvt_ShopBuy val1:val];
	
	if ([[SpeedyPupsIAP get_all_requested_iaps] containsObject:val]) {
		[[IAPHelper sharedInstance] buyProduct:[SpeedyPupsIAP product_for_key:val]];
		
	} else if (streq(val, SHOP_ITEM_MAGNET)) {
		if ([UserInventory get_item_owned:Item_Magnet]) return NO;
		[UserInventory set_item:Item_Magnet owned:YES];
		[UserInventory set_current_gameitem:Item_Magnet];
		[UserInventory set_equipped_gameitem:Item_Magnet];
		
	} else if (streq(val, SHOP_ITEM_ARMOR)) {
		if ([UserInventory get_item_owned:Item_Shield]) return NO;
		[UserInventory set_item:Item_Shield owned:YES];
		[UserInventory set_current_gameitem:Item_Shield];
		[UserInventory set_equipped_gameitem:Item_Shield];
		
	} else if (streq(val, SHOP_ITEM_ROCKET)) {
		if ([UserInventory get_item_owned:Item_Rocket]) return NO;
		[UserInventory set_item:Item_Rocket owned:YES];
		[UserInventory set_current_gameitem:Item_Rocket];
		[UserInventory set_equipped_gameitem:Item_Rocket];
		
	} else if (streq(val, SHOP_ITEM_CLOCK)) {
		if ([UserInventory get_item_owned:Item_Clock]) return NO;
		[UserInventory set_item:Item_Clock owned:YES];
		[UserInventory set_current_gameitem:Item_Clock];
		[UserInventory set_equipped_gameitem:Item_Clock];
		
	} else if (streq(val, SHOP_UPGRADE_MAGNET)) {
		if (![UserInventory can_upgrade:Item_Magnet]) return NO;
		[UserInventory upgrade:Item_Magnet];
		[UserInventory set_current_gameitem:Item_Magnet];
		[UserInventory set_equipped_gameitem:Item_Magnet];
		
	} else if (streq(val, SHOP_UPGRADE_ARMOR)) {
		if (![UserInventory can_upgrade:Item_Shield]) return NO;
		[UserInventory upgrade:Item_Shield];
		[UserInventory set_current_gameitem:Item_Shield];
		[UserInventory set_equipped_gameitem:Item_Shield];
		
	} else if (streq(val, SHOP_UPGRADE_ROCKET)) {
		if (![UserInventory can_upgrade:Item_Rocket]) return NO;
		[UserInventory upgrade:Item_Rocket];
		[UserInventory set_current_gameitem:Item_Rocket];
		[UserInventory set_equipped_gameitem:Item_Rocket];
		
	} else if (streq(val, SHOP_UPGRADE_CLOCK)) {
		if (![UserInventory can_upgrade:Item_Clock]) return NO;
		[UserInventory upgrade:Item_Clock];
		[UserInventory set_current_gameitem:Item_Clock];
		[UserInventory set_equipped_gameitem:Item_Clock];
		
	} else if (streq(val, SHOP_DOG_DOG2)) {
		if ([UserInventory get_character_unlocked:TEX_DOG_RUN_2]) return NO;
		[UserInventory unlock_character:TEX_DOG_RUN_2];
		[MenuCommon popup:[DailyLoginPopup character_unlock_popup:TEX_DOG_RUN_2]];
		
	} else if (streq(val, SHOP_DOG_DOG3)) {
		if ([UserInventory get_character_unlocked:TEX_DOG_RUN_3]) return NO;
		[UserInventory unlock_character:TEX_DOG_RUN_3];
		[MenuCommon popup:[DailyLoginPopup character_unlock_popup:TEX_DOG_RUN_3]];
		
	} else if (streq(val, SHOP_DOG_DOG4)) {
		if ([UserInventory get_character_unlocked:TEX_DOG_RUN_4]) return NO;
		[UserInventory unlock_character:TEX_DOG_RUN_4];
		[MenuCommon popup:[DailyLoginPopup character_unlock_popup:TEX_DOG_RUN_4]];
		
	} else if (streq(val, SHOP_DOG_DOG5)) {
		if ([UserInventory get_character_unlocked:TEX_DOG_RUN_5]) return NO;
		[UserInventory unlock_character:TEX_DOG_RUN_5];
		[MenuCommon popup:[DailyLoginPopup character_unlock_popup:TEX_DOG_RUN_5]];
		
	} else if (streq(val, SHOP_DOG_DOG6)) {
		if ([UserInventory get_character_unlocked:TEX_DOG_RUN_6]) return NO;
		[UserInventory unlock_character:TEX_DOG_RUN_6];
		[MenuCommon popup:[DailyLoginPopup character_unlock_popup:TEX_DOG_RUN_6]];
		
	} else if (streq(val, SHOP_DOG_DOG7)) {
		if ([UserInventory get_character_unlocked:TEX_DOG_RUN_7]) return NO;
		[UserInventory unlock_character:TEX_DOG_RUN_7];
		[MenuCommon popup:[DailyLoginPopup character_unlock_popup:TEX_DOG_RUN_7]];
		
	} else if (streq(val, SHOP_UNLOCK_WORLD2)) {
		[FreeRunStartAtManager set_can_start_at:FreeRunStartAt_WORLD1];
		[FreeRunStartAtManager set_can_start_at:FreeRunStartAt_WORLD2];
		[FreeRunStartAtManager set_can_start_at:FreeRunStartAt_LAB1];
		[FreeRunStartAtManager set_can_start_at:FreeRunStartAt_LAB2];
		
	} else if (streq(val, SHOP_UNLOCK_WORLD3)) {
		[FreeRunStartAtManager set_can_start_at:FreeRunStartAt_WORLD1];
		[FreeRunStartAtManager set_can_start_at:FreeRunStartAt_WORLD2];
		[FreeRunStartAtManager set_can_start_at:FreeRunStartAt_WORLD3];
		[FreeRunStartAtManager set_can_start_at:FreeRunStartAt_LAB1];
		[FreeRunStartAtManager set_can_start_at:FreeRunStartAt_LAB2];
		[FreeRunStartAtManager set_can_start_at:FreeRunStartAt_LAB3];
		
	} else if ([[ExtrasManager all_extras] containsObject:val]) {
		[ExtrasManager set_own_extra_for_key:val];
		[MenuCommon popup:[ExtrasUnlockPopup cons_unlocking:val]];
		
	} else {
		NSLog(@"error unknown shop value %@",val);
		return NO;
	}
	
	[UserInventory add_coins:-price];
	return YES;
}

@end
