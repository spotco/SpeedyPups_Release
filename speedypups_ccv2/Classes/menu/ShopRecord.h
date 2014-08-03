#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum {
    ShopTab_UPGRADE,
    ShopTab_CHARACTERS,
	ShopTab_UNLOCK,
	ShopTab_REALMONEY
} ShopTab;

#define SHOP_ITEM_MAGNET @"shop_item_magnet"
#define SHOP_ITEM_ARMOR @"shop_item_shield"
#define SHOP_ITEM_ROCKET @"shop_item_rocket"
#define SHOP_ITEM_CLOCK @"shop_item_clock"

#define SHOP_UPGRADE_MAGNET @"shop_upgrade_magnet"
#define SHOP_UPGRADE_ARMOR @"shop_upgrade_armor"
#define SHOP_UPGRADE_ROCKET @"shop_upgrade_rocket"
#define SHOP_UPGRADE_CLOCK @"shop_upgrade_clock"

#define SHOP_DOG_DOG2 @"shop_dog_dog2"
#define SHOP_DOG_DOG3 @"shop_dog_dog3"
#define SHOP_DOG_DOG4 @"shop_dog_dog4"
#define SHOP_DOG_DOG5 @"shop_dog_dog5"
#define SHOP_DOG_DOG6 @"shop_dog_dog6"
#define SHOP_DOG_DOG7 @"shop_dog_dog7"

#define SHOP_UNLOCK_WORLD2 @"shop_unlock_world2" 
#define SHOP_UNLOCK_WORLD3 @"shop_unlock_world3"

@interface ItemInfo : NSObject
@property(readwrite,unsafe_unretained) CCTexture2D* tex;
@property(readwrite,assign) CGRect rect;
@property(readwrite,assign) int price;
@property(readwrite,strong) NSString *name, *desc;
@property(readwrite,strong) NSString *val;
@property(readwrite,strong) NSString *short_name;
+(ItemInfo*)cons_tex:(NSString*)texn
			  rectid:(NSString*)rectid
				name:(NSString*)name
				desc:(NSString*)desc
			   price:(int)price
				 val:(NSString*)val;
@end

@interface IAPItemInfo : ItemInfo
@property(readwrite,assign) NSDecimalNumber *iap_price;
@property(readwrite,assign) NSString *iap_identifier;
+(IAPItemInfo*)cons_tex:(NSString*)texn
			  rectid:(NSString*)rectid
				name:(NSString*)name
				desc:(NSString*)desc
			   price:(int)price
				 val:(NSString*)val;
@end

@interface ShopRecord : NSObject
+(NSArray*)get_items_for_tab:(ShopTab)t;
+(BOOL)buy_shop_item:(NSString *)val price:(int)price;
@end
