#import "cocos2d.h"
@class GameEngineLayer;

@interface GameOverUI : CCSprite {
	CCSprite *info_disp_pane;
	int disp_pane_scroll_move_ct;
	BOOL is_info_disp_pane_scroll;
	CGPoint last_info_disp_pane_scroll_pt;
	CCSprite *clippedholder;
	
	float clippedholder_y_min, clippedholder_y_max;
	float vy;
	
	CCSprite *can_scroll_down,*can_scroll_up;
	
	BOOL has_schedule_update;
	NSDictionary *stat_labels;
}

+(GameOverUI*)cons;
-(void)set_stats:(GameEngineLayer*)g;

-(void)touch_begin:(CGPoint)pt;
-(void)touch_move:(CGPoint)pt;
-(void)touch_end:(CGPoint)pt;

@end
