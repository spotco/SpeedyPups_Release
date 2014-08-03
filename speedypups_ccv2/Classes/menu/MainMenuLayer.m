#import "MainMenuLayer.h"

#import "NMenuPlayPage.h"
#import "NMenuWorldSelectPage.h"
#import "NMenuCharSelectPage.h"
#import "NMenuTabShopPage.h"
#import "AudioManager.h"
#import "ObjectPool.h"
#import "BasePopup.h"
#import "MenuCommon.h"
//#import "NMenuShopPage.h"
#import "MainMenuInventoryLayer.h"
#import "GameMain.h"
#import "DailyLoginPrizeManager.h"
#import "ConnectingPopup.h"
#import "TrackingUtil.h"

@implementation NMenuPage
-(void)setOpacity:(GLubyte)opacity {
	[super setOpacity:opacity];
	for(CCSprite *sprite in [self children]) {
		if ([sprite respondsToSelector:@selector(setOpacity:)]) sprite.opacity = opacity;
	}
}
-(void)touch_begin:(CGPoint)pt{}
-(void)touch_move:(CGPoint)pt{}
-(void)touch_end:(CGPoint)pt{}
-(void)cleanup{}
@end

@implementation MainMenuLayer {
	BOOL first_update;
}
@synthesize bg;

+(CCScene*)scene {
    CCScene* sc = [CCScene node];
    MainMenuLayer *mm = [MainMenuLayer node];
    MainMenuBGLayer *mb = [MainMenuBGLayer cons];
    [mm setBg:mb];
    [mm.bg move_fg:[mm get_target_bg_pt]];
	mm.inventory_layer = [MainMenuInventoryLayer cons];
    
    [sc addChild:mb];
    [sc addChild:mm];
    [sc addChild:mm.inventory_layer];
	

	
	
    return sc;
}

-(id)init {
    self = [super init];
	
    [GEventDispatcher add_listener:self];
    [AudioManager playbgm_imm:BGM_GROUP_MENU];
    
    cur_page = MENU_STARTING_PAGE_ID;
    
    menu_pages = [[NSMutableArray alloc] init];
    [self add_pages];
    for(int i = 0; i < [menu_pages count]; i++) {
        CCSprite* c = [menu_pages objectAtIndex:i];
        [c setVisible:i==cur_page?YES:NO];
        [self addChild:c];
    }
    
    self.isTouchEnabled = YES;
    [self schedule:@selector(update:) interval:1.0/60];
	
	[DailyLoginPrizeManager daily_popup_web_check:[Common cons_callback:(NSObject*)[MainMenuLayer class] sel:@selector(daily_popup_go)]
											 fail:[Common cons_callback:(NSObject*)[MainMenuLayer class] sel:@selector(daily_popup_fail)]];
	BasePopup *p = [ConnectingPopup cons];
	[p addChild:[Common cons_label_pos:[Common pct_of_obj:p pctx:0.5 pcty:0.875]
								 color:ccc3(20,20,20)
							  fontsize:35
								   str:@"Connecting..."]];
	[p addChild:[Common cons_label_pos:[Common pct_of_obj:p pctx:0.5 pcty:0.75]
								 color:ccc3(20,20,20)
							  fontsize:15
								   str:@"Please Wait!"]];
	[p addChild:[Common cons_label_pos:[Common pct_of_obj:p pctx:0.5 pcty:0.675]
								   color:ccc3(200,30,30)
								fontsize:10
									 str:@"Connect online to recieve some great daily prizes!"]];
	[MenuCommon popup:p];

	
	
	
    return self;
}

static BOOL daily_popup_show = NO;
+(void)daily_popup_go {
	daily_popup_show = YES;
}
static BOOL daily_popup_fail = NO;
+(void)daily_popup_fail {
	daily_popup_fail = YES;
}

-(void)add_pages {
    [menu_pages addObject:[NMenuTabShopPage cons]];
    [menu_pages addObject:[NMenuCharSelectPage cons]];
    [menu_pages addObject:[NMenuPlayPage cons]];
    [menu_pages addObject:[NMenuWorldSelectPage cons]];
}

-(void)update:(ccTime)dt {
	if (!first_update) {
		[ObjectPool print_info];
		[Resource unload_textures];
		first_update = YES;
		
	} else if (daily_popup_show) {
		if (current_popup != NULL && [current_popup class] == [ConnectingPopup class])[self popup_close];
		daily_popup_show = NO;
		[DailyLoginPrizeManager daily_popup_after_check_show];
		
	} else if (daily_popup_fail) {
		if (current_popup != NULL && [current_popup class] == [ConnectingPopup class])[self popup_close];
		daily_popup_fail = NO;
	}
	
	if (current_popup != NULL) {
		[current_popup update];
	}
	
    float dx = [self get_target_bg_pt].x - [bg get_fg_pos].x;
    dx/=3;
    BOOL snapto = NO;
    if (ABS(dx) < 0.25) {
        [bg move_fg:[self get_target_bg_pt]];
    } else {
        [bg move_fg:ccp([bg get_fg_pos].x+dx,[bg get_fg_pos].y)];
        snapto = YES;
    }
    
    
    [bg update];
	
	if (current_popup != NULL) return;
	
    for(int i = 0; i < [menu_pages count]; i++) {
        CCSprite* c = [menu_pages objectAtIndex:i];
        if (snapto) {
            [c setVisible:NO];
            [c setOpacity:0];
        } else {
            [c setVisible:i==cur_page?YES:NO];
            if (c.visible) {
                [c setOpacity:(255-c.opacity)/5.0+c.opacity];
                if(c.opacity > 245) [c setOpacity:255];
            }
        }
    }
	
	
    
    [GEventDispatcher push_event:[[GEvent cons_type:GEventType_MENU_TICK] add_f1:dt f2:dt]];
	[GEventDispatcher dispatch_events]; //breaks if you do immediate_event in menu->freerun, dunno why
}

-(CGPoint)get_target_bg_pt {
    return ccp(-[Common SCREEN].width*cur_page,0);
}

-(void)dispatch_event:(GEvent *)e {
    if (e.type == GEventType_MENU_GOTO_PAGE) {
        cur_page = e.i1;
		
    } else if (e.type == GEventType_MENU_PLAY_AUTOLEVEL_MODE) {
        [self exit];
        [GameMain start_game_autolevel];
		
		[TrackingUtil track_evt:TrackingEvt_PlayFreeRun val1:[FreeRunStartAtManager name_for_loc:[FreeRunStartAtManager get_starting_loc]]];
		
    } else if (e.type == GEventType_MENU_PLAY_CHALLENGELEVEL_MODE) {
		[self exit];
		[GameMain start_game_challengelevel:[ChallengeRecord get_challenge_number:e.i1]];
		
		[TrackingUtil track_evt:TrackingEvt_PlayChallenge val1:strf("%d",e.i1)];
		
	} else if (e.type == GEventType_QUIT) {
		[self exit];
		if (e.i1 == 1) {
			[GameMain start_introanim];
		} else {
			[GameMain start_menu];
		}
		
	} else if (e.type == GEventType_MENU_POPUP) {
		if (current_popup == NULL) {
			for (int i = 0; i < menu_pages.count; i++) {
				if ([menu_pages[i] visible]) popup_prev_visible = i;
				[menu_pages[i] setVisible:NO];
			}
			[self.inventory_layer setVisible:NO];
			current_popup = [e get_value:@"popup"];
			[current_popup add_close_button:[Common cons_callback:self sel:@selector(popup_close)]];
			[self addChild:current_popup];
		} else {
			[self popup_close];
			current_popup = [e get_value:@"popup"];
			[current_popup add_close_button:[Common cons_callback:self sel:@selector(popup_close)]];
			[self addChild:current_popup];
			
		}
		
	}
}

-(void)popup_close {
	if (current_popup != NULL) {
		[self removeChild:current_popup cleanup:YES];
		current_popup = NULL;
		[menu_pages[popup_prev_visible] setVisible:YES];
		[AudioManager playsfx:SFX_MENU_DOWN];
	}
	[self.inventory_layer setVisible:YES];
}

-(CGPoint)grab_gl_coord_touch:(NSSet*)touches {
	CGPoint touch;
    for (UITouch *t in touches) touch = [t locationInView:[t view]];
	return [[CCDirector sharedDirector] convertToGL:touch];
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint touch = [self grab_gl_coord_touch:touches];
	if (![self.inventory_layer window_open]) {
		for (NMenuPage *p in menu_pages) [Common is_visible:p] ? [p touch_begin:touch]:0;
	} else {
		[self.inventory_layer touch_begin:touch];
	}
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint touch = [self grab_gl_coord_touch:touches];
	if (![self.inventory_layer window_open]) {
		for (NMenuPage *p in menu_pages) [Common is_visible:p] ? [p touch_move:touch]:0;
	} else {
		[self.inventory_layer touch_move:touch];
	}
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint touch = [self grab_gl_coord_touch:touches];
	if (![self.inventory_layer window_open]) {
		for (NMenuPage *p in menu_pages) [Common is_visible:p] ? [p touch_end:touch]:0;
	} else {
		[self.inventory_layer touch_end:touch];
	}
}


-(void)exit {
    [GEventDispatcher remove_all_listeners];
    [self unscheduleAllSelectors];
	[self removeAllChildrenWithCleanup:YES];
    [menu_pages removeAllObjects];
	[[self parent] removeAllChildrenWithCleanup:YES];
}

@end
