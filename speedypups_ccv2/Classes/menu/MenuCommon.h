#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Resource.h"
#import "FileCache.h"

#define t_SHOPBUTTON 1
#define t_SETTINGSBUTTON 2
#define t_CHARSELBUTTON 3
#define t_HOMEBUTTON 4
#define t_INVBUTTON 5

#define FTUE_HAS_PRESSED_MAP @"ftue_has_pressed_map"
#define FTUE_HAS_PRESSED_SHOP @"ftue_has_pressed_shop"

@class BasePopup;

@interface TouchButton : CSF_CCSprite

+(TouchButton*)cons_pt:(CGPoint)pt tex:(CCTexture2D*)tex texrect:(CGRect)texrect cb:(CallBack*)tcb;
-(id)cons_pt:(CGPoint)pt tex:(CCTexture2D *)tex texrect:(CGRect)texrect cb:(CallBack *)tcb;
-(void)touch_begin:(CGPoint)pt;
-(void)touch_move:(CGPoint)pt;
-(void)touch_end:(CGPoint)pt;
-(void)on_touch;
-(CGRect)hit_rect_local;
@property(readwrite,strong) CallBack* cb;
@end

@interface HoldTouchButton : TouchButton {
	float zoom_scale;
	float default_scale_x, default_scale_y;
}
+(HoldTouchButton*)cons_pt:(CGPoint)pt tex:(CCTexture2D*)tex texrect:(CGRect)texrect;
-(void)update;
@property(readwrite,assign) BOOL pressed;
@end

@interface AnimatedTouchButton : TouchButton {
	float target_scale;
	BOOL started_on;
}
+(AnimatedTouchButton*)cons_pt:(CGPoint)pt tex:(CCTexture2D*)tex texrect:(CGRect)texrect cb:(CallBack*)tcb;
-(void)update;
@end

@interface LabelGroup : NSObject {
	NSMutableArray *labels;
}
-(LabelGroup*)add_label:(CCLabelTTF*)l;
-(void)set_string:(NSString*)string;
@end

@interface SpriteGroup : NSObject {
	NSMutableArray *sprites;
}
-(SpriteGroup*)add_sprite:(CCSprite*)spr;
-(void)set_texture:(CCTexture2D*)tex;
-(void)set_texturerect:(CGRect)rect;
@end

@interface MenuCommon : NSObject

+(CSF_CCSprite*)menu_item:(NSString*)tex id:(NSString*)tid pos:(CGPoint)pos;
+(CCMenuItem*)item_from:(NSString*)tex rect:(NSString*)rect tar:(id)tar sel:(SEL)sel pos:(CGPoint)pos;
+(CCMenu*)cons_common_nav_menu;

+(CCSprite*)cons_descaler_for:(CCNode*)item pos:(CGPoint)pos;
+(CCSprite*)cons_flipper_for:(CCNode*)item x:(float)scx y:(float)y;

+(CCMenuItem*)nav_menu_get_charselbutton:(CCMenu*)menu;
+(void)inventory;
+(void)goto_shop;
+(void)goto_charsel;
+(void)goto_home;
+(void)goto_map;
+(void)close_inventory;

+(NSString*)secs_to_prettystr:(long)secs;
+(CCSprite*)wheel_of_prizes_button_sprite;
+(void)popup:(BasePopup*)p;
@end
