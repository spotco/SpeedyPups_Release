#import "CCSprite.h"
#import "MainMenuLayer.h"
#import "BirdFlock.h"
#import "ChallengeModeSelect.h"
@class LabelGroup;
@class SpriteGroup;

typedef enum {
    PlayPageMode_WAIT,
    PlayPageMode_DOGRUN,
    PlayPageMode_SCROLLUP,
    PlayPageMode_EXIT,
    PlayPageMode_MODE_CHOOSE,
    PlayPageMode_CHALLENGE_SELECT,
    PlayPageMode_CHALLENGE_VIEW
} PlayPageMode;

@interface NMenuPlayPage : NMenuPage <GEventListener> {
    PlayPageMode cur_mode;
    BirdFlock *birds;
    
    CCMenuItem *playbutton;
    CCSprite *logo, *logo_base;
    CCMenu *nav_menu,*mode_choose_menu;
    ChallengeModeSelect *challengeselect;

    CCSprite *rundog;
    
    int ct;
    float scrollup_pct;
    
    BOOL kill;
	
	GEvent *play_mode_type;
	
	LabelGroup *startworld_disp;
	SpriteGroup *startworld_disp_icon;
	
	NSMutableArray *challenges_completed_disps;
	
	CCSprite *first_time_popup;
	
	CSF_CCSprite *highscore_sign_base;
	
	CCMenuItemSprite *wheel_ad_button;

	CCMenu *share_buttons;
}

+(NMenuPlayPage*)cons;

@end
