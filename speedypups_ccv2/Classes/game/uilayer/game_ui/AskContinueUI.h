#import "cocos2d.h"
#import "Common.h"
@class MenuCurtains;

typedef enum {
	AskContinueUI_COUNTDOWN,
	AskContinueUI_COUNTDOWN_PAUSED,
	AskContinueUI_YES_TRANSFER_MONEY,
	AskContinueUI_YES_RUNOUT,
	AskContinueUI_TRANSITION_TO_GAMEOVER,
	AskContinueUI_IAP
} AskContinueUI_MODE;

@class GEvent;

@interface AskContinueUI : CCSprite {
	CCNode *ask_continue_ui;
	CCMenu *yesnomenu;
	CCSprite *playericon;
	int player_anim_ct;
	
	int mod_ct;
	AskContinueUI_MODE curmode;
	
	CCSprite *continue_logo;
	
    CCLabelTTF *countdown_disp;
	float countdown_disp_scale;
    int countdown_ct;
    int continue_cost;
	int actual_cost;
	int actual_next_continue_price;
	
	CSF_CCSprite *continue_price_pane;
	float continue_price_pane_pulse_t;
	
	CCLabelTTF *continue_price;
	CCLabelTTF *total_disp;
	NSMutableArray *bone_anims;
	
	MenuCurtains *curtains;
}

+(AskContinueUI*)cons;
-(void)start_countdown:(int)cost;
-(void)dispatch_event:(GEvent*)evt;

@end
