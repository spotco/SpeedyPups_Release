#import "CCLayer.h"
#import "Resource.h"
#import "AudioManager.h"
#import "Common.h"
#import "GEventDispatcher.h"
#import "MainMenuBGLayer.h"
//#import <iAd/iAd.h>

@class MainMenuInventoryLayer;
@class BasePopup;

#define MENU_STARTING_PAGE_ID 2
#define MENU_DOG_MODE_PAGE_ID 1
#define MENU_MAP_PAGE_ID 3
#define MENU_SHOP_PAGE 0

@interface NMenuPage : CCSprite
-(void)touch_begin:(CGPoint)pt;
-(void)touch_move:(CGPoint)pt;
-(void)touch_end:(CGPoint)pt;
@end

@interface MainMenuLayer : CCLayer <GEventListener/*, ADBannerViewDelegate*/ > {
    NSMutableArray* menu_pages;
    int cur_page;
    CGPoint last,dp;
	
	BasePopup *current_popup;
	int popup_prev_visible;
}

@property(readwrite,strong) MainMenuBGLayer* bg;
@property(readwrite,strong) MainMenuInventoryLayer* inventory_layer;

+(CCScene*)scene;

@end