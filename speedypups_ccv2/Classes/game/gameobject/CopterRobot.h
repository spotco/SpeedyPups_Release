#import "GameObject.h"
#import "LauncherRocket.h"
#import "ExplosionParticle.h"
@class NCatBossBody;

typedef enum {
    Side_Left,
    Side_Right
} Side;

typedef enum {
	CopterMode_CatIn,
	CopterMode_CatTaunt,
	CopterMode_CatOut,
	
    CopterMode_IntroAnim,
    CopterMode_ToRemove,
    CopterMode_GotHit_FlyOff,
    CopterMode_Killed_Player,
    CopterMode_RightDash,
    CopterMode_LeftDash,
    CopterMode_SkyFireLeft,
    CopterMode_RapidFireRight,
    CopterMode_TrackingFireLeft,
    Coptermode_DeathExplode,
    Coptermode_BombWaveRight,
    Coptermode_BombDropRight,
    Coptermode_BombDropLeft
} CopterMode;

@interface CopterRobot : GameObject {
    CSF_CCSprite *body,*arm,*main_prop,*aux_prop,*main_nut,*aux_nut;
    CGPoint player_pos, rel_pos, actual_pos;
    int ct,ct2;
    BOOL setbroke;
    float groundlevel;
    float vr;
    CopterMode cur_mode;
    int hp;
    
    int lct,rct;
    
    float arm_r;
    BOOL arm_dir;
    
    CGPoint vibration;
    float vibration_theta;
    
    int recoil_ct;
    CGPoint recoil,recoil_tar;
    
    CGPoint flyoffdir;
	
	float sfx_ct;
	
	NCatBossBody *cat_body;
	CGPoint cat_body_rel_pos;
	float delay_ct;
}

+(CopterRobot*)cons_with_g:(GameEngineLayer*)g;

@end
