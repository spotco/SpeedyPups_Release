#import "cocos2d.h"
#import "Common.h"
#import "GameItemCommon.h"

@interface InventoryItemPane : CCMenuItemSprite {
    CCSprite *w1,*w2;
    GameItem cur_item;
}
+(InventoryItemPane*)cons_pt:(CGPoint)pt cb:(CallBack*)cb;
-(void)set_item:(GameItem)item;
-(GameItem)cur_item;
+(CGRect)invpane_size;
@end

@interface SlotItemPane : InventoryItemPane {
    int slot;
}
+(SlotItemPane*)cons_pt:(CGPoint)pt cb:(CallBack*)cb slot:(int)s;
+(float)objscale;
-(void)set_locked:(BOOL)t;
-(int)get_slot;
@end

@interface MainSlotItemPane : SlotItemPane
+(MainSlotItemPane*)cons_pt:(CGPoint)pt cb:(CallBack*)cb slot:(int)s;
@end