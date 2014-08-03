#import "cocos2d.h"
@class CCLabelTTF_Pooled;

@interface ChallengeModeSelect : CCSprite {
    NSMutableArray *panes;
    CCSprite *pagewindow;
    CCMenuItem *leftarrow, *rightarrow;
    int page_offset;
    
    CCSprite *selectmenu, *chosenmenu;
    
	CCLabelTTF *reward_amount,*chosen_mapname, *chosen_name, *chosen_goal;
	
	CCSprite *chosen_preview;
    CCSprite *show_reward;
	CCSprite *show_already_beaten;
	int chosen_level;
}

+(ChallengeModeSelect*)cons;
-(void)set_to_highest_unlocked_page;
-(void)set_to_first_page;
@end
