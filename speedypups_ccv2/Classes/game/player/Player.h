#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Island.h"
#import "Resource.h"
#import "Common.h"
#import "StreamParticle.h"
#import "RocketParticle.h"
#import "FloatingSweatParticle.h"
#import "FileCache.h"

typedef enum {
    player_anim_mode_RUN_SLOW = 2,
    player_anim_mode_RUN_MED = 3,
    player_anim_mode_RUN_FAST = 4,
    player_anim_mode_RUN_NONE = 5,
    player_anim_mode_CAPE = 6,
    player_anim_mode_ROCKET = 7,
    player_anim_mode_HIT = 8,
    player_anim_mode_SPLASH = 9,
    player_anim_mode_DASH = 10,
    player_anim_mode_SWING = 11,
    player_anim_mode_FLASH = 12,
    player_anim_mode_FLIP = 13,
	player_anim_mode_HEAD = 14
} player_anim_mode;

typedef enum {
	CharacterPower_DOUBLELIVES,
    CharacterPower_AUTOMAGNET,
    CharacterPower_HIGHERJUMP,
    CharacterPower_SLOWFALL,
    CharacterPower_TRIPLEJUMP,
    CharacterPower_LONGDASH,
    CharacterPower_DOUBLEDASH
} CharacterPower;

@interface Player : CSF_CCSprite <PhysicsObject> {
    CGPoint start_pt;
    PlayerEffectParams *current_params;
    PlayerEffectParams *temp_params;
    int particlectr;
    
    int prevndir;
    int flipctr;
    
    int cur_scy;
    int inair_ct;
    
    GameEngineLayer* __unsafe_unretained game_engine_layer;
    
    int new_spd,new_spd_ct;
    int new_magnetrad,new_magnetrad_ct;
    int armored_ct;
    int heart_ct;
	int clock_ct;
    
    id current_anim_action;
    NSMutableDictionary *normal_anims, *armored_anims;
    player_anim_mode anim_mode;
	
	CCSprite *sweatanim, *dashlines;
}

@property(readwrite,strong) CCSprite* player_img;
@property(readwrite,assign) CGPoint start_pt;
@property(readwrite,assign) BOOL dashing,dead;

+(void)set_character:(NSString*)tar;
+(NSString*)get_character;
+(NSString*)get_name:(NSString*)tar;
+(NSString*)get_full_name:(NSString*)tar;
+(NSString*)get_power_desc:(NSString*)tar;

+(void)character_bark;

+(BOOL)current_character_has_power:(CharacterPower)power;

+(Player*)cons_at:(CGPoint)pt;
-(void)cons_anim;
-(void)add_effect:(PlayerEffectParams*)effect;
-(void)reset;
-(void)reset_params;
-(void)remove_temp_params:(GameEngineLayer*)g;
-(void)update:(GameEngineLayer*)g;

-(HitRect) get_hit_rect;
-(HitRect) get_hit_rect_ignore_noclip;
-(HitRect) get_jump_rect;
-(CGPoint) get_center;
-(void) add_effect_suppress_current_end_effect:(PlayerEffectParams *)effect;
-(PlayerEffectParams*) get_current_params;
-(PlayerEffectParams*) get_default_params;

-(void)do_run_anim;
-(void)do_stand_anim;
-(void)do_cape_anim;

-(void)set_new_spd:(int)spd ct:(int)ct;

-(void)set_magnet_rad:(int)rad ct:(int)ct;
-(int)get_magnet_rad;

-(void)set_armored:(int)time;
-(BOOL)is_armored;
-(void)end_armored;

/*
-(void)set_heart:(int)time;
-(BOOL)has_heart;
-(void)reset_heart;
*/
 
-(void)set_clockeffect:(int)time;
-(BOOL)is_clockeffect;

-(player_anim_mode)cur_anim_mode;


@end
