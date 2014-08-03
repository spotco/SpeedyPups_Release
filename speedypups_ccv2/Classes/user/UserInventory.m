#import "UserInventory.h"
#import "DataStore.h"
#import "Resource.h"

@implementation UserInventory

#define STO_CURRENT_BONES @"current_bones"
#define STO_CURRENT_COINS @"current_coins"
#define STO_MAIN_SLOT @"main_slot"
#define STO_EQUIPPED @"equipped_item"

+(void)initialize {
	valid_characters = @[TEX_DOG_RUN_1,TEX_DOG_RUN_2,TEX_DOG_RUN_3,TEX_DOG_RUN_4,TEX_DOG_RUN_5,TEX_DOG_RUN_6,TEX_DOG_RUN_7];
}

+(NSString*)gameitem_to_string:(GameItem)t {
    return [NSString stringWithFormat:@"inventory_%d",t];
}

+(int)get_current_bones {
    return [DataStore get_int_for_key:STO_CURRENT_BONES];
}

+(void)add_bones:(int)ct {
    [DataStore set_key:STO_CURRENT_BONES int_value:[self get_current_bones]+ct];
}

+(int)get_current_coins {
	return [DataStore get_int_for_key:STO_CURRENT_COINS];
}

+(void)add_coins:(int)ct {
	[DataStore set_key:STO_CURRENT_COINS flt_value:[self get_current_coins]+ct];
}

static GameItem current_item = Item_NOITEM;
+(GameItem)get_current_gameitem {
	return current_item;
}

+(void)set_current_gameitem:(GameItem)g {
	current_item = g;
}

+(void)set_equipped_gameitem:(GameItem)g {
	[DataStore set_key:STO_EQUIPPED int_value:(int)g];
}

+(GameItem)get_equipped_gameitem {
	return (GameItem)[DataStore get_int_for_key:STO_EQUIPPED];
}

+(void)reset_to_equipped_gameitem {
	[self set_current_gameitem:[DataStore get_int_for_key:STO_EQUIPPED]];
}

+(NSString*)gameitem_to_upgrade_level_string:(GameItem)gi {
    return [NSString stringWithFormat:@"upgrade_%d",gi];
}

+(NSString*)key_gameitem_owned:(GameItem)g {
	return [NSString stringWithFormat:@"owned_item_%d",g];
}

+(BOOL)get_item_owned:(GameItem)g {
	return [DataStore get_int_for_key:[self key_gameitem_owned:g]];
}

+(void)set_item:(GameItem)g owned:(BOOL)owned {
	[DataStore set_key:[self key_gameitem_owned:g] int_value:owned];
}

+(int)get_upgrade_level:(GameItem)gi {
    return [DataStore get_int_for_key:[self gameitem_to_upgrade_level_string:gi]];
}

+(void)upgrade:(GameItem)gi {
    [DataStore set_key:[self gameitem_to_upgrade_level_string:gi] int_value:[self get_upgrade_level:gi]+1];
}

+(BOOL)can_upgrade:(GameItem)g {
	int uglvl = [self get_upgrade_level:g];
	return uglvl < 3;
}

static NSArray *valid_characters;
+(void)assert_valid_character:(NSString*)character {
	BOOL valid = NO;
	for (NSString *i in valid_characters) {
		if ([i isEqualToString:character]) valid = YES;
	}
	if (!valid) [NSException raise:@"invalid character" format:@""];
}

//character unlock
+(BOOL)get_character_unlocked:(NSString*)character {
	[self assert_valid_character:character];
	[self unlock_character:TEX_DOG_RUN_1];
	return [DataStore get_int_for_key:character];
}

+(void)unlock_character:(NSString*)character {
	[self assert_valid_character:character];
	[DataStore set_key:character int_value:1];
}

#define KEY_SFX_MUTED @"KEY_SFX_MUTED"
#define KEY_BGM_MUTED @"KEY_BGM_MUTED"
+(BOOL)get_sfx_muted {
	return [DataStore get_int_for_key:KEY_SFX_MUTED];
}

+(BOOL)get_bgm_muted {
	return [DataStore get_int_for_key:KEY_BGM_MUTED];
}

+(void)set_sfx_muted:(BOOL)t {
	[DataStore set_key:KEY_SFX_MUTED int_value:t];
}

+(void)set_bgm_muted:(BOOL)t {
	[DataStore set_key:KEY_BGM_MUTED int_value:t];
}

#define KEY_ADS_DISABLED @"KEY_ADS_DISABLED"
+(void)set_ads_disabled:(BOOL)t {
	[DataStore set_key:KEY_ADS_DISABLED int_value:t];
}
+(BOOL)get_ads_disabled {
	return [DataStore get_int_for_key:KEY_ADS_DISABLED];
}

@end
