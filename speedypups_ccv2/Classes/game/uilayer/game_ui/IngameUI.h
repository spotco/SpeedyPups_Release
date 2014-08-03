#import "cocos2d.h"
#import "InventoryItemPane_Deprecated.h"
#import "Challenge.h"
@class UIEnemyAlert;
@class UIWaterAlert;

@interface MRectCCMenuItemImage : CCMenuItemImage
@end

@interface IngameUI : CCSprite {
	UIEnemyAlert *enemy_alert_ui;
	UIWaterAlert *water_alert_ui;
	
    MainSlotItemPane *ingame_ui_item_slot;
    float item_duration_pct;
	float item_slot_notify_anim_sc;
	
	CGPoint itemlenbar_target_pos;
	CCSprite *itemlenbarfill, *readynotif, *itemlenbarroot,*itemlenbaricon;

	CSF_CCSprite *challengedescbg;
	CCSprite *challengedescincon;
	CCLabelBMFont *challengedesc;
	
	CCSprite *scoredispbg;
	CCLabelBMFont *scoredisp;
	CCLabelBMFont *multdisp;
	
	float current_disp_score;
	
	NSString *last_time;
}

@property(readwrite,strong) CCLabelBMFont *lives_disp, *bones_disp, *time_disp;

+(IngameUI*)cons;

-(void)set_enemy_alert_ui_ct:(int)i;
-(void)set_item_duration_pct:(float)f item:(GameItem)item;
-(void)update_item_slot;
-(void)update:(GameEngineLayer*)g;

-(void)enable_challengedesc_type:(ChallengeType)type;
-(void)set_challengedesc_string:(NSString*)str;

-(void)animslot_notification;

@end
