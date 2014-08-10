#import "cocos2d.h"

@class CapeGameEngineLayer;
@class CSF_CCSprite;
@class MenuCurtains;

@interface CapeGameUILayer : CCLayer {
	CapeGameEngineLayer* __unsafe_unretained cape_game;
	
	CCNode *ingame_ui;
	CCNode *pause_ui;
	CCNode *uianim_holder;
	
	NSMutableArray *uianims;
	
	CCLabelBMFont *bones_disp, *lives_disp, *time_disp;
	CCSprite *itemlenbarfill, *itemlenbaricon;
	CSF_CCSprite *itemlenbarroot;
	
	CCLabelTTF *pause_lives_disp, *pause_bones_disp, *pause_time_disp, *pause_points_disp;
	CCLabelTTF *pause_new_high_score_disp;
	
	MenuCurtains *curtains;
	
	
	NSTimer *update_timer;
	
	CSF_CCSprite *challengedescbg;
	CCSprite *challengedescincon;
	CCLabelBMFont *challengedesc;
	
	CCSprite *scoredispbg;
	CCLabelBMFont *scoredisp;
	CCLabelBMFont *multdisp;
	float multdisp_anim_t;
	
	float current_disp_score;
	
	BOOL exit_to_gameover_menu;
}

+(CapeGameUILayer*)cons_g:(CapeGameEngineLayer*)g;

-(void)update;
-(void)do_bone_collect_anim:(CGPoint)start;
-(void)do_treat_collect_anim:(CGPoint)start;
-(void)do_tutorial_anim;

-(void)update_pct:(float)pct;
-(CCLabelBMFont*)bones_disp;
-(CCLabelBMFont*)lives_disp;
-(CCLabelBMFont*)time_disp;

-(void)exit;

-(void)itembar_set_visible:(BOOL)b;

-(void)pause;
-(void)unpause;

@end
