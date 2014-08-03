#import <Foundation/Foundation.h>
#import "Player.h"
#import "Island.h"
#import "GameObject.h"
#import "Common.h"
#import "PlayerEffectParams.h"
#import "DashEffect.h"
@class GameEngineLayer;

@interface GameControlImplementation:NSObject

+(CGPoint)get_post_swipe_drag;

+(void)control_update_player:(GameEngineLayer*)g;
+(void)reset_control_state;

+(void)set_nodash_time:(int)t;

+(void)touch_begin:(CGPoint)pt;
+(void)touch_move:(CGPoint)pt;
+(void)touch_end:(CGPoint)pt;

+(BOOL)get_clockbutton_hold;
+(void)set_clockbutton_hold:(BOOL)hold;

@end
