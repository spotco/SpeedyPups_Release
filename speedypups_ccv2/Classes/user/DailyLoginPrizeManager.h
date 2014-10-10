#import <Foundation/Foundation.h>
@class CallBack;

@interface DailyLoginPrizeManager : NSObject
+(BOOL)daily_wheel_reset_open;
+(void)take_daily_wheel_reset;
+(long)get_time_until_new_day;
+(void)daily_popup_web_check:(CallBack*)ready fail:(CallBack*)fail;
+(BOOL)daily_popup_after_check_show;

+(void)increment_coins_spawned_today;
+(BOOL)conditional_do_coin_level;

@end
