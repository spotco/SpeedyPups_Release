#import "DailyLoginPrizeManager.h"
#import "Common.h" 
#import "MenuCommon.h"
#import "DataStore.h"
#import "DailyLoginPopup.h"
#import "MenuCommon.h"
#import "UserInventory.h"
#import "WebRequest.h"
#import "JSONKit.h"

@implementation DailyLoginPrizeManager

//#define TIME_URL @"http://spotcos.com/SpeedyPups/time.php"
#define TIME_URL @"http://speedypups.com/time.php"

#define KEY_TODAY @"key_today"
#define KEY_FIRST_LOGIN_PRIZE_TAKEN @"key_first_login_prize_taken"
#define KEY_DAILY_WHEEL_RESET_TAKEN @"key_daily_wheel_reset_taken"
#define KEY_COINS_SPAWNED_TODAY @"key_coins_spawned_today"
#define DAY_TIME 24 * 60 * 60

+(BOOL)daily_wheel_reset_open {
	return [DataStore get_int_for_key:KEY_DAILY_WHEEL_RESET_TAKEN] == 0;
}

+(void)take_daily_wheel_reset {
	[DataStore set_key:KEY_DAILY_WHEEL_RESET_TAKEN flt_value:1];
}

static NSString *web_today = NULL;
static long web_remaining = 0;
static long timeof_web_remaining = 0;

+(void)daily_popup_web_check:(CallBack *)ready fail:(CallBack *)fail {
	if ([DataStore get_str_for_key:KEY_TODAY] == NULL) {
		[Common run_callback:ready];
		[WebRequest request_to:TIME_URL callback:^(NSString* response, WebRequestStatus status) {
			if (status == WebRequestStatus_OK) {
				NSDictionary *json = [response objectFromJSONString];
				web_remaining = [[json objectForKey:@"remain"] longValue];
				timeof_web_remaining = sys_time();
				web_today = [json objectForKey:@"today"];
				NSLog(@"time.php request(%@,%lu)",web_today,web_remaining);
				if (web_today != NULL) {
					[DataStore set_key:KEY_TODAY str_value:web_today];
				}
				
			}
		}];
		
	} else {
		[WebRequest request_to:TIME_URL callback:^(NSString* response, WebRequestStatus status) {
			if (status == WebRequestStatus_OK) {
				NSDictionary *json = [response objectFromJSONString];
				web_remaining = [[json objectForKey:@"remain"] longValue];
				timeof_web_remaining = sys_time();
				web_today = [json objectForKey:@"today"];
				NSLog(@"time.php request(%@,%lu)",web_today,web_remaining);
				[Common run_callback:ready];
				
			} else if (status == WebRequestStatus_FAIL) {
				[Common run_callback:fail];
				
			}
		}];
	}
}

+(long)get_time_until_new_day {
	if (timeof_web_remaining == 0) return -1;
	return MAX(0,web_remaining - (sys_time() - timeof_web_remaining));
}

+(BOOL)daily_popup_after_check_show {
	if ([DataStore get_str_for_key:KEY_TODAY] == NULL) {
		if (web_today != NULL) {
			[DataStore set_key:KEY_TODAY str_value:web_today];
		}
		if ([DataStore get_int_for_key:KEY_FIRST_LOGIN_PRIZE_TAKEN] == 0) {
			[DataStore set_key:KEY_FIRST_LOGIN_PRIZE_TAKEN int_value:1];
			[self first_login_prize_popup];
			return YES;
		}
		
	} else if (web_today != NULL) {
		if (!streq([DataStore get_str_for_key:KEY_TODAY], web_today)){
			[DataStore set_key:KEY_TODAY str_value:web_today];
			[self daily_prize_popup];
			[DataStore set_key:KEY_DAILY_WHEEL_RESET_TAKEN int_value:0];
			[DataStore set_key:KEY_COINS_SPAWNED_TODAY int_value:0];
			return YES;
		}
	}
	
	return NO;
}

+(void)first_login_prize_popup {
	BasePopup *p = [DailyLoginPopup cons];
	[self basepopup:p
			 add_h1:@"Welcome!"
				 h2:@"To celebrate your first day, here's 3 coins!"
				 h3:[DailyLoginPrizeManager get_daily_tip]
				amt:3];
	[UserInventory add_coins:3];
	[MenuCommon popup:p];
}
			   
+(void)daily_prize_popup {
	BasePopup *p = [DailyLoginPopup cons];
	[self basepopup:p
			 add_h1:@"Welcome back!"
				 h2:@"For playing today, here's a coin!"
				 h3:[DailyLoginPrizeManager get_daily_tip]
				amt:1];
	[UserInventory add_coins:1];
	[MenuCommon popup:p];
}

#define KEY_DAILY_TIP @"key_daily_tip"
+(NSString*)get_daily_tip {
	int tip = [DataStore get_int_for_key:KEY_DAILY_TIP];
	NSArray *tips = @[
		@"Play every day for some great prizes!",
		@"Don't like ads? Buy ADFREE from the store!",
		@"Use coins to unlock characters from the store!",
		@"You'll find the most coins on your first run of the day!",
		@"Use coins to continue after a game over!",
		@"Need more coins? Try doing some challenges!",
		@"Need more coins? Spend your bones on the Wheel of Prizes!"
	];
	[DataStore set_key:KEY_DAILY_TIP int_value:(tip+1)%tips.count];
	NSString *rtv = [tips get:tip];
	return [NSString stringWithFormat:@"Tip: %@",rtv==NULL?@"???":rtv];
}

+(void)basepopup:(BasePopup*)p add_h1:(NSString*)h1 h2:(NSString*)h2 h3:(NSString*)h3 amt:(int)amt {
	[p addChild:[Common cons_label_pos:[Common pct_of_obj:p pctx:0.5 pcty:0.875]
								 color:ccc3(20,20,20)
							  fontsize:35
								   str:h1]];
	[p addChild:[Common cons_label_pos:[Common pct_of_obj:p pctx:0.5 pcty:0.75]
								 color:ccc3(20,20,20)
							  fontsize:15
								   str:h2]];
	[p addChild:[Common cons_label_pos:[Common pct_of_obj:p pctx:0.5 pcty:0.675]
								 color:ccc3(200,30,30)
							  fontsize:10
								   str:h3]];
	[p addChild:[[CCSprite spriteWithTexture:[Resource get_tex:TEX_ITEM_SS]
										rect:[FileCache get_cgrect_from_plist:TEX_ITEM_SS idname:@"star_coin"]]
				 pos:[Common pct_of_obj:p pctx:0.425 pcty:0.5]]];
	[p addChild:[Common cons_label_pos:[Common pct_of_obj:p pctx:0.5325 pcty:0.5]
								 color:ccc3(200,30,30)
							  fontsize:12
								   str:@"x"]];
	[p addChild:[[Common cons_label_pos:[Common pct_of_obj:p pctx:0.575 pcty:0.5]
								  color:ccc3(200,30,30)
							   fontsize:25
									str:strf("%d",amt)] anchor_pt:ccp(0,0.5)]];
}

+(int)coins_spawned_today {
	return [DataStore get_int_for_key:KEY_COINS_SPAWNED_TODAY];
}
+(void)increment_coins_spawned_today {
	[DataStore set_key:KEY_COINS_SPAWNED_TODAY int_value:[self coins_spawned_today]+1];
}
+(BOOL)conditional_do_coin_level {
	int som = [self coins_spawned_today] + 2;
	return int_random(0, som) == 0;
}

@end
