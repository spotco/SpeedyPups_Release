#import "MenuCommon.h"

@interface SpinButton : TouchButton

+(SpinButton*)cons_pt:(CGPoint)pos cb:(CallBack*)cb;

-(void)lock_time:(long)time;
-(void)lock_time_string:(NSString*)msg;
-(void)lock_bones:(int)cost;
-(void)unlock_cost:(int)cost;

@end
