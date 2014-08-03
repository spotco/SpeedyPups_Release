#import <Foundation/Foundation.h>
@class TexRect;
@class CCTexture2D;
@class GameEngineLayer;

typedef enum {
    Item_NOITEM = 0,
    Item_Magnet = 1,
    Item_Rocket = 2,
    Item_Shield = 3,
    Item_Heart = 4,
	Item_Clock = 5
} GameItem;

@interface NSValue (valueWithGameItem)
+(NSValue*) valueWithGameItem:(GameItem)g;
@end

@interface GameItemCommon : NSObject
+(void)cons_after_textures_loaded;
+(TexRect*)texrect_from:(GameItem)gameitem;
+(TexRect*)object_textrect_from:(GameItem)type;
+(NSString*)name_from:(GameItem)gameitem;
+(NSString*)description_from:(GameItem)gameitem;

+(void)use_item:(GameItem)it on:(GameEngineLayer*)g clearitem:(BOOL)clearitem;
+(int)get_uselength_for:(GameItem)gi g:(GameEngineLayer*)g;

+(NSString*)stars_for_level:(int)i;

@end
