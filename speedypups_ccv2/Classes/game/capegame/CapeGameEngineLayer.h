#import "cocos2d.h"
#import "Common.h"
#import "GEventDispatcher.h"

@class BackgroundObject;
@class CapeGamePlayer;
@class CapeGameUILayer;
@class GameEngineLayer;
@class Particle;
@class CreditsFlybyObject;

@class CapeGameObject;

typedef enum {
	CapeGameMode_FALLIN,
	CapeGameMode_GAMEPLAY,
	CapeGameMode_FALLOUT,
	CapeGameMode_BOSS3_DEFEATED_FLYOUT
} CapeGameMode;

@interface CapeGameEngineLayer : CCLayer <GEventListener> {
	CCSprite *top_scroll, *bottom_scroll;
	BackgroundObject *thunder_bg;
	float thunder_flash_ct;
	
	CapeGamePlayer *player;
	CapeGameUILayer *ui;
	
	GameEngineLayer* __unsafe_unretained main_game;
	
	NSMutableArray *game_objects;
	NSMutableArray *gameobjects_tbr;
	
	CCSprite *particleholder;
	NSMutableArray *particles;
	NSMutableArray *particles_tba;
	
	BOOL touch_down, last_touch_down;
	BOOL initial_hold;
	
	int duration;
	CapeGameMode current_mode;
	
	BackgroundObject *bg;
	BackgroundObject *bgclouds;
	float bgclouds_scroll_x;
	
	BOOL count_as_death;
	BOOL behind_catchup;
	
	BOOL is_credits_scene;
	CreditsFlybyObject *credits_logo;
	CreditsFlybyObject *credits_text;
	float credits_ct;
	int credits_mode;
	float credits_bone_spawn;
	
	float gameend_constant_speed;
	
	float shake_ct;
	float shake_intensity;
}
@property(readwrite,assign) BOOL is_boss_capegame;

+(NSString*)get_level;
-(NSMutableArray*)get_gameobjs;

+(CCScene*)scene_with_level:(NSString*)file g:(GameEngineLayer*)g boss:(BOOL)boss;
+(CCScene*)credits_scene_g:(GameEngineLayer*)g;

-(GameEngineLayer*)get_main_game;
-(CapeGamePlayer*)player;

-(CapeGameUILayer*)get_ui;

-(void)add_particle:(Particle*)p;

-(void)collect_bone:(CGPoint)screen_pos;
-(void)do_get_hit;
-(void)duration_end;
-(void)do_powerup_rocket;
-(void)do_tutorial_anim;

-(void)add_gameobject:(CapeGameObject*)o;
-(void)remove_gameobject:(CapeGameObject*)o;

-(void)boss_end;
-(void)credits_end;

-(void)shake_for:(float)ct intensity:(float)intensity;
-(CGPoint)get_shake_offset;
-(void)freeze_frame:(int)ct;

-(void)pause:(BOOL)do_pause;
@end

@interface CapeGameObject : CSF_CCSprite
-(void)update:(CapeGameEngineLayer*)g;
@end
