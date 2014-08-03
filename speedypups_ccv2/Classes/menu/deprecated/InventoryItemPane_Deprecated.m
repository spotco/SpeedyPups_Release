#import "InventoryItemPane_Deprecated.h"
#import "Resource.h"
#import "FileCache.h"
#import "UserInventory.h"

@implementation InventoryItemPane

#define k_CTDSP 1
#define k_OBJ 2

+(InventoryItemPane*)cons_pt:(CGPoint)pt cb:(CallBack*)cb {
    CCSprite *w1 = [self cons_window], *w2 = [self cons_window];
    [Common set_zoom_pos_align:w1 zoomed:w2 scale:1.2];
    InventoryItemPane *i = [InventoryItemPane itemFromNormalSprite:w1 selectedSprite:w2 target:cb.target selector:cb.selector];
    [i set_w1:w1 w2:w2];
    [i setPosition:pt];
    return i;
}

+(CCSprite*)cons_window {
    CCSprite *window = [CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS] rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"nmenu_inventoryitem"]];
	CCSprite *obj = [CCSprite node];
    [obj setPosition:[Common pct_of_obj:window pctx:0.5 pcty:0.5]];
    [window addChild:obj z:0 tag:k_OBJ];
    return window;
}

-(GameItem)cur_item { return cur_item; }

-(void)set_w1:(CCSprite*)tw1 w2:(CCSprite*)tw2 {w1=tw1; w2=tw2;}

+(CGRect)invpane_size {
    return [FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"nmenu_inventoryitem"];
}

-(void)set_item:(GameItem)item{
    cur_item = item;
    for (CCSprite* s in @[w1,w2]) {
        TexRect *tr = [GameItemCommon texrect_from:item];
        [(CCSprite*)[s getChildByTag:k_OBJ] setTexture:tr.tex];
        [(CCSprite*)[s getChildByTag:k_OBJ] setTextureRect:tr.rect];
        [(CCSprite*)[s getChildByTag:k_OBJ] setOpacity:[UserInventory get_upgrade_level:item]==0?100:255];
    }
}
@end

@implementation SlotItemPane
+(SlotItemPane*)cons_pt:(CGPoint)pt cb:(CallBack*)cb slot:(int)s {
    CCSprite *w1 = [self cons_window], *w2 = [self cons_window];
    [Common set_zoom_pos_align:w1 zoomed:w2 scale:1.2];
    SlotItemPane *i = [SlotItemPane itemFromNormalSprite:w1 selectedSprite:w2 target:cb.target selector:cb.selector];
    [i set_w1:w1 w2:w2];
    [i set_slot:s];
    [i setPosition:pt];
    [i setScale:1.3];
    return i;
}

-(void)set_slot:(int)i {
    slot = i;
}

+(CGRect)invpane_size {
    return [FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"subinventory_empty"];
}

+(float)objscale {
    return 0.35;
}

-(int)get_slot {
    return slot;
}

-(void)set_locked:(BOOL)t {
    [self setIsEnabled:!t];
    for (CCSprite* w in @[w1,w2]) {
        [w setTextureRect:t?[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"subinventory_locked"]:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"subinventory_empty"]];
    }
}

+(CCSprite*)cons_window {
    float wid = [self invpane_size].size.width, hei = [self invpane_size].size.height;
    CCSprite *window = [CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS] rect:[self invpane_size]];
    CCSprite *obj = [CCSprite node];
    [obj setScale:[self objscale]];
    [obj setPosition:ccp(wid*0.5,hei*0.5)];
    [window addChild:obj z:0 tag:k_OBJ];
    return window;
}

-(void)set_item:(GameItem)item {
    cur_item = item;
    for (CCSprite* s in @[w1,w2]) {
        TexRect *tr = [GameItemCommon texrect_from:item];
        [(CCSprite*)[s getChildByTag:k_OBJ] setTexture:tr.tex];
        [(CCSprite*)[s getChildByTag:k_OBJ] setTextureRect:tr.rect];
        [(CCSprite*)[s getChildByTag:k_OBJ] setOpacity:[UserInventory get_upgrade_level:item]==0?100:255];
    }
}
@end

@implementation MainSlotItemPane
+(MainSlotItemPane*)cons_pt:(CGPoint)pt cb:(CallBack*)cb slot:(int)s {
    CCSprite *w1 = [self cons_window], *w2 = [self cons_window];
    [Common set_zoom_pos_align:w1 zoomed:w2 scale:1.2];
    MainSlotItemPane *i = [MainSlotItemPane itemFromNormalSprite:w1 selectedSprite:w2 target:cb.target selector:cb.selector];
    [i set_w1:w1 w2:w2];
    [i set_slot:s];
    [i setPosition:pt];
    return i;
}
-(void)set_locked:(BOOL)t {
    [self setIsEnabled:!t];
	for (CCSprite* c in @[w1,w2]) {
		[(CCSprite*)[c getChildByTag:k_OBJ] setOpacity:t?150:200];
	}
    [self setOpacity:t?150:200];
}
+(float)objscale {
    return 1;
}
+(CGRect)invpane_size {
    return [FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"itemslot_small"];
}
-(void)set_item:(GameItem)item {
	//if (item == cur_item) return;
    cur_item = item;
    for (CCSprite* s in @[w1,w2]) {
        TexRect *tr = [GameItemCommon texrect_from:item];
        [(CCSprite*)[s getChildByTag:k_OBJ] setTexture:tr.tex];
        [(CCSprite*)[s getChildByTag:k_OBJ] setTextureRect:tr.rect];
        [(CCSprite*)[s getChildByTag:k_OBJ] setOpacity:200];
    }
}
@end