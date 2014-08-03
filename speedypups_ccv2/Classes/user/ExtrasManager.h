#import <Foundation/Foundation.h>
@class TexRect;
typedef enum Extras_Type {
	Extras_Type_ART,
	Extras_Type_MUSIC,
	Extras_Type_SFX
} Extras_Type;

@interface ExtrasManager : NSObject
+(NSString*)name_for_key:(NSString*)key;
+(NSString*)desc_for_key:(NSString*)key;
+(BOOL)own_extra_for_key:(NSString*)key;
+(void)set_own_extra_for_key:(NSString*)key;

+(NSMutableArray*)all_extras;
+(NSString*)random_unowned_extra;

+(Extras_Type)type_for_key:(NSString*)key;
+(TexRect*)texrect_for_type:(Extras_Type)type;
@end
